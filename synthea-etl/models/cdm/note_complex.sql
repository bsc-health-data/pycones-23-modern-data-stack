{{ config (
    unique_key = 'note_id',
    materialized='incremental',
    enabled=false
) }}


with patients as (

    select id,
           gender
    from {{ source('raw','patients') }}

),
conditions_pivot as (

    select patient,
           encounter,
           case when code = '72892002' then true else false end as pregnant, -- Normal pregnancy
           case when code = '49727002' then true else false end as cough, -- Cough (finding)
           case when code = '386661006' then true else false end as fever, -- Fever (finding)
           case when code = '44054006' then true else false end as diabetes, -- Diabetes
           case when code = '59621000' then true else false end as hypertension, -- Hypertension
           case when code = '399211009' then true else false end as infarction_history -- History of myocardial infarction (situation
    from {{ ref('conditions') }}

),
observations_pivot as (

    select patient,
           encounter,
           case when value = 'Current every day smoker' then true else false end as smoker
    from {{ ref('observations') }}

),
encounter as (

    select id, patient, start
    from {{ ref('encounters') }}

),
final_visit_ids  AS (

    select *
    from {{ ref('final_visit_ids') }}

),
final_table as (

    select distinct on (e.id) e.id as episode_id,
       p.id as patient_id,
       e.start as note_date,
       p.gender as gender,
       c.pregnant as pregnant,
       c.cough as cough,
       c.fever as fever,
       c.diabetes as diabetes,
       c.hypertension as hypertension,
       c.infarction_history as infarction_history,
       o.smoker as smoker,
       floor(random() * 3 + 1)::int as note_type
    from encounter e
    inner join patients p on e.patient = p.id
    inner join conditions_pivot c on e.id = c.encounter
    inner join observations_pivot o on e.id = o.encounter

)

select
     {{ create_id_from_str("concat('note_', episode_id::text)") }} as note_id,
     {{ create_id_from_str("patient_id::text") }} as person_id,
     NULL::bigint AS note_event_id,
     1147070::int AS note_event_field_concept_id, -- visit_occurrence.visit_occurrence_id
     note_date::date AS note_date,
     note_date::timestamp AS note_datetime,
     44814639::int AS note_type_concept_id, -- Inpatient note
     42527620::int AS note_class_concept_id, -- Physician Hospital Note
     NULL::varchar(250) AS note_title,
     {{ generate_note_text('smoker', 'gender', 'pregnant', 'cough', 'fever', 'diabetes', 'hypertension', 'infarction_history', 'note_type') }} AS note_text,
     32678::int AS encoding_concept_id, -- UTF-8
     4182511::int AS language_concept_id, -- Spanish
     NULL::bigint AS provider_id,
     fv.visit_occurrence_id_new AS visit_occurrence_id,
     NULL::bigint AS visit_detail_id,
     NULL::varchar(50) AS note_source_value,
     {{ var('shard_id') }} AS shard_id
from final_table f
join final_visit_ids fv
    on fv.encounter_id = f.episode_id
