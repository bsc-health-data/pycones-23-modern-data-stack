-- depends_on: {{ ref('visit_occurrence') }}

-- OMOP table: measurement
-- More information: https://ohdsi.github.io/ETL-Synthea/Measurement.html

{{ config (
    unique_key = 'measurement_id',
    materialized='incremental',
    enabled=true
) }}

with measurement as (

    select * from {{ ref('stg_measurement')}}

)
select
    measurement_id,
    person_id,
    measurement_concept_id,
    measurement_date,
    measurement_datetime,
    measurement_time,
    measurement_type_concept_id,
    operator_concept_id,
    value_as_number,
    value_as_concept_id,
    unit_concept_id,
    range_low,
    range_high,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    measurement_source_value,
    measurement_source_concept_id,
    unit_source_value,
    unit_source_concept_id,
    value_source_value,
    measurement_event_id,
    meas_event_field_concept_id
from measurement
