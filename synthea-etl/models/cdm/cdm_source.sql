{{ config(
    materialized='incremental',
    unique_key='cdm_source_name',
	enabled=false
  )
}}

select *
from {{ ref('stg_cdm_source') }}
