DROP TABLE IF EXISTS stg_payments_dedup;

CREATE TABLE stg_payments_dedup AS
WITH ranked_payments AS (
    SELECT 
        payment_id,
        account_id,
        borrower_id,
        event_at,
        payment_reference,
        amount,
        payment_status,
        payment_method,
        provider_id,
        
        ROW_NUMBER() OVER (
            PARTITION BY payment_id 
            ORDER BY CASE WHEN payment_reference IS NOT NULL AND payment_reference != '' THEN 0 ELSE 1 END,
                     event_at ASC
        ) AS rank_num
    FROM fct_payments
)
SELECT 
    payment_id,
    account_id,
    borrower_id,
    event_at,
    payment_reference,
    amount,
    payment_status,
    payment_method,
    provider_id,
    DATE(event_at) AS event_date,
    SUBSTR(event_at, 1, 7) AS event_month,
    CASE WHEN payment_status = 'SUCCESS' THEN 1 ELSE 0 END AS is_success
FROM ranked_payments
WHERE rank_num = 1;


DROP TABLE IF EXISTS stg_calls_dedup;

CREATE TABLE stg_calls_dedup AS
WITH ranked_calls AS (
    SELECT 
        call_id,
        account_id,
        borrower_id,
        event_at,
        agent_id,
        campaign_id,
        direction,
        vendor_id,
        call_status,
        duration_sec,
        timezone,
        ROW_NUMBER() OVER (PARTITION BY call_id ORDER BY event_at ASC) AS rank_num
    FROM fct_calls
)
SELECT 
    call_id,
    account_id,
    borrower_id,
    event_at,
    agent_id,
    campaign_id,
    direction,
    vendor_id,
    call_status,
    duration_sec,
    timezone,
    CASE WHEN call_status = 'ANSWERED' THEN 1 ELSE 0 END AS is_answered
FROM ranked_calls
WHERE rank_num = 1;


DROP TABLE IF EXISTS stg_whatsapp_dedup;

CREATE TABLE stg_whatsapp_dedup AS
WITH ranked_wa AS (
    SELECT 
        whatsapp_event_id,
        account_id,
        borrower_id,
        event_at,
        message_id,
        event_type,
        template_code,
        provider_id,
        ROW_NUMBER() OVER (PARTITION BY whatsapp_event_id ORDER BY event_at ASC) AS rank_num
    FROM fct_whatsapp_events
)
SELECT 
    whatsapp_event_id,
    account_id,
    borrower_id,
    event_at,
    message_id,
    event_type,
    template_code,
    provider_id,
    DATE(event_at) AS event_date
FROM ranked_wa
WHERE rank_num = 1;


SELECT 
    'Payments' AS stream,
    COUNT(*) AS golden_record_count,
    SUM(CASE WHEN is_success = 1 THEN 1 ELSE 0 END) AS success_count,
    ROUND(SUM(CASE WHEN is_success = 1 THEN amount ELSE 0 END) / 10000000.0, 4) AS clean_success_recovery_cr
FROM stg_payments_dedup
UNION ALL
SELECT 
    'Calls' AS stream,
    COUNT(*) AS golden_record_count,
    SUM(is_answered) AS success_count,
    NULL AS clean_success_recovery_cr
FROM stg_calls_dedup
UNION ALL
SELECT 
    'WhatsApp' AS stream,
    COUNT(*) AS golden_record_count,
    SUM(CASE WHEN event_type = 'DELIVERED' THEN 1 ELSE 0 END) AS success_count,
    NULL AS clean_success_recovery_cr
FROM stg_whatsapp_dedup;
