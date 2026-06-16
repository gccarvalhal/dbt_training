with
    source as  (
        select * from {{ source("jaffle_shop", "orders") }}
    ),

    transformed as (
        select
         source.id as order_id,
         source.user_id as customer_id,
         source.order_date as order_placed_at,
         source.status as order_status,
        case 
            when status not in ('returned','return_pending') 
        then source.order_date 
        end as valid_order_date
        from source
    )

select * from transformed