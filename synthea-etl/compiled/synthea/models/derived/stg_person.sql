-- stg_person



with patients as (

    select * from "iomed"."raw"."patients"

),
person as (

select
    
    abs(('x' || substr(md5(id::text), 1, 16))::bit(64)::bigint)
 AS person_id,
    
(CASE WHEN gender = 'M' THEN 8507::int -- Male
      WHEN gender = 'F' THEN 8532::int -- Female
      WHEN gender is null THEN 0::int -- No data
      ELSE 8551::int -- Unknown
      END)
 AS gender_concept_id,
    date_part('year', birthdate::DATE)::INT AS year_of_birth,
    date_part('month', birthdate::DATE)::INT AS month_of_birth,
    date_part('day', birthdate::DATE)::INT AS day_of_birth,
    birthdate::TIMESTAMP AS birth_datetime,
    
(CASE WHEN race = 'white' THEN 8527::int -- White
      WHEN race = 'black' THEN 8516::int -- Black
      WHEN race = 'asian' THEN 8515::int -- Asian
      ELSE 0::int -- No data
      END)
  AS race_concept_id,
    
(CASE WHEN ethnicity = 'hispanic' THEN 38003563::int -- Hispanic or Latino
      ELSE 0::int
      END)
 AS ethnicity_concept_id,
    NULL::INT AS location_id,
    NULL::INT AS provider_id,
    NULL::INT AS care_site_id,
    id::VARCHAR(50) AS person_source_value,
    gender::VARCHAR(50) AS gender_source_value,
    0 AS gender_source_concept_id,
    race::VARCHAR(50) AS race_source_value,
    0 AS race_source_concept_id,
    ethnicity::VARCHAR(50) AS ethnicity_source_value,
    0 AS ethnicity_source_concept_id
from patients
where birthdate is not null -- Don't load patients who do not have birthdate and sex (change variable names if necessary)
      and gender is not null

)

select * from person