{{ config(
    materialized='incremental',
    unique_key='condition_era_id',
	enabled=true
  )
}}

with condition_era as (

    select * from {{ ref('stg_condition_era')}}

)
select
    condition_era_id,
    person_id,
    condition_concept_id,
    condition_era_start_date,
    condition_era_end_date,
    CONDITION_ERA_START_DATE::timestamp as condition_era_start_datetime, -- ELIMINAR LINEA
    CONDITION_ERA_END_DATE::timestamp as condition_era_end_datetime,     -- ELIMINAR LINEA
    condition_occurrence_count
from condition_era
