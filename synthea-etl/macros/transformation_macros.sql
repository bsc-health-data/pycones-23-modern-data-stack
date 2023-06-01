--------------------------
--    ~~ GENERAL ~~     --
--------------------------



-- Macro to create a bigint type ID from a string in absolute value
{% macro create_id_from_str(text) %}
    abs(('x' || substr(md5({{ text }}), 1, 16))::bit(64)::bigint)
{% endmacro %}

-- Macro to create a bigint type ID from a string in absolute value
{% macro bigint_id_from_str(text) %}
    abs(('x' || substr(md5({{ text }}), 1, 16))::bit(64)::bigint)
{% endmacro %}

-- Macro to create a int type ID from a string in absolute value
{% macro int_id_from_str(text) %}
    abs(('x' || substr(md5({{ text }}),1,16))::bit(32)::int)
{% endmacro %}


-- OMOP TABLE: person
--- Macro to transform 'M' and 'F' sex values into their concept_id
{% macro gender_concept_id(sex) %}
(CASE WHEN {{ sex }} = 'M' THEN 8507::int -- Male
      WHEN {{ sex }} = 'F' THEN 8532::int -- Female
      WHEN {{ sex }} is null THEN 0::int -- No data
      ELSE 8551::int -- Unknown
      END)
{% endmacro %}


-- Macro to transform race values into their concept_id
{% macro race_concept_id(race) %}
(CASE WHEN {{ race }} = 'white' THEN 8527::int -- White
      WHEN {{ race }} = 'black' THEN 8516::int -- Black
      WHEN {{ race }} = 'asian' THEN 8515::int -- Asian
      ELSE 0::int -- No data
      END)
{% endmacro %}

-- Macro to transform ethnicity values into their concept_id
{% macro ethnicity_concept_id(race) %}
(CASE WHEN {{ race }} = 'hispanic' THEN 38003563::int -- Hispanic or Latino
      ELSE 0::int
      END)
{% endmacro %}


-- OMOP TABLE: visit_occurrence
-- Macro to transform encounter class values into their concept_id
{% macro visit_concept_id(encounter_class) %}
(CASE {{ encounter_class }}
        WHEN 'ambulatory' THEN 9202 -- Outpatient Visit
        WHEN 'emergency' THEN 9203 -- Emergency Room Visit
        WHEN 'inpatient' THEN 9201 -- Inpatient Visit
        WHEN 'wellness' THEN 9202 -- Outpatient Visit
        WHEN 'urgentcare' THEN 9203 -- Emergency Room Visit
        WHEN 'outpatient' THEN 9202 -- Outpatient Visit
        ELSE 0
        END)
{% endmacro %}
