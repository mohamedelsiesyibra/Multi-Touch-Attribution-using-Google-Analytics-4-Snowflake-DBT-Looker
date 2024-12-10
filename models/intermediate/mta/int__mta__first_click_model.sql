
with assign_first_click as (
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
        
        -- Assign attributed_points: 1 for the first step in the journey, else 0
        case 
            when step_number = 1 then 1 
            else 0 
        end as attributed_points,
        
        -- Calculate attributed_order_value: journey_total_order_value for the first step, else 0
        case 
            when step_number = 1 then journey_total_order_value 
            else 0 
        end as attributed_order_value
    from
        {{ ref('int__mta__sessions_journey_assignment') }}
),

assign_order_type_attribution as (
    select
        ap.*,
        
        -- Assign attribution points and revenue based on journey_number
        case 
            when journey_number = 1 then ap.attributed_points 
            else 0 
        end as first_order_attribution_points,
        
        case 
            when journey_number = 1 then ap.attributed_order_value 
            else 0 
        end as first_order_attributed_revenue,
        
        case 
            when journey_number > 1 then ap.attributed_points 
            else 0 
        end as repeated_order_attribution_points,
        
        case 
            when journey_number > 1 then ap.attributed_order_value 
            else 0 
        end as repeated_order_attributed_revenue,

        'First Click' as model
    from
        assign_first_click ap
)

select * from assign_order_type_attribution


