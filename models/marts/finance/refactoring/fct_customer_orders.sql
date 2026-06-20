-- with statement
with

    paid_orders as (
        select * from {{ ref('int_orders') }}
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
