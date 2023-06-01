-- stg_visit_occurrence

{{ config(
   materialized='table',
   enabled=true
)
}}

WITH all_visits AS (

    SELECT * FROM {{ ref('all_visits') }}

),
person AS (

    SELECT * FROM {{ ref('person') }}

),
final_visit_ids AS (

    SELECT * FROM {{ ref('final_visit_ids') }}

)

SELECT
    av.visit_occurrence_id AS visit_occurrence_id,
    p.person_id AS person_id,
    {{ visit_concept_id("lower(av.encounterclass)") }} AS visit_concept_id,
    av.visit_start_date::DATE AS visit_start_date,
    av.visit_start_date::TIMESTAMP AS visit_start_datetime,
    av.visit_end_date::DATE AS visit_end_date,
    av.visit_end_date::TIMESTAMP AS visit_end_datetime,
    44818517::int AS visit_type_concept_id, -- Visit derived from encounter on claim
    NULL::int AS provider_id,
    NULL::int AS care_site_id,
    av.encounter_id::varchar(50) AS visit_source_value,
    0::int AS visit_source_concept_id,
    0::int AS admitted_from_concept_id,
    NULL::int AS admitted_from_source_value,
    null::int AS discharged_to_source_value,
    0::int AS discharged_to_concept_id,
    lag(visit_occurrence_id)
    over(partition by p.person_id
	order by av.visit_start_date) AS preceding_visit_occurrence_id
FROM all_visits av
JOIN person p ON av.patient = p.person_source_value
WHERE visit_occurrence_id IN (SELECT DISTINCT VISIT_OCCURRENCE_ID_NEW
                              FROM final_visit_ids)
