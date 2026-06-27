with

    source as (select * from {{ ref("stg_stripe__payments") }}),
    aggregated as (
        select sum(payment_amount) as total_revenue
        from source
        where payment_status = 'success'
    )
select *
from aggregated
