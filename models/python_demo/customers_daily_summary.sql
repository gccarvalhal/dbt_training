select 
customer_id,
valid_order_date,
{{ dbt_utils.generate_surrogate_key(['customer_id', 'valid_order_date']) }} as primary_key,
count(*) as quantity
from {{ ref('fct_customer_orders') }}
group by 1,2