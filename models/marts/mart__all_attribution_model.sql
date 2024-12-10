with first_click as (
    select
        session_user_id,
        session_id,
        user_pseudo_id,
        event_ts,
        utm_channel,
        utm_medium,
        utm_source,
        country,
        region,
        attributed_points as orders,
        attributed_order_value as order_revenue,
        first_order_attribution_points as first_order,
        first_order_attributed_revenue as first_order_revenue,
        repeated_order_attribution_points as repeated_order,
        repeated_order_attributed_revenue as repeated_order_revenue,
        model
    from {{ ref('int__mta__first_click_model') }}
),

last_click as (
    select
        session_user_id,
        session_id,
        user_pseudo_id,
        event_ts,
        utm_channel,
        utm_medium,
        utm_source,
        country,
        region,
        attributed_points as orders,
        attributed_order_value as order_revenue,
        first_order_attribution_points as first_order,
        first_order_attributed_revenue as first_order_revenue,
        repeated_order_attribution_points as repeated_order,
        repeated_order_attributed_revenue as repeated_order_revenue,
        model
    from {{ ref('int__mta__last_click_model') }}
),

linear_attribution as (
    select
        session_user_id,
        session_id,
        user_pseudo_id,
        event_ts,
        utm_channel,
        utm_medium,
        utm_source,
        country,
        region,
        attributed_points as orders,
        attributed_order_value as order_revenue,
        first_order_attribution_points as first_order,
        first_order_attributed_revenue as first_order_revenue,
        repeated_order_attribution_points as repeated_order,
        repeated_order_attributed_revenue as repeated_order_revenue,
        model
    from {{ ref('int__mta__linear_attribution_model') }}
),

position_based_attribution as (
    select
        session_user_id,
        session_id,
        user_pseudo_id,
        event_ts,
        utm_channel,
        utm_medium,
        utm_source,
        country,
        region,
        attributed_points as orders,
        attributed_order_value as order_revenue,
        first_order_attribution_points as first_order,
        first_order_attributed_revenue as first_order_revenue,
        repeated_order_attribution_points as repeated_order,
        repeated_order_attributed_revenue as repeated_order_revenue,
        model
    from {{ ref('int__mta__position_based_attribution_model') }}
),

time_decay_attribution as (
    select
        session_user_id,
        session_id,
        user_pseudo_id,
        event_ts,
        utm_channel,
        utm_medium,
        utm_source,
        country,
        region,
        attributed_points as orders,
        attributed_order_value as order_revenue,
        first_order_attribution_points as first_order,
        first_order_attributed_revenue as first_order_revenue,
        repeated_order_attribution_points as repeated_order,
        repeated_order_attributed_revenue as repeated_order_revenue,
        model
    from {{ ref('int__mta__time_decay_attribution_model') }}
)

select * from first_click
union all
select * from last_click
union all
select * from linear_attribution
union all
select * from position_based_attribution
union all
select * from time_decay_attribution