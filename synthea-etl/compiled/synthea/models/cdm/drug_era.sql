

with drug_era as (

    select * from "iomed"."cdm_dbt"."stg_drug_era"

)
select
    drug_era_id,
    person_id,
    drug_concept_id,
    drug_era_start_date,
    drug_era_end_date,
    drug_era_start_date::timestamp as drug_era_start_datetime, -- ELIMINAR LINEA
    drug_era_end_date::timestamp as drug_era_end_datetime,     -- ELIMINAR LINEA
    DRUG_EXPOSURE_COUNT,
    gap_days
from drug_era