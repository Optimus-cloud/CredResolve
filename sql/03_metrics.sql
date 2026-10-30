DROP VIEW IF EXISTS v_monthly_recovery_analysis;

CREATE VIEW v_monthly_recovery_analysis AS
WITH monthly_summary AS (
    SELECT 
        SUBSTR(event_date, 1, 7) AS month,
        CASE 
            WHEN SUBSTR(event_date, 1, 7) IN ('2026-01', '2026-03', '2026-05', '2026-07') THEN 31
            WHEN SUBSTR(event_date, 1, 7) = '2026-02' THEN 28
            WHEN SUBSTR(event_date, 1, 7) IN ('2026-04', '2026-06') THEN 30
            ELSE 8
        END AS days_in_month,
        COUNT(*) AS total_payment_txns,
        SUM(CASE WHEN payment_status = 'SUCCESS' THEN 1 ELSE 0 END) AS success_payment_txns,
        ROUND(SUM(CASE WHEN payment_status = 'SUCCESS' THEN amount ELSE 0 END) / 10000000.0, 4) AS clean_recovery_cr,
        ROUND(SUM(CASE WHEN payment_status = 'SUCCESS' THEN amount ELSE 0 END) / 
              (CASE 
                  WHEN SUBSTR(event_date, 1, 7) IN ('2026-01', '2026-03', '2026-05', '2026-07') THEN 31.0
                  WHEN SUBSTR(event_date, 1, 7) = '2026-02' THEN 28.0
                  WHEN SUBSTR(event_date, 1, 7) IN ('2026-04', '2026-06') THEN 30.0
                  ELSE 8.0
              END) / 100000.0, 2) AS clean_daily_recovery_lakhs
    FROM fct_payments
    WHERE SUBSTR(event_date, 1, 7) <= '2026-07'
    GROUP BY SUBSTR(event_date, 1, 7)
)
SELECT 
    month,
    days_in_month,
    total_payment_txns,
    success_payment_txns,
    clean_recovery_cr,
    ROUND((clean_recovery_cr - LAG(clean_recovery_cr) OVER (ORDER BY month)) / 
          LAG(clean_recovery_cr) OVER (ORDER BY month) * 100.0, 2) AS gross_mom_change_pct,
    clean_daily_recovery_lakhs,
    ROUND((clean_daily_recovery_lakhs - LAG(clean_daily_recovery_lakhs) OVER (ORDER BY month)) / 
          LAG(clean_daily_recovery_lakhs) OVER (ORDER BY month) * 100.0, 2) AS daily_normalized_mom_change_pct
FROM monthly_summary;


DROP VIEW IF EXISTS v_contact_and_rpc_rates;

CREATE VIEW v_contact_and_rpc_rates AS
SELECT 
    call_month AS month,
    COUNT(*) AS total_calls,
    SUM(CASE WHEN call_status = 'ANSWERED' THEN 1 ELSE 0 END) AS answered_calls,
    ROUND(SUM(CASE WHEN call_status = 'ANSWERED' THEN 1.0 ELSE 0.0 END) / COUNT(*) * 100.0, 2) AS contact_rate_pct,
    SUM(is_rpc) AS rpc_calls,
    ROUND(SUM(is_rpc) * 1.0 / NULLIF(SUM(CASE WHEN call_status = 'ANSWERED' THEN 1 ELSE 0 END), 0) * 100.0, 2) AS rpc_rate_on_answered_pct,
    ROUND(SUM(is_rpc) * 1.0 / COUNT(*) * 100.0, 2) AS rpc_rate_on_total_calls_pct
FROM fct_calls
WHERE call_month <= '2026-07'
GROUP BY call_month;


DROP VIEW IF EXISTS v_ptp_performance;

