-- depends_on: "iomed"."cdm"."visit_occurrence"

-- OMOP table: observation
-- More information: https://ohdsi.github.io/ETL-Synthea/Observation.html



with observation as (

    select * from "iomed"."cdm_dbt"."stg_observation"

)
select
    observation_id,
    person_id,
    observation_concept_id,
    observation_date,
    observation_datetime,
    observation_datetime as value_as_datetime, -- ELIMINAR Linea
    observation_type_concept_id,
    value_as_number,
    value_as_string,
    value_as_concept_id,
    qualifier_concept_id,
    unit_concept_id,
    provider_id,
    visit_occurrence_id,
    visit_detail_id,
    observation_source_value,
    observation_source_concept_id,
    unit_source_value,
    qualifier_source_value,
    value_source_value,
    observation_event_id,
    obs_event_field_concept_id
from observation