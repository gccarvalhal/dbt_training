{% macro template_example() %}
    {% set query %}
        select true as boolean
    {% endset %}

    {# 1. Create a namespace with a default value for parse time #}
    {% set ns = namespace(results=false) %}

    {% if execute %}
        {% set results_table = run_query(query) %}
        {# 2. Access the 1st row of the 1st column directly #}
        {% set ns.results = results_table.columns[0][0] %}
        {{ log('SQL results: ' ~ ns.results, info=True) }}
    {% endif %}

    {# 3. Access the namespace property outside the block #}
    select {{ ns.results }} as is_real

{% endmacro %}