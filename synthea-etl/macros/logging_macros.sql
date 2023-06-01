-- Macro to check the last time a row was inserted into a table
{% macro last_inserted(table) %}

(select max(iomed_row_insert_datetime) from  {{table}}  )

{% endmacro %}

-- Macro to check the last time the ETL was run
{% macro last_run() %}

    COALESCE((select max(event_timestamp)
             from {{ logging.get_audit_relation() }}), '1900-01-01'::timestamp)

{% endmacro %}

-- Macro to check the last time a model was run
{% macro last_dbt_run(table_schema, table_name) %}

    COALESCE(
        (select max(event_timestamp)
        from {{ logging.get_audit_relation() }}
        where event_schema = '{{ table_schema }}'
        and event_model =  '{{ table_name }}'
        and event_name = 'model deployment completed'),
        '1900-01-01'::timestamp)

{% endmacro %}
