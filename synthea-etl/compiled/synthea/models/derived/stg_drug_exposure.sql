-- stg_drug_exposure



WITH person AS (

    SELECT * FROM "iomed"."cdm"."person"

),
source_to_standard_vocab_map AS (

    SELECT * FROM "iomed"."cdm_dbt"."source_to_standard_vocab_map"
    WHERE source_vocabulary_id in ('RxNorm', 'CVX') -- RxNorm: drugs from medications, CVX: drugs from immunizations
        AND source_domain_id = 'Drug'
        AND target_domain_id = 'Drug'
        AND target_standard_concept = 'S'
        AND target_invalid_reason IS NULL

),
final_visit_ids AS (

    SELECT * FROM "iomed"."cdm_dbt"."final_visit_ids"

),
source_to_source_vocab_map AS (

    SELECT * FROM "iomed"."cdm_dbt"."source_to_source_vocab_map"
    WHERE source_vocabulary_id in ('RxNorm', 'CVX')  -- RxNorm: drugs from medications, CVX: drugs from immunizations

),
medications_num AS (

    SELECT *,
           row_number() over (partition by encounter order by encounter) as n_medications -- To get a PK for drug_exposure (drug_exposure_id)
    FROM "iomed"."raw"."medications"

),
immunizations_num AS (

    SELECT *,
           row_number() over (partition by encounter order by encounter) as n_immunizations -- To get a PK for drug_exposure (drug_exposure_id)
    FROM "iomed"."raw"."immunizations"

),
medications_mapped as (

    select m.*, srctostdvm.target_concept_id, srctostdvm.source_concept_id, srctostdvm.target_domain_id
    from medications_num m
    left join source_to_standard_vocab_map srctostdvm
        on srctostdvm.source_code = m.code
    left join source_to_source_vocab_map srctosrcvm
        on srctosrcvm.source_code = m.code
),
immunizations_mapped as (

    select i.*, srctostdvm.target_concept_id, srctostdvm.source_concept_id, srctostdvm.target_domain_id
    from immunizations_num i
    left join source_to_standard_vocab_map srctostdvm
        on srctostdvm.source_code = i.code
    left join source_to_source_vocab_map srctosrcvm
        on srctosrcvm.source_code = i.code
)

SELECT
    
    abs(('x' || substr(md5(concat('medications_drug_', encounter::text, '_', target_concept_id::text)), 1, 16))::bit(64)::bigint)
 AS drug_exposure_id,
    p.person_id AS person_id,
    case when m.target_concept_id is NULL then 0 else m.target_concept_id end AS drug_concept_id,
    m.start AS drug_exposure_start_date,
    m.start AS drug_exposure_start_datetime,
    coalesce(m.stop,m.start) AS drug_exposure_end_date,
    coalesce(m.stop,m.start) AS drug_exposure_end_datetime,
    m.stop AS verbatim_end_date,
    38000177 AS drug_type_concept_id, -- Prescription written
    null::varchar AS stop_reason,
    0 AS refills,
    0 AS quantity,
    coalesce(EXTRACT(DAY FROM (m.stop-m.start))::int,0) AS days_supply,
    null::varchar AS sig,
    0 AS route_concept_id,
    0 AS lot_number,
    NULL::bigint AS provider_id,
    fv.visit_occurrence_id_new AS visit_occurrence_id,
    null::bigint AS visit_detail_id,
    m.code AS drug_source_value,
    case when m.target_concept_id is NULL then 0 else m.target_concept_id end AS drug_source_concept_id,
    null::varchar AS route_source_value,
    null::varchar AS dose_unit_source_value
from medications_mapped m
join final_visit_ids fv
    on fv.encounter_id = m.encounter
join person p
  on p.person_source_value    = m.patient

union all

select
    
    abs(('x' || substr(md5(concat('immunizations_drug_', encounter::text, '_', n_immunizations::text)), 1, 16))::bit(64)::bigint)
 AS drug_exposure_id,
    p.person_id AS person_id,
    case when i.target_concept_id is NULL then 0 else i.target_concept_id end AS drug_concept_id,
    i.date::date AS drug_exposure_start_date,
    i.date::timestamp AS drug_exposure_start_datetime,
    i.date::date AS drug_exposure_end_date,
    i.date::timestamp AS drug_exposure_end_datetime,
    i.date::date AS verbatim_end_date,
    581452 AS drug_type_concept_id, -- Dispensed in Outpatient office
    null::varchar AS stop_reason,
    0 AS refills,
    0 AS quantity,
    0 AS days_supply,
    null::varchar AS sig,
    0 AS route_concept_id,
    0 AS lot_number,
    NULL::bigint AS provider_id,
    fv.visit_occurrence_id_new AS visit_occurrence_id,
    null::bigint AS visit_detail_id,
    i.code AS drug_source_value,
    case when i.target_concept_id is NULL then 0 else i.target_concept_id end AS drug_source_concept_id,
    null::varchar AS route_source_value,
    null::varchar AS dose_unit_source_value
from immunizations_mapped i
join final_visit_ids fv
    on fv.encounter_id = i.encounter
join person p
  on p.person_source_value = i.patient