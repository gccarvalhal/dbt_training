with 

orders as (
    select * from {{ ref('_stg_orders') }}
),

payments as (
    select * from {{ ref('_stg_payments') }}
),

customers as (
    select * from {{ ref("_stg_customers") }}
),

completed_payments as (
    select
        order_id,
        max(created) as payment_finalized_date,
        sum(amount) as total_amount_paid
    from payments
    group by 1
),

paid_orders as (
    select
    orders.order_id,
    orders.customer_id,
    orders.valid_order_date,
    orders.order_status,
    completed_payments.total_amount_paid,
    completed_payments.payment_finalized_date
    from orders
    left join completed_payments on orders.order_id = completed_payments.order_id
    left join customers on customers.customer_id = orders.customer_id
)

select * from paid_orders