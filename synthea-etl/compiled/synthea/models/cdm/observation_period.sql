-- OMOP table: observation_period
-- More information: https://ohdsi.github.io/ETL-Synthea/Observation_period.html



with observation_period as (

    select * from "iomed"."cdm_dbt"."stg_observation_period"

)
select
    observation_period_id,
    person_id,
    observation_period_start_date,
    observation_period_end_date,
    period_type_concept_id
from observation_period