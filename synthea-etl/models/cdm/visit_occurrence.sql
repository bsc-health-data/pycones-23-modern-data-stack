-- OMOP table: visit_occurrence
-- More information: https://ohdsi.github.io/ETL-Synthea/Visit_occurrence.html

-- session_replication_role TO 'replica' to avoid checking FK restrictions to
-- allow the deletion of already existing visit_occurrence_id (due to incremental materialization)

{{ config (
    unique_key = 'visit_occurrence_id',
    materialized='incremental',
    enabled=true
    )
}}

With visit_occurrence as (

    select * from {{ ref('stg_visit_occurrence')}}

)
select
    visit_occurrence_id,
    person_id,
    visit_concept_id,
    visit_start_date,
    visit_start_datetime,
    visit_end_date,
    visit_end_datetime,
    visit_type_concept_id,
    provider_id,
    care_site_id,
    visit_source_value,
    visit_source_concept_id,
    admitted_from_concept_id,
    admitted_from_source_value,
    discharged_to_source_value,
    discharged_to_concept_id,
    preceding_visit_occurrence_id
from visit_occurrence
