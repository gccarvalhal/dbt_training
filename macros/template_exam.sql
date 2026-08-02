{% macro template_example(args) %}
    {% set query %}
        select true as boolean
    {% endset %}

    -- Set a fallback default for parse time when execute is False
    {% set results = false %}

    {% if execute %}
        {% set results_table = run_query(query) %}
        {% set results = results_table.columns[0].values[0] %}
        {{ log('SQL results: ' ~ results, info=True) }}
    {% endif %}

    -- Keep the return SQL outside the execute block so dbt can parse it
    select {{ results }} as is_real
    from a_real_table
{% endmacro %}