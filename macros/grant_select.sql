{% macro grant_select(schema= target.schema, role= target.role) %}
    {% set sql %}
        grant usage on schema {{ schema }} to role {{ role }};
        grant select on all tables in schema {{ schema }} to role {{ role }};
        grant select on all views in schema {{ schema }} to role {{ role }};
    {% endset %}
    {% if execute %}
        {% do log("Granting select on schema " ~ schema ~ " to role " ~ role, info=True) %}
        {% do run_query(sql) %}
        {{log('Privs granted', info=True)}}
    {% endif %}
{% endmacro %}