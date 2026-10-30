DROP TABLE IF EXISTS tr_dim_agents;

CREATE TABLE tr_dim_agents AS
WITH ranked_agents AS (
    SELECT 
        agent_id,
        employee_code,
        agent_name,
        vendor_id,
        team,
        status,
        joined_at,
        updated_at,
        ROW_NUMBER() OVER (PARTITION BY agent_id ORDER BY updated_at DESC) AS rank_num
    FROM dim_agents
)
SELECT 
    agent_id,
    employee_code AS latest_employee_code,
    agent_name,
    vendor_id,
    team,
    status AS current_status,
    joined_at,
    updated_at AS last_updated_at
FROM ranked_agents
WHERE rank_num = 1;


DROP TABLE IF EXISTS tr_dim_borrowers;

CREATE TABLE tr_dim_borrowers AS
WITH ranked_borrowers AS (
    SELECT 
        borrower_id,
        name,
        phone,
        email,
        city,
        state,
        created_at,
        updated_at,
        ROW_NUMBER() OVER (PARTITION BY borrower_id ORDER BY updated_at DESC) AS rank_num
    FROM dim_borrowers
)
SELECT 
    borrower_id,
    name,
    phone,
    email,
    city,
    state,
    created_at,
    updated_at
FROM ranked_borrowers
WHERE rank_num = 1;


DROP TABLE IF EXISTS tr_fct_calls;

CREATE TABLE tr_fct_calls AS
SELECT 
    call_id,
    account_id,
    borrower_id,
    event_at AS event_at_raw,
    timezone AS raw_timezone,
    
    CASE 
        WHEN timezone = 'UTC' THEN DATETIME(event_at, '+330 minutes')
        WHEN timezone = 'Asia/Dubai' THEN DATETIME(event_at, '+90 minutes')
        ELSE event_at
    END AS event_at_ist,
    DATE(CASE 
        WHEN timezone = 'UTC' THEN DATETIME(event_at, '+330 minutes')
        WHEN timezone = 'Asia/Dubai' THEN DATETIME(event_at, '+90 minutes')
        ELSE event_at
    END) AS call_date_ist,
    STRFTIME('%H', CASE 
        WHEN timezone = 'UTC' THEN DATETIME(event_at, '+330 minutes')
        WHEN timezone = 'Asia/Dubai' THEN DATETIME(event_at, '+90 minutes')
        ELSE event_at
    END) AS call_hour_ist,
    agent_id,
    campaign_id,
    direction,
    vendor_id,
    call_status,
    duration_sec,
    disposition_code,
    CASE 
        WHEN disposition_code = 'PTP' THEN 'PROMISE_TO_PAY'
        ELSE disposition_code 
    END AS standard_disposition,
    CASE 
        WHEN disposition_code IN ('PROMISE_TO_PAY', 'PTP', 'PTP_BROKEN', 'CALLBACK', 'DISPUTE', 'REFUSED', 'PAID') THEN 1 
        ELSE 0 
    END AS is_rpc
FROM fct_calls;


DROP TABLE IF EXISTS tr_payment_attribution_7d;

CREATE TABLE tr_payment_attribution_7d AS
WITH clean_success_payments AS (
    SELECT 
        payment_id,
        account_id,
        amount,
        event_at AS payment_at
    FROM fct_payments
    WHERE payment_status = 'SUCCESS'
),
unified_interactions AS (
    SELECT account_id, event_at_ist AS interaction_at, call_id AS interaction_id, 'VOICE' AS channel, standard_disposition AS disposition FROM tr_fct_calls
    UNION ALL
    SELECT account_id, event_at, whatsapp_event_id AS interaction_id, 'WHATSAPP' AS channel, event_type AS disposition FROM fct_whatsapp_events
    UNION ALL
    SELECT account_id, event_at, sms_event_id AS interaction_id, 'SMS' AS channel, event_type AS disposition FROM fct_sms_events
    UNION ALL
    SELECT account_id, event_at, visit_id AS interaction_id, 'FIELD' AS channel, outcome AS disposition FROM fct_field_visits
),
eligible_matches AS (
    SELECT 
        p.payment_id,
        p.account_id,
        p.amount,
        p.payment_at,
        i.channel,
        i.interaction_id,
        i.disposition,
        (JULIANDAY(p.payment_at) - JULIANDAY(i.interaction_at)) AS days_prior,
        ROW_NUMBER() OVER (
            PARTITION BY p.payment_id 
            ORDER BY (JULIANDAY(p.payment_at) - JULIANDAY(i.interaction_at)) ASC
        ) AS rank_touch
    FROM clean_success_payments p
    INNER JOIN unified_interactions i
        ON p.account_id = i.account_id
       AND JULIANDAY(p.payment_at) >= JULIANDAY(i.interaction_at)
       AND (JULIANDAY(p.payment_at) - JULIANDAY(i.interaction_at)) <= 7.0
)
SELECT 
    p.payment_id,
    p.account_id,
    p.amount,
    p.payment_at,
    COALESCE(m.channel, 'UNATTRIBUTED') AS attributed_channel,
    m.interaction_id,
    COALESCE(m.disposition, 'NO_TOUCH_IN_7D') AS touch_disposition,
    ROUND(m.days_prior, 2) AS days_prior,
    CASE 
        WHEN m.channel IS NOT NULL THEN 'ATTRIBUTED'
        ELSE 'UNATTRIBUTED'
    END AS attribution_status
FROM clean_success_payments p
LEFT JOIN eligible_matches m
    ON p.payment_id = m.payment_id AND m.rank_touch = 1;
