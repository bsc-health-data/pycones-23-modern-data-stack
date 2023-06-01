-- stg_provider




    select
        0::bigint as provider_id, -- NOT NULL (change variable name if necessary)
        null::varchar(255) as provider_name,
        null::varchar(20) as npi,
        null::varchar(20) as dea,
        0::int as specialty_concept_id, -- NOT NULL
        null::bigint as care_site_id,
        null::int as year_of_birth,
        0::int as gender_concept_id, -- NOT NULL
        null::text as provider_source_value,
        null::text as specialty_source_value,
        0::int as specialty_source_concept_id, -- NOT NULL
        null::text as gender_source_value,
        0::int as gender_source_concept_id -- NOT NULL