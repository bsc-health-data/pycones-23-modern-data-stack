-- stg_observation_period

{{ config(
   materialized='table',
   enabled=true
)
}}

WITH person AS (

    SELECT * FROM {{ ref('person') }}

),
encounters AS (

    SELECT * FROM {{ source('raw', 'encounters') }}

),
observation_period AS (

    SELECT p.person_id,
           MIN(e.start) AS start_date,
	       MAX(e.stop) AS end_date
    FROM person p
    JOIN encounters e ON p.person_source_value = e.patient
    GROUP BY p.person_id
)

SELECT
    {{ create_id_from_str("CONCAT('obs_period_', person_id::text)") }} AS observation_period_id,
    person_id AS person_id,
    start_date AS observation_period_start_date,
	end_date AS observation_period_end_date,
	44814724::INT AS period_type_concept_id -- Period covering healthcare encounters
FROM observation_period
