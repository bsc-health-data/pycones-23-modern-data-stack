-- stg_condition_occurrence



WITH conditions_num AS (

    SELECT *,
           row_number() over (partition by encounter order by encounter) as n_condition -- To get a PK for condition_occurrence (condition_occurrence_id)
    FROM "iomed"."raw"."conditions"

),
source_to_standard_vocab_map AS (

    SELECT * FROM "iomed"."cdm_dbt"."source_to_standard_vocab_map"
    WHERE source_vocabulary_id = 'SNOMED'
        AND source_domain_id = 'Condition'
        AND target_domain_id = 'Condition'
        AND target_standard_concept = 'S'
        AND target_invalid_reason IS NULL

),
source_to_source_vocab_map AS (

    SELECT * FROM "iomed"."cdm_dbt"."source_to_source_vocab_map"
    WHERE source_vocabulary_id = 'SNOMED'

),
final_visit_ids AS (

    SELECT * FROM "iomed"."cdm_dbt"."final_visit_ids"

),
person AS (

    SELECT * FROM "iomed"."cdm"."person"

)

SELECT
    
    abs(('x' || substr(md5(concat('condition_', encounter::text, '_', n_condition::text)), 1, 16))::bit(64)::bigint)
 AS condition_occurrence_id,
    p.person_id AS person_id,
    case when srctostdvm.target_concept_id is NULL then 0 else srctostdvm.target_concept_id end AS condition_concept_id,
    c.start AS condition_start_date,
    c.start AS condition_start_datetime,
    c.stop AS condition_end_date,
    c.stop AS condition_end_datetime,
    32020::int AS condition_type_concept_id, -- EHR encounter diagnosis
    0::int AS condition_status_concept_id,
    null::varchar(20) AS stop_reason,
    null::int AS provider_id,
    fv.visit_occurrence_id_new AS visit_occurrence_id,
    null::bigint AS visit_detail_id,
    c.code::varchar(50) AS condition_source_value,
    case when srctosrcvm.target_concept_id is NULL then 0 else srctosrcvm.target_concept_id end AS condition_source_concept_id,
    null::varchar(50) AS condition_status_source_value
from conditions_num c
left join source_to_standard_vocab_map srctostdvm
    on srctostdvm.source_code = c.code
left join source_to_source_vocab_map srctosrcvm
    on srctosrcvm.source_code = c.code
join final_visit_ids fv
    on fv.encounter_id = c.encounter
join person p on c.patient = p.person_source_value