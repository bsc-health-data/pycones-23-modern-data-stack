-- stg_observation_period



WITH person AS (

    SELECT * FROM "iomed"."cdm"."person"

),
encounters AS (

    SELECT * FROM "iomed"."raw"."encounters"

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
    
    abs(('x' || substr(md5(CONCAT('obs_period_', person_id::text)), 1, 16))::bit(64)::bigint)
 AS observation_period_id,
    person_id AS person_id,
    start_date AS observation_period_start_date,
	end_date AS observation_period_end_date,
	44814724::INT AS period_type_concept_id -- Period covering healthcare encounters
FROM observation_period