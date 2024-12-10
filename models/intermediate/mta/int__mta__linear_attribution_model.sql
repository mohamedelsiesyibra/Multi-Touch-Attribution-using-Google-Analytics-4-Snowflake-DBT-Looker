
with assign_linear_attribution as (
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
        
        -- Assign attributed_points: 1 divided by the maximum number of steps in the journey
        1.0 / max_steps_in_journey as attributed_points,
        
        -- Calculate attributed_order_value: attributed_points multiplied by journey_total_order_value
        (1.0 / max_steps_in_journey) * journey_total_order_value as attributed_order_value
    from
        {{ ref('int__mta__sessions_journey_assignment') }}
),

assign_order_type_attribution as (
    select
        lca.*,
        
        -- Assign attribution points and revenue based on journey_number
        case 
            when journey_number = 1 then lca.attributed_points 
            else 0 
        end as first_order_attribution_points,
        
        case 
            when journey_number = 1 then lca.attributed_order_value 
            else 0 
        end as first_order_attributed_revenue,
        
        case 
            when journey_number > 1 then lca.attributed_points 
            else 0 
        end as repeated_order_attribution_points,
        
        case 
            when journey_number > 1 then lca.attributed_order_value 
            else 0 
        end as repeated_order_attributed_revenue,

        'Linear' as model
    from
        assign_linear_attribution lca
)

select * from assign_order_type_attribution