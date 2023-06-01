{{ config(
    materialized='incremental',
    unique_key='location_id',
	enabled=true
  )
}}

select *
from {{ ref('stg_location') }}
