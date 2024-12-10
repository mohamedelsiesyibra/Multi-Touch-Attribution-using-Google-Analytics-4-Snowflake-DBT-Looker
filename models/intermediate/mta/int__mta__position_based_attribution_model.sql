
with assign_position_based_attribution as (
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
        max_steps_in_journey,
        
        -- Assign attributed_points based on the Position-Based attribution model:
        -- - 100% attribution if the journey has only one step.
        -- - 50% attribution if the journey has two steps.
        -- - 40% attribution to the first and last steps if the journey has more than two steps.
        -- - Remaining 20% attribution is evenly distributed among intermediary steps.
        case 
            when max_steps_in_journey = 1 then 1.00
            when max_steps_in_journey = 2 then 0.50
            when step_number = 1 then 0.40
            when step_number = max_steps_in_journey then 0.40
            else 0.20 / (max_steps_in_journey - 2)
        end as attributed_points,

        -- Calculate attributed_order_value based on the assigned attributed_points.
        -- This represents the portion of the journey's total order value attributed to each step.
        case 
            when max_steps_in_journey = 1 then journey_total_order_value
            when max_steps_in_journey = 2 then 0.50 * journey_total_order_value
            when step_number = 1 then 0.40 * journey_total_order_value
            when step_number = max_steps_in_journey then 0.40 * journey_total_order_value
            else (0.20 / (max_steps_in_journey - 2)) * journey_total_order_value
        end as attributed_order_value
    from
        {{ ref('int__mta__sessions_journey_assignment') }}
),

assign_order_type_attribution as (
    select
        pba.*,
        
        -- Assign attribution points and revenue based on journey_number
        case 
            when journey_number = 1 then pba.attributed_points 
            else 0 
        end as first_order_attribution_points,
        
        case 
            when journey_number = 1 then pba.attributed_order_value 
            else 0 
        end as first_order_attributed_revenue,
        
        case 
            when journey_number > 1 then pba.attributed_points 
            else 0 
        end as repeated_order_attribution_points,
        
        case 
            when journey_number > 1 then pba.attributed_order_value 
            else 0 
        end as repeated_order_attributed_revenue,

        'Position Based [40-20-40]' as model
    from
        assign_position_based_attribution pba
)

select * from assign_order_type_attribution