-- OMOP table: death
-- More information:  https://ohdsi.github.io/CommonDataModel/cdm54.html#DEATH


-- session_replication_role TO 'replica' to avoid checking FK restrictions to
-- allow the deletion of already existing person_id (due to incremental materialization)

{{
config(
  unique_key='person_id',
  materialized='incremental',
  enabled=true
  )
}}

with death as (

    select * from {{ ref('stg_death') }}

)
select
    person_id,
    death_date,
    death_datetime,
    death_type_concept_id,
    cause_concept_id,
    cause_source_value,
    cause_source_concept_id
from death
