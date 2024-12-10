
with journey_assignment as (
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
        total_order_value,
        has_purchase,

        -- calculate cumulative number of purchases before the current session
        coalesce(
            sum(
                case 
                    when has_purchase = true 
                    then 1 
                    else 0 
                end
            ) over (
                partition by user_pseudo_id
                order by event_ts
                rows between unbounded preceding and 1 preceding
            ),
            0
        ) + 1 as journey_number
    from {{ ref('int__mta__sessions_paid_users') }}
),

journey_steps as (
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
        total_order_value,
        has_purchase,
        journey_number,

        -- assign step_number within each journey
        row_number() over (
            partition by user_pseudo_id, journey_number
            order by event_ts
        ) as step_number
    from journey_assignment 
),

journey_metrics as (
    select
        js.session_user_id,
        js.session_id,
        js.user_pseudo_id,
        js.event_ts,
        js.utm_channel,
        js.utm_medium,
        js.utm_source,
        js.country,
        js.region,
        js.total_order_value,
        js.has_purchase,
        js.journey_number,
        js.step_number,

        -- Calculate total order value for the journey
        sum(coalesce(js.total_order_value, 0)) over (
            partition by js.user_pseudo_id, js.journey_number
        ) as journey_total_order_value,
        MAX(STEP_NUMBER) OVER (
            PARTITION BY USER_PSEUDO_ID, JOURNEY_NUMBER
        ) AS max_steps_in_journey,
                COUNT(*) OVER (
            PARTITION BY USER_PSEUDO_ID, JOURNEY_NUMBER
        ) AS total_steps_in_journey,
        SUM(STEP_NUMBER) OVER (
            PARTITION BY USER_PSEUDO_ID, JOURNEY_NUMBER
        ) AS sum_of_step_numbers
    from journey_steps js
    qualify (
        sum(coalesce(js.total_order_value, 0)) over (
            partition by js.user_pseudo_id, js.journey_number
        ) > 0
    )
)

select * from journey_metrics
