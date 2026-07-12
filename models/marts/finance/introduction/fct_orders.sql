{{
    config(
        materialized='incremental',
        incremental_strategy = 'insert_overwrite',
        unique_key = 'order_id',
        cluster_by = ['date_day'],
{#         used for big query #}
        partition_by = {
            'field' = 'order_date',
            'date_type' = 'date',
            'granularity' = 'day'
        }
    )
}}
with orders as (
    select * from {{ ref('stg_jaffle_shop_orders') }}
),
payments as (
    select * from {{ ref('stg_stripe__payments') }}
),
order_payments as (
    select
    order_id,
    sum(case when payment_status = 'success' then payment_amount end) as amount
    from payments
    group by 1
),
final as (
    select
        orders.order_id,
        orders.customer_id,
        orders.order_date,
        coalesce(order_payments.amount, 0) as amount
        from orders
        left join order_payments using (order_id)
)
select * from final
{% if is_incremental() %}
    -- this filter will only be applied on an incremental run
    where order_date > (select max(order_date) from {{ this }}) 
{% endif %}