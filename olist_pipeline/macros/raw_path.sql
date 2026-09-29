{#- Quoted path to a raw Olist CSV. Relative paths resolve against the directory dbt runs from
    (the repo root); override with the OLIST_RAW_DIR env var. -#}
{% macro raw_path(file) -%}
'{{ env_var("OLIST_RAW_DIR", "data/raw") }}/{{ file }}'
{%- endmacro %}
