-- OMOP table: person
-- More information:  https://ohdsi.github.io/ETL-Synthea/Person.html


-- session_replication_role TO 'replica' to avoid checking FK restrictions to
-- allow the deletion of already existing person_id (due to incremental materialization)

{{
config(
  unique_key='person_id',
  materialized='incremental',
  enabled=true
  )
}}

with person as (

    select * from {{ ref('stg_person')}}

)
select
    person_id,
    gender_concept_id,
    year_of_birth,
    month_of_birth,
    day_of_birth,
    birth_datetime,
    race_concept_id,
    ethnicity_concept_id,
    location_id,
    provider_id,
    care_site_id,
    person_source_value,
    gender_source_value,
    gender_source_concept_id,
    race_source_value,
    race_source_concept_id,
    ethnicity_source_value,
    ethnicity_source_concept_id
from person
