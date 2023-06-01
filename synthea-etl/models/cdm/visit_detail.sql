-- SET CONSTRAINTS ALL DEFERRED to check FK contraints after the transaction
-- and allow the deletion of already existing visit_occurrence_id (due to incremental materialization)

{{ config(
    unique_key='visit_detail_id',
    materialized='incremental',
	enabled=false
  )
}}


with visit_detail as (

    select * from {{ ref('stg_visit_detail')}}

)
select
    visit_detail_id,
    person_id,
    visit_detail_concept_id,
    visit_detail_start_date,
    visit_detail_start_datetime,
    visit_detail_end_date,
    visit_detail_end_datetime,
    visit_detail_type_concept_id,
    provider_id,
    care_site_id,
    visit_detail_source_value,
    visit_detail_source_concept_id,
    admitted_from_concept_id,
    admitted_from_source_value,
    discharged_to_source_value,
    discharged_to_concept_id,
    preceding_visit_detail_id,
    parent_visit_detail_id, -- CAMBIAR
    visit_occurrence_id
from visit_detail
