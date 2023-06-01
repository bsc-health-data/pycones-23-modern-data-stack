
{{ config (
    enabled = true
) }}

WITH encounters AS (

    SELECT * FROM {{ source('raw', 'encounters') }}

),
person AS (

    SELECT * FROM {{ ref('person') }}

),

-- IP VISITS
CTE_END_DATES AS (
    SELECT patient, encounterclass, EVENT_DATE-interval '1' day AS END_DATE
    FROM (
        SELECT patient, encounterclass, EVENT_DATE, EVENT_TYPE,
            MAX(START_ORDINAL) OVER (PARTITION BY patient, encounterclass ORDER BY EVENT_DATE, EVENT_TYPE ROWS UNBOUNDED PRECEDING) AS START_ORDINAL,
            ROW_NUMBER() OVER (PARTITION BY patient, encounterclass ORDER BY EVENT_DATE, EVENT_TYPE) AS OVERALL_ORD
        FROM (
            SELECT patient, encounterclass, start AS EVENT_DATE, -1 AS EVENT_TYPE,
                   ROW_NUMBER () OVER (PARTITION BY patient, encounterclass ORDER BY start, stop) AS START_ORDINAL
            FROM encounters
            WHERE encounterclass = 'inpatient'
            UNION ALL
            SELECT patient, encounterclass, stop+interval '1' day, 1 AS EVENT_TYPE, NULL
            FROM encounters
            WHERE encounterclass = 'inpatient'
        ) RAWDATA
    ) E
    WHERE (2 * E.START_ORDINAL - E.OVERALL_ORD = 0)
),
CTE_VISIT_ENDS AS (
    SELECT MIN(V.id) encounter_id,
        V.patient,
        V.encounterclass,
        V.start VISIT_START_DATE,
        MIN(E.END_DATE) AS VISIT_END_DATE
    FROM encounters V
        JOIN CTE_END_DATES E
            ON V.patient = E.patient
            AND V.encounterclass = E.encounterclass
            AND E.END_DATE >= V.start
    GROUP BY V.patient,V.encounterclass,V.start
),
IP_VISITS AS(
    SELECT T2.encounter_id,
        T2.patient,
        T2.encounterclass,
        T2.VISIT_START_DATE,
        T2.VISIT_END_DATE
    FROM (
        SELECT
            encounter_id,
            patient,
            encounterclass,
            MIN(VISIT_START_DATE) AS VISIT_START_DATE,
            VISIT_END_DATE
        FROM CTE_VISIT_ENDS
        GROUP BY encounter_id, patient, encounterclass, VISIT_END_DATE
    ) T2
),

-- EMERGENCY VISITS
ER_VISITS AS(
SELECT T2.encounter_id,
    T2.patient,
    T2.encounterclass,
    T2.VISIT_START_DATE,
    T2.VISIT_END_DATE
FROM (
    SELECT MIN(encounter_id) encounter_id,
        patient,
        encounterclass,
        VISIT_START_DATE,
        MAX(VISIT_END_DATE) AS VISIT_END_DATE
    FROM (
        SELECT CL1.id encounter_id,
            CL1.patient,
            CL1.encounterclass,
            CL1.start VISIT_START_DATE,
            CL2.stop VISIT_END_DATE
        FROM encounters CL1
        JOIN encounters CL2
            ON CL1.patient = CL2.patient
            AND CL1.start = CL2.start
            AND CL1.encounterclass = CL2.encounterclass
        WHERE CL1.encounterclass in ('emergency','urgent')
    ) T1
    GROUP BY patient, encounterclass, VISIT_START_DATE
) T2
),

-- OUTPATIENTS VISITS
CTE_VISITS_DISTINCT AS (
    SELECT MIN(id) encounter_id,
                   patient,
                   encounterclass,
                    start VISIT_START_DATE,
                    stop VISIT_END_DATE
    FROM encounters
    WHERE encounterclass in ('ambulatory', 'wellness', 'outpatient')
    GROUP BY patient,encounterclass,start,stop
),
OP_VISITS AS (
    SELECT MIN(encounter_id) encounter_id,
           patient,
            encounterclass,
            VISIT_START_DATE,
            MAX(VISIT_END_DATE) AS VISIT_END_DATE
    FROM CTE_VISITS_DISTINCT
    GROUP BY patient, encounterclass, VISIT_START_DATE
),

-- ALL VISITS
ALL_VISITS AS (

    SELECT * FROM IP_VISITS
    UNION ALL
    SELECT * FROM ER_VISITS
    UNION ALL
    SELECT * FROM OP_VISITS

)
SELECT *,
       {{ create_id_from_str('encounter_id') }} as visit_occurrence_id
FROM ALL_VISITS
