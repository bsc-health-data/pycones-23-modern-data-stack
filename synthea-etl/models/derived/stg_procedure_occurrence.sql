-- stg_procedure_occurrence

{{ config(
   materialized='table',
   enabled=true
)
}}

WITH final_visit_ids  AS (

    SELECT * FROM {{ ref('final_visit_ids') }}

),
source_to_standard_vocab_map AS (

    SELECT * FROM {{ ref('source_to_standard_vocab_map') }}
    WHERE source_vocabulary_id = 'SNOMED'
        AND source_domain_id = 'Procedure'
        AND target_domain_id = 'Procedure'
        AND target_standard_concept = 'S'
        AND target_invalid_reason IS NULL

),
source_to_source_vocab_map AS (

    SELECT * FROM {{ ref('source_to_source_vocab_map') }}
    WHERE source_vocabulary_id  = 'SNOMED'

),
procedures_num AS (

    SELECT *,
           row_number() over (partition by encounter order by encounter) as n_procedures -- To get a PK for procedure_occurrence (procedure_occurrence_id)
    FROM {{ source('raw', 'procedures') }}

),

person AS (

    SELECT * FROM {{ ref('person') }}

)

SELECT
    {{ create_id_from_str("concat('procedures_', encounter::text, '_', n_procedures::text)") }} AS procedure_occurrence_id,
    p.person_id AS person_id,
    case when srctostdvm.target_concept_id is NULL then 0 else srctostdvm.target_concept_id end AS procedure_concept_id,
    pr.start::date AS procedure_date,
    pr.start::timestamp AS procedure_datetime,
    pr.stop::date AS procedure_end_date,
    pr.stop::timestamp AS procedure_end_datetime,
    38000275 AS procedure_type_concept_id, -- EHR order list entry
    0 AS modifier_concept_id,
    null::int AS quantity,
    null::bigint AS provider_id,
    fv.visit_occurrence_id_new AS visit_occurrence_id,
    null::bigint AS visit_detail_id,
    pr.code AS procedure_source_value,
    case when srctosrcvm.target_concept_id is NULL then 0 else srctosrcvm.target_concept_id end AS procedure_source_concept_id,
    null::varchar(50) AS modifier_source_value
from procedures_num pr
left join source_to_standard_vocab_map srctostdvm
    on srctostdvm.source_code = pr.code
left join source_to_source_vocab_map srctosrcvm
    on srctosrcvm.source_code = pr.code
join final_visit_ids fv
    on fv.encounter_id = pr.encounter
join person p
  on p.person_source_value = pr.patient
