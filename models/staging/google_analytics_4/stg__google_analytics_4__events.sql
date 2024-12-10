with events as (
    select
        concat(session_id, '-', user_pseudo_id) as session_user_id,
        session_id,
        user_pseudo_id,
        event_ts,
        utm_channel,
        utm_medium,
        utm_source,
        event_type,
        order_value,
        country,
        region
    from {{ source('pc_dbt_db', 'ga4_events') }}
)

select * from events