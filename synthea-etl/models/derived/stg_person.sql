-- stg_person

{{ config(
    materialized='table',
	enabled=true
)
}}

with patients as (

    select * from {{ source('raw', 'patients') }}

),
person as (

select
    {{ create_id_from_str("id::text")}} AS person_id,
    {{ gender_concept_id ("gender") }} AS gender_concept_id,
    date_part('year', birthdate::DATE)::INT AS year_of_birth,
    date_part('month', birthdate::DATE)::INT AS month_of_birth,
    date_part('day', birthdate::DATE)::INT AS day_of_birth,
    birthdate::TIMESTAMP AS birth_datetime,
    {{ race_concept_id("race") }}  AS race_concept_id,
    {{ ethnicity_concept_id("ethnicity") }} AS ethnicity_concept_id,
    NULL::INT AS location_id,
    NULL::INT AS provider_id,
    NULL::INT AS care_site_id,
    id::VARCHAR(50) AS person_source_value,
    gender::VARCHAR(50) AS gender_source_value,
    0 AS gender_source_concept_id,
    race::VARCHAR(50) AS race_source_value,
    0 AS race_source_concept_id,
    ethnicity::VARCHAR(50) AS ethnicity_source_value,
    0 AS ethnicity_source_concept_id
from patients
where birthdate is not null -- Don't load patients who do not have birthdate and sex (change variable names if necessary)
      and gender is not null

)

select * from person
