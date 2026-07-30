{% for j in range(26)%}
    select {{j}} as number {% if not loop.last %} union all {% endif %}
{% endfor %}