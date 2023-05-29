# Synthea

## Set up
[SyntheaTM](https://github.com/synthetichealth/synthea/) is a synthetic patient generator that models the medical history of synthetic patients. Basic setup:

- https://github.com/synthetichealth/synthea/wiki/Basic-Setup-and-Running

Run

```
java -jar synthea-with-dependencies.jar -c synthea.properties -p 1000
``` 
or using docker
```
docker run -v ${PWD}:/synthea -w  /synthea  openjdk:8u232-jre \
  java -jar synthea-with-dependencies.jar -c ./config -s 42 -p 100 "New York"
```

./config

```
exporter.csv.export = `true`
```

to generate synthetic data for 1000 patients or unzip provided [data.zip](https://github.com/alabarga/pybcn22-modern-data-stack/blob/main/synthea/data.zip)

After running Synthea, the CSV exporter will create these files:

| File | Description |
|------|-------------|
| [`allergies.csv`](#allergies) | Patient allergy data. |
| [`careplans.csv`](#careplans) | Patient care plan data, including goals. |
| [`conditions.csv`](#conditions) | Patient conditions or diagnoses. |
| [`devices.csv`](#devices) | Patient-affixed permanent and semi-permanent devices. |
| [`encounters.csv`](#encounters) | Patient encounter data. |
| [`imaging_studies.csv`](#imaging-studies) | Patient imaging metadata. |
| [`immunizations.csv`](#immunizations) | Patient immunization data. |
| [`medications.csv`](#medications) | Patient medication data. |
| [`observations.csv`](#observations) | Patient observations including vital signs and lab reports. |
| [`organizations.csv`](#organizations) | Provider organizations including hospitals. |
| [`patients.csv`](#patients) | Patient demographic data. |
| [`payer_transitions.csv`](#payer-transitions) | Payer Transition data (i.e. changes in health insurance). |
| [`payers.csv`](#payers) | Payer organization data. |
| [`procedures.csv`](#procedures) | Patient procedure data including surgeries. |
| [`providers.csv`](#providers) | Clinicians that provide patient care. |
| [`supplies.csv`](#supplies) | Supplies used in the provision of care. |


There exists a [R-based utility](https://github.com/OHDSI/ETL-Synthea) to load Synthea generated CSV data to OMOP CDM.

## Synthea ETL

This example is meant to show the process by which the synthetic data set [Synthea](https://synthetichealth.github.io/synthea/) can be converted to the [OMOP Common Data Model](https://github.com/OHDSI/CommonDataModel).

The below image illustrates how each Synthea table is mapped to its corresponding OMOP CDM table(s). Some of the native tables will be mapped to more than one CDM table and that is largely due to vocabulary and domain movement.

![](https://github.com/OHDSI/ETL-Synthea/raw/master/docs/syntheaETL_files/image1.png)


### **PERSON**
* Source table

| | Column Name | Data Type | Required? | Description |
|-|-------------|-----------|-----------|-------------|
| :key: | Id | UUID | ``true`` | Primary Key. Unique Identifier of the patient. |
| | BirthDate | Date (`YYYY-MM-DD`) | ``true`` | The date the patient was born. |
| | DeathDate | Date (`YYYY-MM-DD`) | ``false`` | The date the patient died. |
| | SSN | String | ``true`` | Patient Social Security identifier. |
| | Drivers | String | ``false`` | Patient Drivers License identifier. |
| | Passport | String | ``false`` | Patient Passport identifier. |
| | Prefix | String | ``false`` | Name prefix, such as `Mr.`, `Mrs.`, `Dr.`, etc. |
| | First | String | ``true`` | First name of the patient. |
| | Last | String | ``true`` | Last or surname of the patient. |
| | Suffix | String | ``false`` | Name suffix, such as `PhD`, `MD`, `JD`, etc. |
| | Maiden | String | ``false`` | Maiden name of the patient. |
| | Marital | String | ``false`` | Marital Status. `M` is married, `S` is single. Currently no support for divorce (`D`) or widowing (`W`) |
| | Race | String | ``true`` | Description of the patient's primary race. |
| | Ethnicity | String | ``true`` | Description of the patient's primary ethnicity. |
| | Gender | String | ``true`` | Gender. `M` is male, `F` is female. |
| | BirthPlace | String | ``true`` | Name of the town where the patient was born. |
| | Address | String | ``true`` | Patient's street address without commas or newlines. |
| | City | String | ``true`` | Patient's address city. |
| | County | String | ``false`` | Patient's address county. |
| | State | String | ``true`` | Patient's address state. |
| | Zip | String | ``false`` | Patient's zip code. |
| | Lat | Numeric | ``false`` | Latitude of Patient's address. |
| | Lon | Numeric | ``false`` | Longitude of Patient's address. |
| | Healthcare_Expenses | ``true`` | The total lifetime cost of healthcare to the patient (i.e. what the patient paid). |
| | Healthcare_Coverage | ``true`` | The total lifetime cost of healthcare services that were covered by Payers (i.e. what the insurance company paid). |

* Source table - OMOP CDM mapping

![](https://ohdsi.github.io/ETL-Synthea/syntheaETL_files/image11.png)

* Destination table

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| person_id |  |  |  |
| gender_concept_id | gender | When gender = ‘M’ then set gender_concept_id to 8507, when gender = ‘F’ then set to 8532 | Drop any rows with missing/unknown gender. |
| year_of_birth | birthdate | Take year from birthdate |  |
| month_of_birth | birthdate | Take month from birthdate |  |
| day_of_birth | birthdate | Take day from birthdate |  |
| birth_datetime | birthdate | With midnight as time 00:00:00 |  |
| death_datetime | deathdate | With midnight as time 00:00:00 |  |
| race_concept_id | race | When race = ‘WHITE’ then set as 8527, when race = ‘BLACK’ then set as 8516, when race = ‘ASIAN’ then set as 8515, otherwise set as 0 |  |
| ethnicity_concept_id | race  ethnicity | When race = ‘HISPANIC’, or when ethnicity in (‘CENTRAL_AMERICAN’, ‘DOMINICAN’, ‘MEXICAN’, ‘PUERTO_RICAN’, ‘SOUTH_AMERICAN’ ) then set as 38003563, otherwise set as 0  When race = ‘HISPANIC’, or when ethnicity in (‘CENTRAL_AMERICAN’, ‘DOMINICAN’, ‘MEXICAN’, ‘PUERTO_RICAN’, ‘SOUTH_AMERICAN’ ) then set as 38003563, otherwise set as 0 |  |
| location_id |  |  |  |
| provider_id |  |  |  |
| care_site_id |  |  |  |
| person_source_value | id |  |  |
| gender_source_value | gender |  |  |
| gender_source_concept_id |  |  |  |
| race_source_value | race |  |  |
| race_source_concept_id |  |  |  |
| ethnicity_source_value | ethnicity |  |  |
| ethnicity_source_concept_id |  |  |  |

* [Source table - OMOP CDM transformation](https://gitlab.com/iomed/data-engineering/synthea-etl-pipeline/-/blob/hospital_edge/synthea-etl/models/person.sql)

!!! note Note
    This a model created with [DBT](https://www.getdbt.com/). 
    For more information see [Transformation with Data Build Tool (DBT)](https://handbook.iomed.health/products/data-engineering/elt/transform/).

### **OBSERVATION_PERIOD**
* Source table (encounters.csv)

| | Column Name | Data Type | Required? | Description |
|-|-------------|-----------|-----------|-------------|
| :key: | Id |  UUID  | `true` | Primary Key. Unique Identifier of the encounter. |
| | Start | iso8601 UTC Date (`yyyy-MM-dd'T'HH:mm'Z'`) | `true` | The date and time the encounter started. |
| | Stop | iso8601 UTC Date (`yyyy-MM-dd'T'HH:mm'Z'`) | `false`  | The date and time the encounter concluded. |
| | Patient | UUID | `true` | Foreign key to the Patient. |
| | Organization | UUID | `true` | Foreign key to the Organization. |
| | Provider | UUID | `true` | Foreign key to the Provider. |
| | Payer | UUID | `true` | Foreign key to the Payer. |
| | EncounterClass | String | `true` | The class of the encounter, such as ambulatory, emergency, inpatient, wellness, or urgentcare |
| | Code | String | `true` | Encounter code from SNOMED-CT |
| | Description | String | `true` | Description of the type of encounter. |
| | Base_Encounter_Cost | Numeric | `true` | The base cost of the encounter, not including any line item costs related to medications, immunizations, procedures, or other services. |
| | Total_Claim_Cost | Numeric | `true` | The total cost of the encounter, including all line items. |
| | Payer_Coverage | Numeric | `true` | The amount of cost covered by the Payer. |
| | ReasonCode | String | `false`  | Diagnosis code from SNOMED-CT, only if this encounter targeted a specific condition. |
| | ReasonDescription | String | `false`  | Description of the reason code. |

* Source table - OMOP CDM mapping
![](https://ohdsi.github.io/ETL-Synthea/syntheaETL_files/image10.png)

*  Destination table

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| observation_period_id |  |  |  |
| person_id | patient | Map by mapping person.person_source_value to patient.  Find person.person_id by mapping encounters.patient to person.person_source_value. |  |
| observation_period_start_date | start | min(start) group by patient  Take the earliest START per patient |  |
| observation_period_end_date | stop | max(stop) group by patient  Take the latest STOP per patient |  |
| period_type_concept_id |  |  |Set as concept 44814724 (Period covering healthcare encounters) for all records  |

*  [Source table - OMOP CDM transformation](https://gitlab.com/iomed/data-engineering/synthea-etl-pipeline/-/blob/hospital_edge/synthea-etl/models/observation_period.sql)

### **VISIT_OCCURRENCE**

* Source table (encounters.csv)

| | Column Name | Data Type | Required? | Description |
|-|-------------|-----------|-----------|-------------|
| :key: | Id |  UUID  | `true` | Primary Key. Unique Identifier of the encounter. |
| | Start | iso8601 UTC Date (`yyyy-MM-dd'T'HH:mm'Z'`) | `true` | The date and time the encounter started. |
| | Stop | iso8601 UTC Date (`yyyy-MM-dd'T'HH:mm'Z'`) | `false`  | The date and time the encounter concluded. |
| | Patient | UUID | `true` | Foreign key to the Patient. |
| | Organization | UUID | `true` | Foreign key to the Organization. |
| | Provider | UUID | `true` | Foreign key to the Provider. |
| | Payer | UUID | `true` | Foreign key to the Payer. |
| | EncounterClass | String | `true` | The class of the encounter, such as ambulatory, emergency, inpatient, wellness, or urgentcare |
| | Code | String | `true` | Encounter code from SNOMED-CT |
| | Description | String | `true` | Description of the type of encounter. |
| | Base_Encounter_Cost | Numeric | `true` | The base cost of the encounter, not including any line item costs related to medications, immunizations, procedures, or other services. |
| | Total_Claim_Cost | Numeric | `true` | The total cost of the encounter, including all line items. |
| | Payer_Coverage | Numeric | `true` | The amount of cost covered by the Payer. |
| | ReasonCode | String | `false`  | Diagnosis code from SNOMED-CT, only if this encounter targeted a specific condition. |
| | ReasonDescription | String | `false`  | Description of the reason code. |


*  Source table - OMOP CDM mapping
![](https://ohdsi.github.io/ETL-Synthea/syntheaETL_files/image13.png)

*  Destination table

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| visit_occurrence_id |  |  |  |
| person_id | patient | Map by mapping person.person_source_value to patient.  Find person.person_id by mapping encounters.patient to person.person_source_value. |  |
| visit_concept_id | encounterclass | When encounterclass is 'emergency' or 'urgentcare' then set to 9203. When encounterclass is 'ambulatory', 'wellness', or 'outpatient' then set to 9202. When encounterclass is 'inpatient' then set to 9201. Otherwise set to 0. |  |
| visit_start_date | start |  |  |
| visit_start_datetime | start |  |  |
| visit_end_date | stop |  |  |
| visit_end_datetime | stop |  |  |
| visit_type_concept_id |  |  |Set all records as concept_id 44818517.  |
| provider_id |  |  |  |
| care_site_id |  |  |  |
| visit_source_value | encounterclass |  |  |
| visit_source_concept_id |  |  |  |
| admitted_from_concept_id |  |  |  |
| admitted_from_source_value |  |  |  |
| discharge_to_concept_id |  |  |  |
| discharge_to_source_value |  |  |  |

*  [Source table - OMOP CDM transformation](https://gitlab.com/iomed/data-engineering/synthea-etl-pipeline/-/blob/hospital_edge/synthea-etl/models/visit_occurrence.sql)

**Steps**

For encounterclass = ‘Inpatient’ (IP):

1. Sort data in ascending order by PATIENT, START, END.

2. Then by PERSON_ID, collapse lines of claim as long as the time between the END of one line and the START of the next is <=1 day.
3. Each consolidated inpatient claim is then considered as one inpatient visit, set

    1. MIN(START) as VISIT_START_DATE
    2. MAX(END) as VISIT_END_DATE
    3. ‘IP’ as PLACE_OF_SERVICE_SOURCE_VALUE
    4. See if any records with encounterclass ‘outpatient’ (OP), 'ambulatory' (OP), 'wellness' (OP), ‘emergency’ (ER) or 'urgentcare' (ER) occur during an identified ‘inpatient’ visit. These should be consolidated into the ‘inpatient’ visit, unless it is an ‘emergency’ or 'urgentcare' visit that starts and ends on the first day of the ‘inpatient’ visit.  Types of outpatient (OP) visits not collapsed: 
        1. If an OP starts before an IP but ends during an IP
        2. If an OP starts before and ends after an IP visit.  If an OP is collapsed into an IP and its VISIT_END_DATE is greater than the IP's VISIT_END_DATE it does not change the IP VISIT_END_DATE.

For claim type in ('emergency','urgentcare') (ER):

1. Sort data in ascending order by PATIENT, START, END.
2. Then by PERSON_ID, collapse all (ER) claims that start on the same day as one ER visit, then take START as VISIT_START_DATE, MAX (END) as VISIT_END_DATE, and ‘ER’ as PLACE_OF_SERVICE_SOURCE_VALUE.

For claim type in ('ambulatory', 'wellness', 'outpatient') (OP):

1. Sort data in ascending order by PATIENT, START, END.
2. Then by PERSON_ID take START as VISIT_START_DATE, MAX(END) as VISIT_END_DATE, and ‘OP’ as PLACE_OF_SERVICE_SOURCE_VALUE.


### **CONDITION_OCCURRENCE**
*  Source table (conditions.csv)

| | Column Name | Data Type | Required? | Description |
|-|-------------|-----------|-----------|-------------|
| | Start | Date (YYYY-MM-DD) | `true` | The date the condition was diagnosed.
| | Stop | Date (YYYY-MM-DD) | `false` | The date the condition resolved, if applicable.
| | Patient | UUID | `true` | Foreign key to the Patient.
| | Encounter | UUID | `true` | Foreign key to the Encounter when the condition was diagnosed.
| | Code | String | `true` | Diagnosis code from SNOMED-CT
| | Description | String | `true` | Description of the condition.

*  Source table - OMOP CDM mapping
![](https://ohdsi.github.io/ETL-Synthea/syntheaETL_files/image2.png)

*  Destination table

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| condition_occurrence_id |  | Autogenerate |  |
| person_id | patient | Map by mapping person.person_source_value to patient.  Find person.person_id by mapping encouters.patient to person.person_source_value. |  |
| condition_concept_id | code | Use the following SQL code to lookup target_concept_id in CTE_TARGET_VOCAB_MAP:    select ctvm.target_concept_id    from conditions c     join cte_target_vocab_map ctvm       on ctvm.source_code              = c.code     and ctvm.target_domain_id       = 'Condition'     and ctvm.target_vocabulary_id = 'SNOMED'     and ctvm.target_invalid_reason is NULL     and ctvm.target_standard_concept = 'S' |  |
| condition_start_date | start |  |  |
| condition_start_datetime | start |  |  |
| condition_end_date | stop |  |  |
| condition_end_datetime | stop |  |  |
| condition_type_concept_id |  | Set to 32020 (EHR Encounter Diagnosis) for all records |  |
| stop_reason |  |  |  |
| provider_id |  |  |  |
| visit_occurrence_id | encounter | Lookup visit_occurrence_id using encounter, joining to temp table defined in AllVisitTable.sql. |  |
| visit_detail_id |  |  |  |
| condition_source_value | code |  |  |
| condition_source_concept_id | code | Use the following SQL code to lookup the source_concept_id in CTE_SOURCE_VOCAB_MAP:     select csvm.source_concept_id     from cte_source_vocab_map csvm      join conditions c        on csvm.source_code                 = c.code      and csvm.source_vocabulary_id  = 'SNOMED' |  |
| condition_status_source_value |  |  |  |
| condition_status_concept_id |  |  |  |

*  [Source table - OMOP CDM transformation](https://gitlab.com/iomed/data-engineering/synthea-etl-pipeline/-/blob/hospital_edge/synthea-etl/models/condition_occurrence.sql)


### **DRUG_EXPOSURE**
* Source tables
medications.csv

| | Column Name | Data Type | Required? | Description |
|-|-------------|-----------|-----------|-------------|
| | Start | iso8601 UTC Date (`yyyy-MM-dd'T'HH:mm'Z'`) | `true` | The date and time the medication was prescribed.
| | Stop | iso8601 UTC Date (`yyyy-MM-dd'T'HH:mm'Z'`) | `false` | The date and time the prescription ended, if applicable.
| | Patient | UUID | `true` | Foreign key to the Patient.
| | Payer | UUID | `true` | Foreign key to the Payer.
| | Encounter | UUID | `true` | Foreign key to the Encounter where the medication was prescribed.
| | Code | String | `true` | Medication code from RxNorm.
| | Description | String | `true` | Description of the medication.
| | Base_Cost | Numeric | `true` | The line item cost of the medication.
| | Payer_Coverage | Numeric | `true` | The amount covered or reimbursed by the Payer.
| | Dispenses | Numeric | `true` | The number of times the prescription was filled.
| | TotalCost | Numeric | `true` | The total cost of the prescription, including all dispenses.
| | ReasonCode | String | `false` | Diagnosis code from SNOMED-CT specifying why this medication was prescribed.
| | ReasonDescription | String | `false` | Description of the reason code.

immunizations.csv

| | Column Name | Data Type | Required? | Description |
|-|-------------|-----------|-----------|-------------|
| | Date | iso8601 UTC Date (`yyyy-MM-dd'T'HH:mm'Z'`) | true | The date the immunization was administered.
| | Patient | UUID | ``true`` | Foreign key to the Patient.
| | Encounter | UUID | `true` | Foreign key to the Encounter where the immunization was administered.
| | Code | String | `true` | Immunization code from CVX.
| | Description | String | `true` | Description of the immunization.
| | Cost | Numeric | `true` | The line item cost of the immunization.

conditions.csv

| | Column Name | Data Type | Required? | Description |
|-|-------------|-----------|-----------|-------------|
| | Start | Date (YYYY-MM-DD) | `true` | The date the condition was diagnosed.
| | Stop | Date (YYYY-MM-DD) | `false` | The date the condition resolved, if applicable.
| | Patient | UUID | `true` | Foreign key to the Patient.
| | Encounter | UUID | `true` | Foreign key to the Encounter when the condition was diagnosed.
| | Code | String | `true` | Diagnosis code from SNOMED-CT
| | Description | String | `true` | Description of the condition.

*  Source table - OMOP CDM mapping
From medications.csv
![](https://ohdsi.github.io/ETL-Synthea/syntheaETL_files/image4.png)

From immunizations.csv
![](https://ohdsi.github.io/ETL-Synthea/syntheaETL_files/image5.png)

From conditions.csv
![](https://ohdsi.github.io/ETL-Synthea/syntheaETL_files/image3.png)

*  Destination table

From medications.csv

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| drug_exposure_id |  |  |  |
| person_id | patient | Map by mapping person.person_source_value to patient.  Find person.person_id by mapping  medications.patient to person.person_source_value. |  |
| drug_concept_id | code | Use code to lookup target_concept_id in CTE_TARGET_VOCAB_MAP:    select ctvm.target_concept_id    from medications m     join cte_target_vocab_map ctvm       on ctvm.source_code               = m.code     and ctvm.target_domain_id        = 'Drug'     and ctvm.target_vocabulary_id  = 'RxNorm'     and ctvm.target_standard_concept = 'S'     and ctvm.target_invalid_reason is NULL |  |
| drug_exposure_start_date | start |  |  |
| drug_exposure_start_datetime | start | Use 00:00:00 as the time. |  |
| drug_exposure_end_date | stop  start |  |  |
| drug_exposure_end_datetime | stop  start | Use 00:00:00 as the time. |  |
| verbatim_end_date | stop |  |  |
| drug_type_concept_id |  |  |Use the concept_id 581452 for all records from the immunizations and conditions tables and concept_id 38000177 for all records from the medications table.   |
| stop_reason |  |  |  |
| refills |  |  |  |
| quantity |  |  |  |
| days_supply | start  stop |  |  |
| sig |  |  |  |
| route_concept_id |  |  |  |
| lot_number |  |  |  |
| provider_id |  |  |  |
| visit_occurrence_id | encounter | Lookup visit_occurrence_id using encounter, joining to temp table defined in AllVisitTable.sql. |  |
| visit_detail_id |  |  |  |
| drug_source_value | code |  |  |
| drug_source_concept_id | code | Use code to lookup target_concept_id in CTE_SOURCE_VOCAB_MAP:    select csvm.source_concept_id    from medications m     join cte_source_vocab_map csvm      on cvm.source_code                = m.code      and cvm.source_vocabulary_id = 'RxNorm' |  |
| route_source_value |  |  |  |
| dose_unit_source_value |  |  |  |


From immunizations.csv

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| drug_exposure_id |  |  |  |
| person_id | patient | Map by mapping person.person_source_value to patient.  Find person.person_id by mapping immunizations.patient to person.person_source_value. |  |
| drug_concept_id | code | Use code to lookup target_concept_id in CTE_TARGET_VOCAB_MAP:    select ctvm.target_concept_id    from immunizations i     join cte_target_vocab_map ctvm       on ctvm.source_code               = i.code     and ctvm.target_domain_id        = 'Drug'     and ctvm.target_vocabulary_id = 'CVX'     and ctvm.target_standard_concept = 'S'     and ctvm.target_invalid_reason is NULL |  |
| drug_exposure_start_date | date |  |  |
| drug_exposure_start_datetime | date | Use 00:00:00 as the time. |  |
| drug_exposure_end_date | date |  |  |
| drug_exposure_end_datetime | date | Use 00:00:00 as the time. |  |
| verbatim_end_date | date |  |  |
| drug_type_concept_id |  |  | Use the concept_id 581452 for all records from the immunizations and conditions tables and concept_id 38000177 for all records from the medications table.  |
| stop_reason |  |  |  |
| refills |  |  |  |
| quantity |  |  |  |
| days_supply |  |  |  |
| sig |  |  |  |
| route_concept_id |  |  |  |
| lot_number |  |  |  |
| provider_id |  |  |  |
| visit_occurrence_id | encounter | Lookup visit_occurrence_id using encounter, joining to temp table defined in AllVisitTable.sql. |  |
| visit_detail_id |  |  |  |
| drug_source_value | code |  |  |
| drug_source_concept_id | code | Use code to lookup target_concept_id in CTE_SOURCE_VOCAB_MAP:    select csvm.source_concept_id    from immunizations i     join cte_source_vocab_map csvm      on csvm.source_code                = i.code     and csvm.source_vocabulary_id = 'CVX' |  |
| route_source_value |  |  |  |
| dose_unit_source_value |  |  |  |


From conditions.csv

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| drug_exposure_id |  |  |  |
| person_id | patient | Map by mapping person.person_source_value to patient.  Find person.person_id by mapping encouters.patient to person.person_source_value. |  |
| drug_concept_id | code | Use code to lookup target_concept_id in CTE_TARGET_VOCAB_MAP:    select ctvm.target_concept_id    from conditions c     join cte_target_vocab_map ctvm       on ctvm.source_code              = c.code     and ctvm.target_domain_id       = 'Drug'     and ctvm.target_vocabulary_id = 'RxNorm'     and ctvm.target_standard_concept = 'S'     and ctvm.target_invalid_reason is NULL |  |
| drug_exposure_start_date | start |  |  |
| drug_exposure_start_datetime | start |  |  |
| drug_exposure_end_date | stop |  |  |
| drug_exposure_end_datetime | stop |  |  |
| verbatim_end_date | stop |  |  |
| drug_type_concept_id |  |  | Use the concept_id 581452 for all records from the immunizations and conditions tables and concept_id 38000177 for all records from the medications table.  |
| stop_reason |  |  |  |
| refills |  |  |  |
| quantity |  |  |  |
| days_supply |  |  |  |
| sig |  |  |  |
| route_concept_id |  |  |  |
| lot_number |  |  |  |
| provider_id |  |  |  |
| visit_occurrence_id | encounter | Lookup visit_occurrence_id using encounter, joining to temp table defined in AllVisitTable.sql. |  |
| visit_detail_id |  |  |  |
| drug_source_value | code |  |  |
| drug_source_concept_id | code | Use code to lookup source_concept_id in CTE_SOURCE_VOCAB_MAP:     select csvm.source_concept_id     from cte_source_vocab_map csvm      join conditions c        on csvm.source_code                 = c.code      and csvm.source_vocabulary_id  = 'SNOMED' |  |
| route_source_value |  |  |  |
| dose_unit_source_value |  |  |  |

* [Source table - OMOP CDM transformation](https://gitlab.com/iomed/data-engineering/synthea-etl-pipeline/-/blob/hospital_edge/synthea-etl/models/drug_exposure.sql)


### **PROCEDURE_OCCURRENCE**
*  Source table (procedures.csv)

| | Column Name | Data Type | Required? | Description |
|-|-------------|-----------|-----------|-------------|
| | Start | iso8601 UTC Date (`yyyy-MM-dd'T'HH:mm'Z'`) | `true` | The date and time the procedure was performed.
| | Stop | iso8601 UTC Date (`yyyy-MM-dd'T'HH:mm'Z'`) | `false` | The date and time the procedure was completed, if applicable.
| | Patient | UUID | `true` | Foreign key to the Patient.
| | Encounter | UUID | `true` | Foreign key to the Encounter where the procedure was performed.
| | Code | String | `true` | Procedure code from SNOMED-CT
| | Description | String | `true` | Description of the procedure.
| | Base_Cost | Numeric | `true` | The line item cost of the procedure.
| | ReasonCode | String | `false` | Diagnosis code from SNOMED-CT specifying why this procedure was performed.
| | ReasonDescription | String | `false` | Description of the reason code.


*  Source table - OMOP CDM mapping
![](https://ohdsi.github.io/ETL-Synthea/syntheaETL_files/image12.png)

*  Destination table

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| procedure_occurrence_id |  |  |  |
| person_id | patient | Map by mapping person.person_source_value to patient.  Find person.person_id by mapping encouters.patient to person.person_source_value. |  |
| procedure_concept_id | code | Use code to lookup target_concept_id in CTE_TARGET_VOCAB_MAP:    select ctvm.target_concept_id    from procedures pr     join cte_target_vocab_map ctvm       on ctvm.source_code              = pr.code     and ctvm.target_domain_id       = 'Procedure'     and ctvm.target_vocabulary_id = 'SNOMED'     and ctvm.target_invalid_reason is NULL     and ctvm.target_standard_concept = 'S' |  |
| procedure_date | date |  |  |
| procedure_datetime | date | Use 00:00:00 as the time. |  |
| procedure_type_concept_id |  |  | Use concept_id 38000275 for all records. |
| modifier_concept_id |  |  |  |
| quantity |  |  |  |
| provider_id |  |  |  |
| visit_occurrence_id | encounter | Lookup visit_occurrence_id using encounter, joining to temp table defined in AllVisitTable.sql. |  |
| visit_detail_id |  |  |  |
| procedure_source_value | code |  |  |
| procedure_source_concept_id | code | Use code to lookup source_concept_id in CTE_SOURCE_VOCAB_MAP:     select csvm.source_concept_id     from cte_source_vocab_map csvm      join procedures pr        on csvm.source_code                 = pr.code      and csvm.source_vocabulary_id  = 'SNOMED' |  |
| modifier_source_value |  |  |  |


*  [Source table - OMOP CDM transformation](https://gitlab.com/iomed/data-engineering/synthea-etl-pipeline/-/blob/hospital_edge/synthea-etl/models/procedure_occurrence.sql)


### **OBSERVATION**

*  Source table

allergies.csv

| | Column Name | Data Type | Required? | Description |
|-|-------------|-----------|-----------|-------------|
| | Start | Date (YYYY-MM-DD) | `true` | The date the allergy was diagnosed.
| | Stop | Date (YYYY-MM-DD) | `false` | The date the allergy ended, if applicable.
| | Patient | UUID | `true` | Foreign key to the Patient.
| | Encounter | UUID | `true` | Foreign key to the Encounter when the allergy was diagnosed.
| | Code | String | `true` | Allergy code from SNOMED-CT
| | Description | String | `true` | Description of the Allergy

conditions.csv

| | Column Name | Data Type | Required? | Description |
|-|-------------|-----------|-----------|-------------|
| | Start | Date (YYYY-MM-DD) | `true` | The date the condition was diagnosed.
| | Stop | Date (YYYY-MM-DD) | `false` | The date the condition resolved, if applicable.
| | Patient | UUID | `true` | Foreign key to the Patient.
| | Encounter | UUID | `true` | Foreign key to the Encounter when the condition was diagnosed.
| | Code | String | `true` | Diagnosis code from SNOMED-CT
| | Description | String | `true` | Description of the condition.


*  Source table - OMOP CDM mapping
From allergies.csv
![](https://ohdsi.github.io/ETL-Synthea/syntheaETL_files/image8.png)

From conditions.csv
![](https://ohdsi.github.io/ETL-Synthea/syntheaETL_files/image9.png)


*  Destination table

From allergies.csv

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| observation_id |  |  |  |
| person_id | patient | Map by mapping person.person_source_value to patient.  Find person.person_id by mapping allergies.patient to person.person_source_value. |  |
| observation_concept_id | code | Use code to lookup target_concept_id in CTE_TARGET_VOCAB_MAP:    select ctvm.target_concept_id    from allergies a     join cte_target_vocab_map ctvm       on ctvm.source_code              = a.code     and ctvm.target_domain_id       = 'Observation'     and ctvm.target_vocabulary_id = 'SNOMED'     and ctvm.target_standard_concept = 'S'     and ctvm.target_invalid_reason is NULL |  |
| observation_date | start |  |  |
| observation_datetime | start | Use 00:00:00 as time. |  |
| observation_type_concept_id |  | Set as 38000280 for all records. |  |
| value_as_number |  |  |  |
| value_as_string |  |  |  |
| value_as_concept_id |  |  |  |
| qualifier_concept_id |  |  |  |
| unit_concept_id |  |  |  |
| provider_id |  |  |  |
| visit_occurrence_id | encounter | Lookup visit_occurrence_id using encounter, joining to temp table defined in AllVisitTable.sql. |  |
| visit_detail_id |  |  |  |
| observation_source_value | code |  |  |
| observation_source_concept_id | code | Use code to lookup source_concept_id in CTE_SOURCE_VOCAB_MAP:     select csvm.source_concept_id     from cte_source_vocab_map csvm      join allergies a        on csvm.source_code                 = a.code      and csvm.source_vocabulary_id  = 'SNOMED' |  |
| unit_source_value |  |  |  |
| qualifier_source_value |  |  |  |
| observation_event_id |  |  |  |
| obs_event_field_concept_id |  |  |  |
| value_as_datetime |  |  |  |

From conditions.csv

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| observation_id |  |  |  |
| person_id | patient | Map by mapping person.person_source_value to patient.  Find person.person_id by mapping encouters.patient to person.person_source_value. |  |
| observation_concept_id | code | Use code to lookup target_concept_id in CTE_TARGET_VOCAB_MAP:    select ctvm.target_concept_id    from conditions c     join cte_target_vocab_map ctvm       on ctvm.source_code              = c.code     and ctvm.target_domain_id       = 'Observation'     and ctvm.target_vocabulary_id = 'SNOMED' |  |
| observation_date | start |  |  |
| observation_datetime | start |  |  |
| observation_type_concept_id | | Set as 38000280 for all records. |  |
| value_as_number |  |  |  |
| value_as_string |  |  |  |
| value_as_concept_id |  |  |  |
| qualifier_concept_id |  |  |  |
| unit_concept_id |  |  |  |
| provider_id |  |  |  |
| visit_occurrence_id | encounter | Lookup visit_occurrence_id using encounter, joining to temp table defined in AllVisitTable.sql. |  |
| visit_detail_id |  |  |  |
| observation_source_value | code |  |  |
| observation_source_concept_id | code | Use code to lookup source_concept_id in CTE_SOURCE_VOCAB_MAP:     select csvm.source_concept_id     from cte_source_vocab_map csvm      join conditions c        on csvm.source_code                 = c.code      and csvm.source_vocabulary_id  = 'SNOMED' |  |
| unit_source_value |  |  |  |
| qualifier_source_value |  |  |  |
| observation_event_id |  |  |  |
| obs_event_field_concept_id |  |  |  |
| value_as_datetime |  |  |  |

* [Source table - OMOP CDM transformation](https://gitlab.com/iomed/data-engineering/synthea-etl-pipeline/-/blob/hospital_edge/synthea-etl/models/observation.sql)


### **MEASUREMENT**
* Source table

procedures.csv

| | Column Name | Data Type | Required? | Description |
|-|-------------|-----------|-----------|-------------|
| | Start | iso8601 UTC Date (`yyyy-MM-dd'T'HH:mm'Z'`) | `true` | The date and time the procedure was performed.
| | Stop | iso8601 UTC Date (`yyyy-MM-dd'T'HH:mm'Z'`) | `false` | The date and time the procedure was completed, if applicable.
| | Patient | UUID | `true` | Foreign key to the Patient.
| | Encounter | UUID | `true` | Foreign key to the Encounter where the procedure was performed.
| | Code | String | `true` | Procedure code from SNOMED-CT
| | Description | String | `true` | Description of the procedure.
| | Base_Cost | Numeric | `true` | The line item cost of the procedure.
| | ReasonCode | String | `false` | Diagnosis code from SNOMED-CT specifying why this procedure was performed.
| | ReasonDescription | String | `false` | Description of the reason code.

observations.csv

| | Column Name | Data Type | Required? | Description |
|-|-------------|-----------|-----------|-------------|
| | Date | iso8601 UTC Date (`yyyy-MM-dd'T'HH:mm'Z'`) | `true` | The date and time the observation was performed.
| | Patient | UUID | `true` | Foreign key to the Patient.
| | Encounter | UUID | `true` | Foreign key to the Encounter where the observation was performed.
| | Code | String | `true` | Observation or Lab code from LOINC
| | Description | String | `true` | Description of the observation or lab.
| | Value | String | `true` | The recorded value of the observation.
| | Units | String | `false` | The units of measure for the value.
| | Type | String | `true` | The datatype of Value: text or numeric

* Source table - OMOP CDM mapping
From procedures.csv
![](https://ohdsi.github.io/ETL-Synthea/syntheaETL_files/image6.png)

From observations.csv
![](https://ohdsi.github.io/ETL-Synthea/syntheaETL_files/image7.png)

* Destination table

From procedures.csv

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| measurement_id |  |  |  |
| person_id | patient | Lookup in the person table: map by mapping person.person_source_value to patient. |  |
| measurement_concept_id | code | Use code to lookup target_concept_id in CTE_TARGET_VOCAB_MAP:    select ctvm.target_concept_id    from procedures pr     join cte_target_vocab_map ctvm       on ctvm.source_code              = pr.code     and ctvm.target_domain_id       = 'Measurement'     and ctvm.target_vocabulary_id = 'SNOMED'     and ctvm.target_standard_concept = 'S'     and ctvm.target_invalid_reason is NULL |  |
| measurement_date | date |  |  |
| measurement_datetime | date | Use 00:00:00 as the time. |  |
| measurement_time | date |  |  |
| measurement_type_concept_id |  |  | Use concept_id 5001 for all records |
| operator_concept_id |  |  |  |
| value_as_number |  |  |  |
| value_as_concept_id |  |  |  |
| unit_concept_id |  |  |  |
| range_low |  |  |  |
| range_high |  |  |  |
| provider_id |  |  |  |
| visit_occurrence_id | encounter | Lookup visit_occurrence_id using encounter, joining to temp table defined in AllVisitTable.sql. |  |
| visit_detail_id |  |  |  |
| measurement_source_value | code |  |  |
| measurement_source_concept_id | code | Use code to lookup source_concept_id in CTE_SOURCE_VOCAB_MAP:     select csvm.source_concept_id     from cte_source_vocab_map csvm      join procedures pr        on csvm.source_code                 = pr.code        and csvm.source_vocabulary_id  = 'SNOMED' |  |
| unit_source_value |  |  |  |
| value_source_value |  |  |  |

From observations.csv

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| measurement_id |  |  |  |
| person_id | patient | Map by mapping person.person_source_value to patient.  Find person.person_id by mapping encouters.patient to person.person_source_value. |  |
| measurement_concept_id | code | Use code to lookup target_concept_id in CTE_TARGET_VOCAB_MAP:    select ctvm.target_concept_id    from observations o     join cte_target_vocab_map ctvm       on ctvm.source_code              = o.code     and ctvm.target_domain_id       = 'Measurement'     and ctvm.target_standard_concept = 'S'     and ctvm.target_invalid_reason is NULL |  |
| measurement_date | date |  |  |
| measurement_datetime | date | Use 00:00:00 as time. |  |
| measurement_time |  |  |  |
| measurement_type_concept_id |  |  | Use concept_id 5001 for all records |
| operator_concept_id |  |  |  |
| value_as_number | value |  |  |
| value_as_concept_id |  |  |  |
| unit_concept_id |  |  |  |
| range_low |  |  |  |
| range_high |  |  |  |
| provider_id |  |  |  |
| visit_occurrence_id | code | Lookup visit_occurrence_id using encounter, joining to temp table defined in AllVisitTable.sql. |  |
| visit_detail_id |  |  |  |
| measurement_source_value | code |  |  |
| measurement_source_concept_id | code | Use code to lookup source_concept_id in CTE_SOURCE_VOCAB_MAP:     select csvm.source_concept_id     from cte_source_vocab_map csvm      join observations o        on csvm.source_code                 = o.code      and csvm.source_vocabulary_id  = 'SNOMED' |  |
| unit_source_value | units |  |  |
| value_source_value | value |  |  |


* [Source table - OMOP CDM transformation](https://gitlab.com/iomed/data-engineering/synthea-etl-pipeline/-/blob/hospital_edge/synthea-etl/models/measurement.sql)
