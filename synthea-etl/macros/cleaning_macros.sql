--------------------------
--   ~~ DATA TYPES   ~~ --
--------------------------
-- Macro to check if a column has integer-type values and if not, set it as NULL
{% macro str_to_int(num) %}
(CASE WHEN {{ num }} ~ '^[0-9]+$' THEN {{ num }}::int
      ELSE null::int
      END)
{% endmacro %}

-- Macro to check if a column has float-type values and if not, set it as NULL
{% macro str_to_dec(num) %}
(CASE WHEN {{ num }} ~ '^-?[0-9]\d*(\.\d+)?$' THEN {{ num }}::decimal
      ELSE null::int
      END)
{% endmacro %}


--------------------------
-- ~~ DATES AND TIME ~~ --
--------------------------

-- Macro to transform string-type date ('YYYYMMMDD') to date data-type
{% macro str_to_date(fecha) %}
(CASE WHEN {{ fecha }} ~ '^(19|20)\d\d(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])$'
      THEN to_date({{ fecha }},'YYYYMMDD')
      ELSE null::date
      END)
{% endmacro %}

-- Macro to transform string-type date and time columns to timestamp format
{% macro str_to_timestamp(fecha, hora) %}
(CASE WHEN {{ fecha }} ~ '^(19|20)\d\d(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])$'
      AND  {{ hora }} ~ '^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$'
      THEN to_timestamp({{ fecha }} || ' ' || {{ hora }}, 'YYYYMMDD HH24:MI')
      WHEN {{ fecha }} ~ '^(19|20)\d\d(0[1-9]|1[012])(0[1-9]|[12][0-9]|3[01])$'
      THEN to_timestamp({{ fecha }} || ' 00:00', 'YYYYMMDD HH24:MI')
      ELSE null::timestamp
      END)
{% endmacro %}


--------------------------
--     ~~ OTHERS ~~     --
--------------------------

-- Macro to transform not-null empty values (e.g. '') to NULL
{% macro null_conversion(column_name, null_value)  %}
(CASE WHEN {{ column_name }} = {{ null_value }} THEN NULL
      ELSE {{ column_name }}
      END)
{% endmacro %}

-- Macro to clean age column from strings (e.g. 80 años, 79E...)
{% macro clean_age(age) %}
(CASE WHEN {{ age }} != '' THEN substring({{age}} from '(\d*).*')::int
      ELSE null::int
      END)
{% endmacro %}
