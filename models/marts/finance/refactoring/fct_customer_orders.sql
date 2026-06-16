-- with statement
with
    -- logical ctes
    orders_payment_success as (
        select
            payments.order_id,
            max(payments.created) as payment_finalized_date,
            sum(payments.amount) / 100.0 as total_amount_paid
        from {{ ref("_stg_payments") }} as payments
        group by 1
    ),

    paid_orders as (
        select
            orders.order_id,
            orders.customer_id,
            orders.order_placed_at,
            orders.order_status,
            p.total_amount_paid,
            p.payment_finalized_date,
            customer.customer_first_name,
            customer.customer_last_name
        from {{ ref("_stg_orders") }} as orders
        left join orders_payment_success as p on orders.order_id = p.order_id
        left join {{ ref("_stg_customers") }} customer on orders.customer_id = customer.customer_id
    ),

    order_amount_paid as (
        select p.order_id, sum(t2.total_amount_paid) as clv_bad
        from paid_orders p
        left join
            paid_orders t2
            on p.customer_id = t2.customer_id
            and p.order_id >= t2.order_id
        group by 1
        order by p.order_id
    ),

    -- final cte
    final as (
        select
            p.*,
            row_number() over (order by p.order_id) as transaction_seq,
            row_number() over (
                partition by customer_id order by p.order_id
            ) as customer_sales_seq,
            case
                when
                    (
                        rank() over (
                            partition by p.customer_id
                            order by p.order_placed_at, p.order_id
                        )
                        = 1
                    )
                then 'new'
                else 'return'
            end as nvsr
        from paid_orders p
        left outer join order_amount_paid x on x.order_id = p.order_id
        order by order_id
    )

-- simple select statment
select *
from final
