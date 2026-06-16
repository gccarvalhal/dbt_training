with
    source as (
        select * from {{ source("jaffle_shop", "customers") }}
        ),
    transformed as (
        select
        source.id as customer_id,
        source.first_name as customer_first_name,
        source.last_name as customer_last_name,
        source.first_name || '' || source.last_name as full_name
        from source
        )

select * from transformed