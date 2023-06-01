-- stg_cdm_source

{{ config(
   materialized='table',
   enabled=true
 )
}}


select
  'hospital_edge'::varchar(255) as cdm_source_name, -- NOT NULL
  'hospital_edge'::varchar(25) as cdm_source_abbreviation,
  'IOMED'::varchar(255) as cdm_holder,
  'hospital_edge'::text as source_description,
  null::varchar(255) as source_documentation_reference,
  null::varchar(255) as cdm_etl_reference,
  null::date as source_release_date,
  null::date as cdm_release_date,
  'CDM v5.4'::varchar(10) as cdm_version,
  (select vocabulary_version from {{ source('vocabularies','vocabulary') }} where vocabulary_id='None')::varchar(20) as vocabulary_version
