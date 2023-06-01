-- stg_observation

{{ config(
   materialized='table',
   enabled=true
)
}}

WITH final_visit_ids  AS (

    SELECT * FROM {{ ref('final_visit_ids') }}

),
source_to_source_vocab_map AS (

    SELECT * FROM {{ ref('source_to_source_vocab_map') }}
    WHERE source_vocabulary_id = 'SNOMED'

),
source_to_standard_vocab_map AS (

    SELECT * FROM {{ ref('source_to_standard_vocab_map') }}
    WHERE source_vocabulary_id = 'SNOMED'
        AND source_domain_id = 'Observation'
        AND target_domain_id = 'Observation'
        AND target_standard_concept = 'S'
        AND target_invalid_reason IS NULL

),
allergies_num AS (

    SELECT *,
           row_number() over (partition by encounter order by encounter) as n_allergies -- To get a PK for observation (observation_id)
    FROM {{ source('raw', 'allergies') }}

),
conditions_num AS (

    SELECT *,
           row_number() over (partition by encounter order by encounter) as n_conditions -- To get a PK for observation (observation_id)
    FROM {{ source('raw', 'conditions') }}

),
person AS (

    SELECT * FROM {{ ref('person') }}

)

SELECT
    {{ create_id_from_str("concat('allergies_observation_', encounter::text, '_', n_allergies::text)") }} AS observation_id,
    p.person_id AS person_id,
    case when srctostdvm.target_concept_id is NULL then 0 else srctostdvm.target_concept_id end AS observation_concept_id,
    a.start AS observation_date,
    a.start AS observation_datetime,
    38000280 AS observation_type_concept_id, -- Observation recorded from EHR
    null::float AS value_as_number,
    null::varchar AS value_as_string,
    0::int AS value_as_concept_id,
    0::int AS qualifier_concept_id,
    0::int AS unit_concept_id,
    null::bigint AS provider_id,
    fv.visit_occurrence_id_new AS visit_occurrence_id,
    null::bigint AS visit_detail_id,
    a.code AS observation_source_value,
    case when srctosrcvm.target_concept_id is NULL then 0 else srctosrcvm.target_concept_id end AS observation_source_concept_id,
    null::varchar AS unit_source_value,
    null::varchar AS qualifier_source_value,
    null::varchar AS value_source_value,
    null::bigint AS observation_event_id,
    0::int AS obs_event_field_concept_id
from allergies_num a
left join source_to_standard_vocab_map srctostdvm
    on srctostdvm.source_code = a.code
left join source_to_source_vocab_map srctosrcvm
    on srctosrcvm.source_code = a.code
join final_visit_ids fv
    on fv.encounter_id = a.encounter
join person p
    on p.person_source_value = a.patient

union all

SELECT
    {{ create_id_from_str("concat('conditions_observation_', encounter::text, '_', n_conditions::text)") }} AS observation_id,
    p.person_id AS person_id,
    case when srctostdvm.target_concept_id is NULL then 0 else srctostdvm.target_concept_id end AS observation_concept_id,
    c.start AS observation_date,
    c.start AS observation_datetime,
    38000276 AS observation_type_concept_id, -- Problem list from EHR
    null::float AS value_as_number,
    null::varchar AS value_as_string,
    0::int AS value_as_concept_id,
    0::int AS qualifier_concept_id,
    0::int AS unit_concept_id,
    null::bigint AS provider_id,
    fv.visit_occurrence_id_new AS visit_occurrence_id,
    null::bigint AS visit_detail_id,
    c.code AS observation_source_value,
    case when srctosrcvm.target_concept_id is NULL then 0 else srctosrcvm.target_concept_id end AS observation_source_concept_id,
    null::varchar AS unit_source_value,
    null::varchar AS qualifier_source_value,
    null::varchar AS value_source_value,
    null::bigint AS observation_event_id,
    0::int AS obs_event_field_concept_id
from conditions_num c
join source_to_standard_vocab_map srctostdvm
    on srctostdvm.source_code = c.code
left join source_to_source_vocab_map srctosrcvm
    on srctosrcvm.source_code = c.code
join final_visit_ids fv
    on fv.encounter_id = c.encounter
join person p
  on p.person_source_value = c.patient
