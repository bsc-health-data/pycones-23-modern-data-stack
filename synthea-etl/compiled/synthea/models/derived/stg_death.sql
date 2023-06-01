-- stg_death



with patients as (

    select * from "iomed"."raw"."patients"

),
person as (

    select * from "iomed"."cdm"."person"

),
death as (
    select
        p.person_id::bigint as person_id, -- NOT NULL
        deathdate::date as death_date, -- NOT NULL
        deathdate::timestamp as death_datetime,
        0::integer as death_type_concept_id, -- NOT NULL
        null::integer as cause_concept_id,
        null::text as cause_source_value,
        null::integer as cause_source_concept_id
    from patients pa
    inner join person p
        on pa.id = p.person_source_value -- Change variable name if necessary
    where deathdate is not null
)

select * from death