with session_aggregates as (
    select
        session_user_id,
        session_id,
        user_pseudo_id,
        min(event_ts) as event_ts,

        -- earliest non-null utm_channel
        min_by(
            case when utm_channel is not null then utm_channel end,
            case when utm_channel is not null then event_ts end
        ) as utm_channel,

        -- earliest non-null utm_medium
        min_by(
            case when utm_medium is not null then utm_medium end,
            case when utm_medium is not null then event_ts end
        ) as utm_medium,

        -- earliest non-null utm_source
        min_by(
            case when utm_source is not null then utm_source end,
            case when utm_source is not null then event_ts end
        ) as utm_source,

        -- earliest non-null country
        min_by(
            case when country is not null then country end,
            case when country is not null then event_ts end
        ) as country,

        -- earliest non-null region
        min_by(
            case when region is not null then region end,
            case when region is not null then event_ts end
        ) as region,

        -- sum of order_value for all purchase events in the session
        sum(
            case 
                when event_type = 'purchase' and order_value is not null 
                then order_value 
                else 0 
            end
        ) as total_order_value,

        -- flag indicating if a purchase occurred in the session
        max(
            case 
                when event_type = 'purchase' and order_value is not null 
                then 1 
                else 0 
            end
        ) = 1 as has_purchase

    
    from {{ ref('stg__google_analytics_4__events') }}
    group by session_user_id, session_id, user_pseudo_id
)

select * from session_aggregates