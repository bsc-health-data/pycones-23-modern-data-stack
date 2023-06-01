-- stg_location



select
   0::bigint as location_id, -- NOT NULL
   null::varchar(50) as address_1,
   null::varchar(50) as address_2,
   null::varchar(50) as city,
   null::varchar(2) as state,
   null::varchar(9) as zip,
   null::varchar(20) as county,
   'hospital_edge'::text as location_source_value,
   0::int as country_concept_id,
   'Spain'::varchar(100) as country_source_value,
   null::numeric as latitude,
   null::numeric as longitude