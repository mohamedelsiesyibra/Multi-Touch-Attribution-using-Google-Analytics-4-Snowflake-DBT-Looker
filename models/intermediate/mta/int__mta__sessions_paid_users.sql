with purchasing_users as (
    select distinct
        user_pseudo_id
    from {{ ref('int__mta__sessions_aggregation') }}
    where has_purchase = true
),

filtered_purchasing_sessions as (
    select
        sa.session_user_id,
        sa.session_id,
        sa.user_pseudo_id,
        sa.event_ts,
        sa.utm_channel,
        sa.utm_medium,
        sa.utm_source,
        sa.country,
        sa.region,
        sa.total_order_value,
        sa.has_purchase
    from {{ ref('int__mta__sessions_aggregation') }} sa
    inner join purchasing_users pu
        on sa.user_pseudo_id = pu.user_pseudo_id
)

select * from filtered_purchasing_sessions