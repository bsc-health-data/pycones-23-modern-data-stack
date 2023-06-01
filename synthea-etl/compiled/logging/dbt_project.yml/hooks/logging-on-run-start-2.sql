
    

    insert into "iomed"."cdm_meta"."dbt_audit_log" (
        event_name,
        event_timestamp,
        event_schema,
        event_model,
        event_user,
        event_target,
        event_is_full_refresh,
        invocation_id
    )

    values (
        'run started',
        
    (current_timestamp at time zone 'utc')::
    timestamp

,
        '',
        '',
        'postgres',
        'synthea',
        FALSE,
        'f50e6a13-2918-4d67-8867-1378cf104964'
    );

    commit;


