with events as (

    select * from "iomed"."meta"."stg_dbt_audit_log"

),

aggregated as (

    select

        md5(cast(coalesce(cast(event_model as 
    varchar
), '') || '-' || coalesce(cast(invocation_id as 
    varchar
), '') as 
    varchar
)) as model_deployment_id,

        invocation_id,
        event_model as model,
        event_schema as schema,
        event_user as user,
        event_target as target,
        event_is_full_refresh as is_full_refresh,

        min(case
            when event_name = 'model deployment started' then event_timestamp
        end) as deployment_started_at,

        min(case
            when event_name = 'model deployment completed' then event_timestamp
        end) as deployment_completed_at

    from events

    where event_name ilike '%model%'

    group by 1,2,3,4,5,6,7

)

select * from aggregated