-- depends_on: {{ ref('visit_occurrence') }}

-- OMOP table: drug_exposure
-- More information: https://ohdsi.github.io/ETL-Synthea/Drug_exposure.html

{{ config (
    unique_key = 'drug_exposure_id',
    materialized='incremental',
    enabled=true
) }}

with drug_exposure as (

    select distinct on (drug_exposure_id) *     -- Hacemos distinct porque hay problemas con el id (no hay codigos de medicamentos en Synthea)
    from {{ ref('stg_drug_exposure') }}
    order by drug_exposure_id, drug_concept_id
)
select
    drug_exposure_id,
    person_id,
    drug_concept_id,
    drug_exposure_start_date,
    drug_exposure_start_datetime,
    drug_exposure_end_date,
    drug_exposure_end_datetime,
    verbatim_end_date,
    drug_type_concept_id,
    stop_reason,
    refills,
    quantity,
    days_supply,
    sig,
    route_concept_id,
    lot_number,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    drug_source_value,
    drug_source_concept_id,
    route_source_value,
    dose_unit_source_value
from drug_exposure
