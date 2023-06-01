-- stg_note

{{ config(
   materialized='table',
   enabled=true
)
}}

with patients as (

    select id,
           gender
    from {{ source('raw', 'patients') }}

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
    from {{ source('raw', 'conditions') }}

),
observations_pivot as (

    select patient,
           encounter,
           case when value = 'Current every day smoker' then true else false end as smoker
    from {{ source('raw', 'observations') }}

),
encounter as (

    select id, patient, start
    from {{ source('raw', 'encounters') }}

),
final_visit_ids  AS (

    select *
    from {{ ref('final_visit_ids') }}

),
all_conditions as (

    select fv.VISIT_OCCURRENCE_ID_NEW as episode_id,
       p.id as patient_id,
       e.start as note_date,
       p.gender as gender,
       c.pregnant as pregnant,
       c.cough as cough,
       c.fever as fever,
       c.diabetes as diabetes,
       c.hypertension as hypertension,
       c.infarction_history as infarction_history,
       o.smoker as smoker
    from encounter e
    inner join patients p on e.patient = p.id
    inner join conditions_pivot c on e.id = c.encounter
    inner join observations_pivot o on e.id = o.encounter
    inner join final_visit_ids fv on fv.encounter_id = e.id
),
final_table as (

    select episode_id,
           patient_id,
           gender,
           min(note_date) as note_date,
           bool_or(pregnant) as pregnant,
           bool_or(cough) as cough,
           bool_or(fever) as fever,
           bool_or(diabetes) as diabetes,
           bool_or(hypertension) as hypertension,
           bool_or(infarction_history) as infarction_history,
           bool_or(smoker) as smoker,
           floor(random() * 3 + 1)::int as note_type
    from all_conditions
    group by episode_id, patient_id, gender

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
     f.episode_id AS visit_occurrence_id,
     NULL::bigint AS visit_detail_id,
     NULL::varchar(50) AS note_source_value
from final_table f