CREATE VIEW v_ptp_performance AS
WITH monthly_ptp AS (
    SELECT 
        SUBSTR(event_at, 1, 7) AS month,
        COUNT(*) AS total_ptp_commitments,
        SUM(CASE WHEN status = 'KEPT' THEN 1 ELSE 0 END) AS kept_ptp,
        SUM(CASE WHEN status = 'BROKEN' THEN 1 ELSE 0 END) AS broken_ptp,
        SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled_ptp,
        SUM(CASE WHEN status = 'OPEN' THEN 1 ELSE 0 END) AS open_ptp,
        ROUND(SUM(promised_amount) / 10000000.0, 2) AS total_promised_amount_cr
    FROM fct_promises_to_pay
    WHERE SUBSTR(event_at, 1, 7) <= '2026-07'
    GROUP BY SUBSTR(event_at, 1, 7)
),
monthly_calls AS (
    SELECT call_month AS month, SUM(CASE WHEN call_status = 'ANSWERED' THEN 1 ELSE 0 END) AS answered_calls
    FROM fct_calls
    WHERE call_month <= '2026-07'
    GROUP BY call_month
)
SELECT 
    p.month,
    p.total_ptp_commitments,
    c.answered_calls,
    ROUND(p.total_ptp_commitments * 1.0 / c.answered_calls * 100.0, 2) AS ptp_rate_on_answered_pct,
    p.kept_ptp,
    p.broken_ptp,
    p.cancelled_ptp,
    ROUND(p.kept_ptp * 1.0 / (p.kept_ptp + p.broken_ptp + p.cancelled_ptp) * 100.0, 2) AS ptp_kept_rate_pct,
    p.total_promised_amount_cr
FROM monthly_ptp p
JOIN monthly_calls c ON p.month = c.month;


DROP VIEW IF EXISTS v_productivity_metrics;

CREATE VIEW v_productivity_metrics AS
WITH monthly_recov AS (
    SELECT 
        SUBSTR(event_date, 1, 7) AS month,
        COUNT(DISTINCT account_id) AS distinct_paying_accounts,
        SUM(amount) AS clean_recovery_inr
    FROM fct_payments
    WHERE payment_status = 'SUCCESS' AND SUBSTR(event_date, 1, 7) <= '2026-07'
    GROUP BY SUBSTR(event_date, 1, 7)
),
monthly_hours AS (
    SELECT 
        SUBSTR(login_at, 1, 7) AS month,
        ROUND(SUM((JULIANDAY(logout_at) - JULIANDAY(login_at)) * 24.0), 1) AS total_agent_hours
    FROM fct_agent_sessions
    WHERE SUBSTR(login_at, 1, 7) <= '2026-07'
    GROUP BY SUBSTR(login_at, 1, 7)
)
SELECT 
    r.month,
    r.distinct_paying_accounts,
    ROUND(r.clean_recovery_inr / 10000000.0, 4) AS clean_recovery_cr,
    ROUND(r.clean_recovery_inr / 30000.0, 2) AS recovery_per_total_portfolio_account_inr,
    ROUND(r.clean_recovery_inr / r.distinct_paying_accounts, 2) AS recovery_per_paying_account_inr,
    h.total_agent_hours,
    ROUND(r.clean_recovery_inr / h.total_agent_hours, 2) AS recovery_per_agent_hour_inr
FROM monthly_recov r
JOIN monthly_hours h ON r.month = h.month;


DROP VIEW IF EXISTS v_channel_attribution_summary;

CREATE VIEW v_channel_attribution_summary AS
SELECT 
    attributed_channel,
    COUNT(*) AS payment_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM tr_payment_attribution_7d), 2) AS payment_share_pct,
    ROUND(SUM(amount) / 10000000.0, 4) AS attributed_amount_cr,
    ROUND(SUM(amount) * 100.0 / (SELECT SUM(amount) FROM tr_payment_attribution_7d), 2) AS amount_share_pct,
    ROUND(AVG(amount), 2) AS average_ticket_size_inr,
    ROUND(AVG(days_prior), 2) AS avg_days_prior_to_payment
FROM tr_payment_attribution_7d
GROUP BY attributed_channel;
