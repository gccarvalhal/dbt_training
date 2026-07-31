{% macro cents_to_dollars(columns_name, decimals=2) -%} ROUND({{columns_name}} / 100,{{decimals}}) {%- endmacro %}
