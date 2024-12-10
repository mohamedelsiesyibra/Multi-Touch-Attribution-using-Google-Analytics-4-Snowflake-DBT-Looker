
with assign_time_decay_attribution as (
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
        step_number,
        journey_total_order_value,
        sum_of_step_numbers,
        
        -- Assign attributed_points based on the Time-Decay attribution model:
        -- - Attribution points increase with the step number.
        -- - Each step's points are calculated as STEP_NUMBER divided by the sum of all step numbers in the journey.
        round(step_number::float / sum_of_step_numbers, 4) as attributed_points,

        -- Calculate attributed_order_value based on the assigned attributed_points.
        -- This represents the portion of the journey's total order value attributed to each step.
        round((step_number::float / sum_of_step_numbers) * journey_total_order_value, 2) as attributed_order_value
    from
        {{ ref('int__mta__sessions_journey_assignment') }}
),

assign_order_type_attribution as (
    select
        tda.*,

        -- Assign attribution points and revenue based on journey_number
        case 
            when journey_number = 1 then tda.attributed_points 
            else 0 
        end as first_order_attribution_points,

        case 
            when journey_number = 1 then tda.attributed_order_value 
            else 0 
        end as first_order_attributed_revenue,

        case 
            when journey_number > 1 then tda.attributed_points 
            else 0 
        end as repeated_order_attribution_points,

        case 
            when journey_number > 1 then tda.attributed_order_value 
            else 0 
        end as repeated_order_attributed_revenue,

        'Time Decay' as model
    from
        assign_time_decay_attribution tda
)

select * from assign_order_type_attribution