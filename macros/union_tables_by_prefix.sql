{% macro union_tables_by_prefix(database, schema, prefix) %}

    {% set tables = [] %}

    {% if execute %}
        {# Fetch matching tables from the information schema #}
        {% set query %}
            select table_name
            from {{ database }}.information_schema.tables
            where table_schema = upper('{{ schema }}')
              and table_name ilike '{{ prefix }}%'
        {% endset %}

        {% set results = run_query(query) %}
        {% set tables = results.columns[0].values %}
    {% endif %}

    {# If no tables found or during parse phase #}
    {% if tables | length > 0 %}
        {% for table in tables %}
            select * from "{{ database }}"."{{ schema }}"."{{ table }}"
            {% if not loop.last %} union all {% endif %}
        {% endfor %}
    {% else %}
        {# Fallback SQL for parse phase or when no matching tables are found #}
        select null as fallback_col where false
    {% endif %}

{% endmacro %}