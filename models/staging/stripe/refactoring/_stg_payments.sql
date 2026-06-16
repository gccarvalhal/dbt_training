with 
    source as (
        select * from {{ source("stripe", "payment") }}
        ),
    transformed as (
        select
            orderid as order_id,
            paymentmethod as payment_method,
            status as payment_status,
            amount,
            created,
            _batched_at
        from source
        where status <> 'fail'

    )
select * from transformed