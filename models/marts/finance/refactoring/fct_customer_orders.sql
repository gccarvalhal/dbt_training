-- with statement
with

    paid_orders as (select * from {{ ref("int_orders") }}),

    customers as (select * from {{ ref("_stg_customers") }}),

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

    version_status as (
        select
            po.order_id,
            case
                when
                    (
                        rank() over (
                            partition by po.customer_id
                            order by po.order_placed_at, po.order_id
                        )
                        = 1
                    )
                then 'new'
                else 'return'
            end as nvsr
        from paid_orders po
    ),
    sales_transaction_sequence as (
        select
            paid_orders.order_id,
            row_number() over (
                order by paid_orders.valid_order_date, paid_orders.order_id
            ) as transaction_seq
        from paid_orders
    ),
    customer_sales_sequence as (
        select
            paid_orders.order_id,
            row_number() over (
                partition by paid_orders.customer_id
                order by paid_orders.valid_order_date, paid_orders.order_id
            ) as customer_sales_seq
        from paid_orders
    ),
customer_lifetime_value as (
        select
            paid_orders.order_id,
            sum(paid_orders.total_amount_paid) over (
                partition by paid_orders.customer_id
                order by paid_orders.valid_order_date, paid_orders.order_id
            ) as customer_lifetime_value  -- <--- REMOVA A VÍRGULA AQUI
        from paid_orders
    ),
    first_day_of_sale as (
        select
            paid_orders.order_id,
            first_value(paid_orders.valid_order_date) over (
                partition by paid_orders.customer_id
                order by paid_orders.valid_order_date, paid_orders.order_id
            ) as fdos
        from paid_orders
        left join customers on paid_orders.customer_id = customers.customer_id
    ),
    -- final cte
    final as (
        select
            p.*,
            sales_transaction_sequence.transaction_seq,
            customer_sales_sequence.customer_sales_seq,
            version_status.nvsr,
            first_day_of_sale.fdos
        from paid_orders p
        left join
            sales_transaction_sequence
            on sales_transaction_sequence.order_id = p.order_id
        left join
            customer_sales_sequence on customer_sales_sequence.order_id = p.order_id
        left join
            customer_lifetime_value on customer_lifetime_value.order_id = p.order_id
        left join first_day_of_sale on first_day_of_sale.order_id = p.order_id
        left join version_status on version_status.order_id = p.order_id
        left outer join order_amount_paid x on x.order_id = p.order_id
        order by order_id
    )

-- simple select statment
select *
from final
