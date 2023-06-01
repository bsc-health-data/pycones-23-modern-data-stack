-- stg_measurement

{{ config (
    materialized='table',
    enabled=true
)
}}


WITH final_visit_ids  AS (

    SELECT * FROM {{ ref('final_visit_ids') }}

),
source_to_source_vocab_map AS (

    SELECT * FROM {{ ref('source_to_source_vocab_map') }}
    WHERE source_vocabulary_id in ('SNOMED', 'LOINC') -- SNOMED: measurements from procedures, LOINC: measurements from observations

),
source_to_standard_vocab_map AS (

    SELECT * FROM {{ ref('source_to_standard_vocab_map') }}
    WHERE source_vocabulary_id in ('SNOMED', 'LOINC') -- SNOMED: measurements from procedures, LOINC: measurements from observations
        AND source_domain_id = 'Measurement'
        AND target_domain_id = 'Measurement'
        AND target_standard_concept = 'S'
        AND target_invalid_reason IS NULL

),
procedures_num AS (

    SELECT *,
           row_number() over (partition by encounter order by encounter) as n_procedures -- To get a PK for measurement (measurement_id)
    FROM {{ source('raw', 'procedures') }}

),
observations_num AS (

    SELECT *,
           row_number() over (partition by encounter order by encounter) as n_observations -- To get a PK for measurement (measurement_id)
    FROM {{ source('raw', 'observations') }}

),
person AS (

    SELECT * FROM {{ ref('person') }}

)

SELECT
    {{ create_id_from_str("concat('procedures_measurement_', encounter::text, '_', n_procedures::text)") }} AS measurement_id,
    p.person_id AS person_id,
    case when srctostdvm.target_concept_id is NULL then 0 else srctostdvm.target_concept_id end AS measurement_concept_id,
    pr.start::date AS measurement_date,
    pr.start::timestamp AS measurement_datetime,
    pr.start::timestamp AS measurement_time,
    5001 AS measurement_type_concept_id, -- Test ordered through EHR
    null::int AS operator_concept_id,
    null::float AS value_as_number,
    null::int AS value_as_concept_id,
    null::int AS unit_concept_id,
    null::float AS range_low,
    null::float AS range_high,
    null::bigint AS provider_id,
    fv.visit_occurrence_id_new AS visit_occurrence_id,
    null::bigint AS visit_detail_id,
    pr.code AS measurement_source_value,
    case when srctosrcvm.target_concept_id is NULL then 0 else srctosrcvm.target_concept_id end AS measurement_source_concept_id,
    null::varchar(50) AS unit_source_value,
    null::int AS unit_source_concept_id,
    null::varchar(50) AS value_source_value,
    null::int AS measurement_event_id,
    null::int AS meas_event_field_concept_id
from procedures_num pr
join source_to_standard_vocab_map srctostdvm
    on srctostdvm.source_code = pr.code
left join source_to_source_vocab_map srctosrcvm
    on srctosrcvm.source_code = pr.code
join final_visit_ids fv
    on fv.encounter_id = pr.encounter
join person p
  on p.person_source_value    = pr.patient

union all

SELECT
    {{ create_id_from_str("concat('observation_measurement_', encounter::text, '_', n_observations::text)") }} AS measurement_id,
    p.person_id AS person_id,
    case when srctostdvm.target_concept_id is NULL then 0 else srctostdvm.target_concept_id end AS measurement_concept_id,
    o.date::date AS measurement_date,
    o.date::timestamp AS measurement_datetime,
    o.date::timestamp AS measurement_time,
    5001 AS measurement_type_concept_id,  -- Test ordered through EHR
    null::int AS operator_concept_id,
    null::float AS value_as_number,
    null::int AS value_as_concept_id,
    null::int AS unit_concept_id,
    null::float AS range_low,
    null::float AS range_high,
    null::bigint AS provider_id,
    fv.visit_occurrence_id_new AS visit_occurrence_id,
    null::bigint AS visit_detail_id,
    o.code AS measurement_source_value,
    case when srctosrcvm.target_concept_id is NULL then 0 else srctosrcvm.target_concept_id end AS measurement_source_concept_id,
    null::varchar(50) AS unit_source_value,
    null::int AS unit_source_concept_id,
    null::varchar(50) AS value_source_value,
    null::int AS measurement_event_id,
    null::int AS meas_event_field_concept_id
from observations_num o
join source_to_standard_vocab_map srctostdvm
    on srctostdvm.source_code = o.code
left join source_to_source_vocab_map srctosrcvm
    on srctosrcvm.source_code = o.code
join final_visit_ids fv
    on fv.encounter_id = o.encounter
join person p
  on p.person_source_value    = o.patient
