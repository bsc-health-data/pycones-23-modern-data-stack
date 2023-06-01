{{
config(
    unique_key='provider_id',
    materialized='incremental',
	enabled=true
  )
}}

with provider as (

    select * from {{ ref('stg_provider')}}

)
select
    provider_id,
    provider_name,
    npi,
    dea,
    specialty_concept_id,
    care_site_id,
    year_of_birth,
    gender_concept_id,
    provider_source_value,
    specialty_source_value,
    specialty_source_concept_id,
    gender_source_value,
    gender_source_concept_id
from provider
