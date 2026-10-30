SELECT 
    'A. Duplicate Payments' AS audit_area,
    COUNT(*) AS total_raw_records,
    COUNT(DISTINCT payment_id) AS unique_payment_ids,
    COUNT(*) - COUNT(DISTINCT payment_id) AS duplicate_rows_identified,
    SUM(CASE WHEN payment_status = 'SUCCESS' THEN amount ELSE 0 END) AS raw_succ_amount,
    ROUND((SELECT SUM(amount) FROM fct_payments WHERE payment_status = 'SUCCESS') / 10000000.0, 4) AS clean_succ_amount_cr
FROM (
    
    SELECT payment_id, amount, payment_status FROM fct_payments
);


DROP VIEW IF EXISTS v_forensic_targeting_timing;

CREATE VIEW v_forensic_targeting_timing AS
WITH matched_targeting AS (
    SELECT 
        p.payment_id,
        p.account_id,
        DATE(p.event_at) AS pay_date,
        t.target_date,
        (JULIANDAY(p.event_at) - JULIANDAY(t.target_date)) AS day_diff
    FROM fct_payments p
    INNER JOIN fct_daily_targeting t ON p.account_id = t.account_id
    WHERE p.payment_status = 'SUCCESS'
)
SELECT 
    CASE 
        WHEN day_diff < 0 THEN '1. Target occurred AFTER payment (Invalid Post-Payment Match)'
        WHEN day_diff = 0 THEN '2. Target occurred on SAME DAY as payment'
        WHEN day_diff BETWEEN 0.0001 AND 7.0 THEN '3. Target occurred 1 to 7 days prior (Valid Window)'
        ELSE '4. Target occurred > 7 days prior'
    END AS timing_classification,
    COUNT(*) AS match_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM matched_targeting), 2) AS percentage_of_matches
FROM matched_targeting
GROUP BY 1;


DROP VIEW IF EXISTS v_forensic_timezone_hourly;

CREATE VIEW v_forensic_timezone_hourly AS
SELECT 
    raw_timezone,
    COUNT(*) AS total_calls,
    ROUND(AVG(duration_sec), 1) AS avg_duration_sec,
    SUM(CASE WHEN call_status = 'ANSWERED' THEN 1 ELSE 0 END) AS answered_calls,
    ROUND(SUM(CASE WHEN call_status = 'ANSWERED' THEN 1.0 ELSE 0.0 END) / COUNT(*) * 100.0, 2) AS contact_rate_pct
FROM tr_fct_calls
GROUP BY raw_timezone;


DROP VIEW IF EXISTS v_forensic_vendor_dispositions;

CREATE VIEW v_forensic_vendor_dispositions AS
SELECT 
    vendor_id,
    COUNT(*) AS total_calls,
    SUM(CASE WHEN disposition_code = 'PTP' THEN 1 ELSE 0 END) AS count_code_ptp,
    SUM(CASE WHEN disposition_code = 'PROMISE_TO_PAY' THEN 1 ELSE 0 END) AS count_code_promise_to_pay,
    SUM(CASE WHEN standard_disposition = 'PROMISE_TO_PAY' THEN 1 ELSE 0 END) AS count_harmonized_ptp,
    SUM(is_rpc) AS count_rpc_contacts
FROM tr_fct_calls
GROUP BY vendor_id;


DROP VIEW IF EXISTS v_forensic_agent_identity;

CREATE VIEW v_forensic_agent_identity AS
SELECT 
    agent_id,
    COUNT(*) AS total_history_snapshots,
    COUNT(DISTINCT employee_code) AS unique_employee_codes_assigned,
    COUNT(DISTINCT vendor_id) AS unique_vendors,
    COUNT(DISTINCT team) AS unique_teams,
    MIN(joined_at) AS earliest_joined_at,
    MAX(updated_at) AS latest_updated_at
FROM dim_agents
GROUP BY agent_id
HAVING COUNT(DISTINCT employee_code) > 1
LIMIT 10;


DROP VIEW IF EXISTS v_forensic_portfolio_vintage;

CREATE VIEW v_forensic_portfolio_vintage AS
SELECT 
    SUBSTR(opened_at, 1, 7) AS open_vintage_month,
    COUNT(*) AS accounts_opened,
    ROUND(AVG(dpd), 1) AS mean_dpd,
    ROUND(AVG(outstanding_amount), 2) AS mean_outstanding_inr,
    ROUND(SUM(CASE WHEN risk_segment = 'HIGH' THEN 1.0 ELSE 0.0 END) / COUNT(*) * 100.0, 1) AS high_risk_pct,
    ROUND(SUM(CASE WHEN risk_segment = 'NPA' THEN 1.0 ELSE 0.0 END) / COUNT(*) * 100.0, 1) AS npa_pct
FROM dim_accounts
GROUP BY SUBSTR(opened_at, 1, 7)
ORDER BY open_vintage_month ASC;


DROP VIEW IF EXISTS v_forensic_denominator_targeting;

CREATE VIEW v_forensic_denominator_targeting AS
SELECT 
    account_master_status,
    COUNT(*) AS total_targeting_records,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fct_daily_targeting), 2) AS share_of_daily_targeting_pct,
    COUNT(DISTINCT account_id) AS unique_accounts_targeted,
    ROUND(AVG(dpd), 1) AS mean_dpd,
    ROUND(AVG(outstanding_amount), 2) AS mean_outstanding_inr
FROM fct_daily_targeting
GROUP BY account_master_status;


DROP VIEW IF EXISTS v_counterfactual_strategy_comparison;

CREATE VIEW v_counterfactual_strategy_comparison AS
WITH account_strategies AS (
    SELECT 
        t.account_id,
        c.strategy_version,
        t.account_master_status
    FROM fct_daily_targeting t
    JOIN dim_campaigns c ON t.campaign_id = c.campaign_id
    GROUP BY t.account_id, c.strategy_version
),
single_strategy_accounts AS (
    SELECT 
        account_id,
        MIN(strategy_version) AS exclusive_strategy_version
    FROM account_strategies
    GROUP BY account_id
    HAVING COUNT(DISTINCT strategy_version) = 1
),
account_outcomes AS (
    SELECT 
        s.account_id,
        s.exclusive_strategy_version,
        CASE WHEN p.account_id IS NOT NULL THEN 1 ELSE 0 END AS has_paid,
        COALESCE(p.total_amount_recovered, 0) AS amount_recovered
    FROM single_strategy_accounts s
    LEFT JOIN (
        SELECT account_id, SUM(amount) AS total_amount_recovered
        FROM fct_payments
        WHERE payment_status = 'SUCCESS'
        GROUP BY account_id
    ) p ON s.account_id = p.account_id
)
SELECT 
    exclusive_strategy_version,
    COUNT(*) AS total_accounts,
    SUM(has_paid) AS paying_accounts,
    ROUND(SUM(has_paid) * 100.0 / COUNT(*), 2) AS recovery_conversion_rate_pct,
    ROUND(SUM(amount_recovered) / 10000000.0, 4) AS total_recovered_cr,
    ROUND(AVG(amount_recovered), 2) AS mean_recovery_per_account_inr
FROM account_outcomes
GROUP BY exclusive_strategy_version
ORDER BY exclusive_strategy_version ASC;
