-- depends_on: {{ ref('visit_occurrence') }}

-- OMOP table: procedure_occurrence
-- More information: https://ohdsi.github.io/ETL-Synthea/Procedure_occurrence.html

{{ config (
    unique_key = 'procedure_occurrence_id',
    materialized='incremental',
    enabled=true
) }}

with procedure_occurrence as (

    select * from {{ ref('stg_procedure_occurrence')}}

)
select
    procedure_occurrence_id,
    person_id,
    procedure_concept_id,
    procedure_date,
    procedure_datetime,
    procedure_end_date,
    procedure_end_datetime,
    procedure_type_concept_id,
    modifier_concept_id,
    quantity,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    procedure_source_value,
    procedure_source_concept_id,
    modifier_source_value
from procedure_occurrence
