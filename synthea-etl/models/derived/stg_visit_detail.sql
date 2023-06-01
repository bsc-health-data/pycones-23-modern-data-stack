-- stg_visit_detail

{{ config(
    materialized='table',
	enabled=false
)
}}

select
    visit_occurrence_id as visit_detail_id,         -- NOT NULL
    person_id as person_id,                         -- NOT NULL
    0::int as visit_detail_concept_id,              -- NOT NULL
    visit_start_date as visit_detail_start_date,          -- NOT NULL
    visit_start_datetime as visit_detail_start_datetime,
    visit_end_date visit_detail_end_date,            -- NOT NULL
    visit_end_datetime as visit_detail_end_datetime,
    0::int as visit_detail_type_concept_id,         -- NOT NULL
    null::int as provider_id,
    0::int as care_site_id,
    null::varchar(50) as visit_detail_source_value,
    0::int as visit_detail_source_concept_id,
    0::int as admitted_from_concept_id,
    null::varchar(50) as admitted_from_source_value,
    null::varchar(50) as discharged_to_source_value,
    0::int as discharged_to_concept_id,
    null::int as preceding_visit_detail_id,
    null::int as parent_visit_detail_id,
    visit_occurrence_id as visit_occurrence_id                   -- NOT NULL
from {{ ref('stg_visit_occurrence') }}
