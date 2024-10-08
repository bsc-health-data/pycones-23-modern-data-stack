{% macro default__create_unlogged_table_as(temporary, relation, sql) -%}
  create unlogged {% if temporary: -%}temporary{%- endif %} table
    {{ relation.include(database=(not temporary), schema=(not temporary)) }}
  as (
    {{ sql }}
  );
{% endmacro %}

{% macro create_unlogged_table_as(temporary, relation, sql) -%}
  {{ adapter_macro('create_table_as', temporary, relation, sql) }}
{%- endmacro %}

{% materialization table_unlogged, default %}
  {%- set identifier = model['alias'] -%}
  {%- set tmp_identifier = model['name'] + '__dbt_tmp' -%}
  {%- set backup_identifier = model['name'] + '__dbt_backup' -%}

  {%- set old_relation = adapter.get_relation(database=database, schema=schema, identifier=identifier) -%}
  {%- set target_relation = api.Relation.create(identifier=identifier,
                                                schema=schema,
                                                database=database,
                                                type='table') -%}
  {%- set intermediate_relation = api.Relation.create(identifier=tmp_identifier,
                                                      schema=schema,
                                                      database=database,
                                                      type='table') -%}

  /*
      See ../view/view.sql for more information about this relation.
  */
  {%- set backup_relation_type = 'table' if old_relation is none else old_relation.type -%}
  {%- set backup_relation = api.Relation.create(identifier=backup_identifier,
                                                schema=schema,
                                                database=database,
                                                type=backup_relation_type) -%}

  {%- set exists_as_table = (old_relation is not none and old_relation.is_table) -%}
  {%- set exists_as_view = (old_relation is not none and old_relation.is_view) -%}


  -- drop the temp relations if they exists for some reason
  {{ adapter.drop_relation(intermediate_relation) }}
  {{ adapter.drop_relation(backup_relation) }}

  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- `BEGIN` happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  -- build model
  {% call statement('main') -%}
    {{ create_unlogged_table_as(False, intermediate_relation, sql) }}
  {%- endcall %}

  -- set logged
  {{ dbt__set_logged(intermediate_relation) }}

  -- cleanup
  {% if old_relation is not none %}
      {{ adapter.rename_relation(target_relation, backup_relation) }}
  {% endif %}

  {{ adapter.rename_relation(intermediate_relation, target_relation) }}

  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {{ adapter.commit() }}

  -- finally, drop the existing/backup relation after the commit
  {{ drop_relation_if_exists(backup_relation) }}

  {{ run_hooks(post_hooks, inside_transaction=False) }}
{% endmaterialization %}
