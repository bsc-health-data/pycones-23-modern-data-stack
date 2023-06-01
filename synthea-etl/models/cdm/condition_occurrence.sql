-- depends_on: {{ ref('visit_occurrence') }}

-- OMOP table: condition_occurrence
-- More information: https://ohdsi.github.io/ETL-Synthea/Condition_occurrence.html

{{ config (
    unique_key = 'condition_occurrence_id',
    materialized='incremental',
    enabled=true
) }}

with condition_occurrence as (

    select * from {{ ref('stg_condition_occurrence')}}

)
select
    condition_occurrence_id,
    person_id,
    condition_concept_id,
    condition_start_date,
    condition_start_datetime,
    condition_end_date,
    condition_end_datetime,
    condition_type_concept_id,
    condition_status_concept_id,
    stop_reason,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    condition_source_value,
    condition_source_concept_id,
    condition_status_source_value
from condition_occurrence
