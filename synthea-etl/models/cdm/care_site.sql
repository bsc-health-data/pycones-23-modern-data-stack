-- depends_on: {{ ref('location') }}

{{ config(
    materialized='incremental',
    unique_key='care_site_id',
	enabled=true
  )
}}

select *
from {{ ref('stg_care_site') }}
