

-- More information: https://ohdsi.github.io/CommonDataModel/sqlScripts.html#drug_eras

WITH cteDrugTarget AS (

    SELECT d.DRUG_EXPOSURE_ID
    ,d.PERSON_ID
    ,c.CONCEPT_ID
    ,d.DRUG_TYPE_CONCEPT_ID
    ,DRUG_EXPOSURE_START_DATE
    ,COALESCE(DRUG_EXPOSURE_END_DATE, (DRUG_EXPOSURE_START_DATE + DAYS_SUPPLY), (DRUG_EXPOSURE_START_DATE + integer '1')) AS DRUG_EXPOSURE_END_DATE
    ,c.CONCEPT_ID AS INGREDIENT_CONCEPT_ID
FROM "iomed"."cdm"."drug_exposure" d
INNER JOIN "iomed"."vocabularies"."concept_ancestor" ca ON ca.DESCENDANT_CONCEPT_ID = d.DRUG_CONCEPT_ID
INNER JOIN "iomed"."vocabularies"."concept" c ON ca.ANCESTOR_CONCEPT_ID = c.CONCEPT_ID
WHERE c.VOCABULARY_ID = 'RxNorm'
    AND c.CONCEPT_CLASS_ID = 'Ingredient'

),
cteEndDates AS (

SELECT PERSON_ID
    ,INGREDIENT_CONCEPT_ID
    ,(EVENT_DATE - integer '30') AS END_DATE -- unpad the end date
FROM (
    SELECT E1.PERSON_ID
        ,E1.INGREDIENT_CONCEPT_ID
        ,E1.EVENT_DATE
        ,COALESCE(E1.START_ORDINAL, MAX(E2.START_ORDINAL)) START_ORDINAL
        ,E1.OVERALL_ORD
    FROM (
        SELECT PERSON_ID
            ,INGREDIENT_CONCEPT_ID
            ,EVENT_DATE
            ,EVENT_TYPE
            ,START_ORDINAL
            ,ROW_NUMBER() OVER (
                PARTITION BY PERSON_ID
                ,INGREDIENT_CONCEPT_ID ORDER BY EVENT_DATE
                    ,EVENT_TYPE
                ) AS OVERALL_ORD -- this re-numbers the inner UNION so all rows are numbered ordered by the event date
        FROM (
            -- select the start dates, assigning a row number to each
            SELECT PERSON_ID
                ,INGREDIENT_CONCEPT_ID
                ,DRUG_EXPOSURE_START_DATE AS EVENT_DATE
                ,0 AS EVENT_TYPE
                ,ROW_NUMBER() OVER (
                    PARTITION BY PERSON_ID
                    ,INGREDIENT_CONCEPT_ID ORDER BY DRUG_EXPOSURE_START_DATE
                    ) AS START_ORDINAL
            FROM cteDrugTarget

            UNION ALL

            -- add the end dates with NULL as the row number, padding the end dates by 30 to allow a grace period for overlapping ranges.
            SELECT PERSON_ID
                ,INGREDIENT_CONCEPT_ID
                ,(DRUG_EXPOSURE_END_DATE + integer '30')
                ,1 AS EVENT_TYPE
                ,NULL
            FROM cteDrugTarget
            ) RAWDATA
        ) E1
    INNER JOIN (
        SELECT PERSON_ID
            ,INGREDIENT_CONCEPT_ID
            ,DRUG_EXPOSURE_START_DATE AS EVENT_DATE
            ,ROW_NUMBER() OVER (
                PARTITION BY PERSON_ID
                ,INGREDIENT_CONCEPT_ID ORDER BY DRUG_EXPOSURE_START_DATE
                ) AS START_ORDINAL
        FROM cteDrugTarget
        ) E2 ON E1.PERSON_ID = E2.PERSON_ID
        AND E1.INGREDIENT_CONCEPT_ID = E2.INGREDIENT_CONCEPT_ID
        AND E2.EVENT_DATE <= E1.EVENT_DATE
    GROUP BY E1.PERSON_ID
        ,E1.INGREDIENT_CONCEPT_ID
        ,E1.EVENT_DATE
        ,E1.START_ORDINAL
        ,E1.OVERALL_ORD
    ) E
WHERE 2 * E.START_ORDINAL - E.OVERALL_ORD = 0

),
cteDrugExpEnds AS (
    SELECT d.PERSON_ID
        ,d.INGREDIENT_CONCEPT_ID
        ,d.DRUG_TYPE_CONCEPT_ID
        ,d.DRUG_EXPOSURE_START_DATE
        ,MIN(e.END_DATE) AS ERA_END_DATE
    FROM cteDrugTarget d
    INNER JOIN cteEndDates e ON d.PERSON_ID = e.PERSON_ID
        AND d.INGREDIENT_CONCEPT_ID = e.INGREDIENT_CONCEPT_ID
        AND e.END_DATE >= d.DRUG_EXPOSURE_START_DATE
    GROUP BY d.PERSON_ID
        ,d.INGREDIENT_CONCEPT_ID
        ,d.DRUG_TYPE_CONCEPT_ID
        ,d.DRUG_EXPOSURE_START_DATE
),
final_drug_era AS (
    SELECT row_number() OVER (
        ORDER BY person_id
        ) AS drug_era_id
    ,person_id
    ,INGREDIENT_CONCEPT_ID AS drug_concept_id
    ,min(DRUG_EXPOSURE_START_DATE)::date AS drug_era_start_date
    ,ERA_END_DATE::date AS drug_era_end_date
    ,COUNT(*) AS DRUG_EXPOSURE_COUNT
    ,30 AS gap_days
FROM cteDrugExpEnds
GROUP BY person_id
    ,INGREDIENT_CONCEPT_ID
    ,drug_type_concept_id
    ,ERA_END_DATE
)

SELECT * from final_drug_era