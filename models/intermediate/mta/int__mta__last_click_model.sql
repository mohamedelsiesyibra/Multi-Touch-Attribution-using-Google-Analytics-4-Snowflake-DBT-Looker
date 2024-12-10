
with assign_last_click as (
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
        
        -- Assign attributed_points: 1 for the last step_number, else 0
        case 
            when step_number = max(step_number) over (
                partition by user_pseudo_id, journey_number
            ) then 1 
            else 0 
        end as attributed_points,
        
        -- Calculate attributed_order_value: attributed_points * journey_total_order_value
        case 
            when step_number = max(step_number) over (
                partition by user_pseudo_id, journey_number
            ) then journey_total_order_value 
            else 0 
        end as attributed_order_value
    from
        {{ ref('int__mta__sessions_journey_assignment') }}
),

assign_order_type_attribution as (
    select
        lc.*,
        
        -- Assign attribution points and revenue based on journey_number
        case 
            when journey_number = 1 then lc.attributed_points 
            else 0 
        end as first_order_attribution_points,
        
        case 
            when journey_number = 1 then lc.attributed_order_value 
            else 0 
        end as first_order_attributed_revenue,
        
        case 
            when journey_number > 1 then lc.attributed_points 
            else 0 
        end as repeated_order_attribution_points,
        
        case 
            when journey_number > 1 then lc.attributed_order_value 
            else 0 
        end as repeated_order_attributed_revenue,

        'Last Click' as model
    from
        assign_last_click lc
)

select * from assign_order_type_attribution