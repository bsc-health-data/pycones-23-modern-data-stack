-- stg_care_site

{{ config(
   materialized='table',
   enabled=true
 )
}}

select
    0::bigint as care_site_id, -- NOT NULL
    'Hospital'::varchar(255) as care_site_name,
    0::int as place_of_service_concept_id, -- NOT NULL
    0::bigint as location_id,
    'Hospital'::text as care_site_source_value,
    'Hospital'::text as place_of_service_source_value
