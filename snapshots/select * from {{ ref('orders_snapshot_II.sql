select * from {{ ref('orders_snapshot_II') }}
where user_id = 66