{% macro load_synthea() %}
{% set create_sql %}

  drop schema if exists iomed_raw cascade;

  create schema iomed_raw;

  create table iomed_raw.allergies
  (
      start       date,
      stop        date,
      patient     text,
      encounter   text,
      code        varchar,
      description text
  );

  create index idx_allergies_code
      on iomed_raw.allergies (code);

  create table iomed_raw.conditions
  (
      start       date,
      stop        date,
      patient     text,
      encounter   text,
      code        varchar,
      description text
  );

  create index idx_conditions_code
      on iomed_raw.conditions (code);

  create table iomed_raw.immunizations
  (
      date        timestamp,
      patient     text,
      encounter   text,
      code        varchar,
      description text,
      base_cost   double precision
  );

  create index idx_immunizations_code
      on iomed_raw.immunizations (code);

  create table iomed_raw.encounters
  (
      id                  text,
      start               timestamp,
      stop                timestamp,
      patient             text,
      organization        text,
      provider            text,
      payer               text,
      encounterclass      text,
      code                bigint,
      description         text,
      base_encounter_cost double precision,
      total_claim_cost    double precision,
      payer_coverage      double precision,
      reasoncode          bigint,
      reasondescription   text
  );

  create table iomed_raw.medications
  (
      start             timestamp,
      stop              timestamp,
      patient           text,
      payer             text,
      encounter         text,
      code              varchar,
      description       text,
      base_cost         double precision,
      payer_coverage    double precision,
      dispenses         integer,
      totalcost         double precision,
      reasoncode        bigint,
      reasondescription text
  );

  create index idx_medications_code
      on iomed_raw.medications (code);

  create table iomed_raw.observations
  (
      date        timestamp,
      patient     text,
      encounter   text,
      code        varchar,
      description text,
      value       text,
      units       text,
      type        text
  );

  create table iomed_raw.procedures
  (
      start             timestamp,
      stop              timestamp,
      patient           text,
      encounter         text,
      code              varchar,
      description       text,
      base_cost         double precision,
      reasoncode        bigint,
      reasondescription text
  );

  create index idx_procedures_code
      on iomed_raw.procedures (code);

  create table iomed_raw.patients
  (
      id                  text,
      birthdate           date,
      deathdate           date,
      ssn                 text,
      drivers             text,
      passport            text,
      prefix              text,
      first               text,
      last                text,
      suffix              varchar,
      maiden              text,
      marital             text,
      race                text,
      ethnicity           text,
      gender              text,
      birthplace          text,
      address             text,
      city                text,
      state               text,
      county              text,
      zip                 integer,
      lat                 double precision,
      lon                 double precision,
      healthcare_expenses double precision,
      healthcare_coverage double precision
  );
{% endset %}

{% set copy_sql %}

 copy iomed_raw.observations from program 'curl -H "Host: storage.googleapis.com" https://storage.googleapis.com/iomed-public-data/synthea/100000_patients/observations.csv.gz -k -s | zcat' with csv header delimiter E',';
 copy iomed_raw.patients from program 'curl -H "Host: storage.googleapis.com" https://storage.googleapis.com/iomed-public-data/synthea/100000_patients/patients.csv.gz -k -s | zcat' with csv header delimiter E',';
 copy iomed_raw.conditions from program 'curl -H "Host: storage.googleapis.com" https://storage.googleapis.com/iomed-public-data/synthea/100000_patients/conditions.csv.gz -k -s | zcat' with csv header delimiter E',';
 copy iomed_raw.procedures from program 'curl -H "Host: storage.googleapis.com" https://storage.googleapis.com/iomed-public-data/synthea/100000_patients/procedures.csv.gz -k -s | zcat' with csv header delimiter E',';
 copy iomed_raw.allergies from program 'curl -H "Host: storage.googleapis.com" https://storage.googleapis.com/iomed-public-data/synthea/100000_patients/allergies.csv.gz -k -s | zcat' with csv header delimiter E',';
 copy iomed_raw.encounters from program 'curl -H "Host: storage.googleapis.com" https://storage.googleapis.com/iomed-public-data/synthea/100000_patients/encounters.csv.gz -k -s | zcat' with csv header delimiter E',';
 copy iomed_raw.immunizations from program 'curl -H "Host: storage.googleapis.com" https://storage.googleapis.com/iomed-public-data/synthea/100000_patients/immunizations.csv.gz -k -s | zcat' with csv header delimiter E',';
 copy iomed_raw.medications from program 'curl -H "Host: storage.googleapis.com" https://storage.googleapis.com/iomed-public-data/synthea/100000_patients/medications.csv.gz -k -s | zcat' with csv header delimiter E',';

{% endset %}

{% do run_query(create_sql) %}
{% do log("Synthea tables created", info=True) %}

{% do run_query(copy_sql) %}
{% do log("Synthea data copied", info=True) %}
{% endmacro %}
