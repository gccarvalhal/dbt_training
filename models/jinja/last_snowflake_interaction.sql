{% set database = target.database %}
{% set schema = target.schema %}
{% set days = 30 %}

select
    table_type,
    table_catalog,
    table_schema,
    table_name,
    last_altered,
    case when table_type = 'VIEW' then table_type else 'TABLE' end as drop_type,
    'DROP '
    || (case when table_type = 'VIEW' then table_type else 'TABLE' end)
    || ' {{ database | upper }}.'
    || table_schema
    || '.'
    || table_name
    || ';' as drop_query
from {{ database }}.information_schema.tables
where table_schema = upper('{{ schema }}') 
  and last_altered <= current_date - {{ days }}
order by last_altered desc