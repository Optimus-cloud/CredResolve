# CredResolve Data Quality & Forensic Audit Report

**Author:** Senior Data Analyst  
**Date:** October 2026  
**Analytical Scope:** Full Ingestion Audit across 17 Operational Datasets (Jan 2026 – Aug 2026)  
**Deliverable Type:** Part 1 & Part 2 Assignment Requirement  

---

## Executive Summary

CredResolve's leadership team was presented with an executive assertion: *"Recovery has improved by 11% month-on-month."* 

A comprehensive data quality audit and forensic investigation was conducted across all 18 raw files (17 relational tables + 1 data dictionary). The audit revealed that this claim is an analytical illusion driven by **calendar day-count artifacts**, **injected duplicate payments**, **denominator manipulation**, and **naive attribution logic**. 

Furthermore, our data-cleaning pipeline prevented **₹2.59 Crores** in phantom recovery from polluting executive reporting, rectified **500 duplicate payment rows**, resolved **30,000 fragmented agent snapshots**, harmonized **7,830 split promise-to-pay codes**, and uncovered that **74.59% of daily collections targeting is wasted on inactive accounts** (already closed, paid, or written off).

---

## 1. Raw Records to Golden Dataset Reconciliation

Every transformation and rejection has been logged into an immutable audit trail (`golden_dataset/audit_cleaning_trail.csv`). Below is the full reconciliation from Raw Records $\rightarrow$ Rejected / Corrected $\rightarrow$ Golden Dataset entities.

| Table Name | Raw Records | Rejected Records | Corrected / Enriched | Golden Records | Primary Cleaning Mechanism & Business Impact |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **`fct_payments`** | 25,500 | 500 | 14 | 25,000 | Deduplicated on `payment_id`. Coalesced 14 partial pairs where injected clone had `payment_reference = NULL`. Removed **₹2.59 Cr** in phantom recovery. |
| **`fct_calls`** | 91,350 | 1,350 | 90,000 | 90,000 | Dropped 1,350 injected duplicates. Standardized mixed timezones (`Asia/Dubai`, `UTC`, `Asia/Kolkata`) into standardized IST (`Asia/Kolkata`). |
| **`fct_whatsapp_events`** | 60,600 | 600 | 0 | 60,000 | Dropped 600 injected duplicates; normalized timestamps. |
| **`fct_sms_events`** | 45,000 | 0 | 0 | 45,000 | Verified unique primary keys (`sms_event_id`); standardized event dates. |
| **`fct_field_visits`** | 25,000 | 0 | 250 | 25,000 | Imputed 250 missing `scheduled_at` timestamps using `event_at`. |
| **`fct_promises_to_pay`**| 18,000 | 0 | 0 | 18,000 | Validated 18,000 PTP commitments; created binary `is_kept` indicator. |
| **`dim_borrowers`** | 30,600 | 600 | 11,015 | 11,015 | Dropped 600 duplicates. Resolved multiple profile versions per `borrower_id` by taking the latest snapshot by `updated_at`. |
| **`dim_agents`** | 30,000 | 0 | 1,000 | 1,000 | Resolved 30,000 historical audit snapshots to 1,000 master agent entities using latest `updated_at`. Isolated `employee_code` collision. |
| **`fct_agent_sessions`** | 15,000 | 0 | 0 | 15,000 | Computed 78,870.9 total agent productive hours (`logout_at - login_at`). |
| **`dim_accounts`** | 30,000 | 0 | 30,000 | 30,000 | Cross-referenced account master status against `account_status_history`. Exposed severe status divergence. |
| **`fct_daily_targeting`** | 45,000 | 0 | 45,000 | 45,000 | Flagged targeting viability. Exposed that 74.6% of targets target inactive accounts. |
| **`fct_payment_attribution_7d`** | 17,534 | 0 | 17,534 | 17,534 | Implemented strict 7-day last-touch attribution window. Classified 14,010 payments without preceding touches as UNATTRIBUTED. |

---

## 2. Forensic Investigation Deep Dive (Part 2)

### A. Duplicate Payments: Phantom Recovery Inflation
* **Forensic Question:** Could retries or ingestion issues be inflating recovery?
* **Detection Methodology:** 
  - Exact duplicate detection across all columns (`df.duplicated().sum() = 486`).
  - Primary key uniqueness scan (`payment_id.nunique() = 25,000` out of 25,500 rows).
  - Column-by-column diff analysis on the remaining 14 non-exact duplicate pairs.
* **Findings:**
  - Exactly 500 duplicate rows were injected at the end of `payments.csv` (rows 25,000 to 25,499).
  - 486 rows were identical copies of earlier transactions.
  - 14 rows shared the identical `payment_id`, `account_id`, `borrower_id`, `event_at` (to the second), `amount` (to the paisa), and `provider_id`, but had `payment_reference = NaN` in the duplicate copy.
* **Business Impact:** 
  - Leaving raw payment records uncleaned inflated gross successful recovery by **₹2,588,284.14 (~₹2.59 Cr)**.
  - Furthermore, counting uncollected payments (`FAILED`, `PENDING`, `REVERSED`) inflated raw payment totals by an additional **₹42.7 Cr**.

### B. Attribution Errors: The Post-Payment Join & Lookback Trap
* **Forensic Question:** Are payments being incorrectly attributed to the latest campaign or interaction?
* **Detection Methodology:** 
  - Calculated elapsed days between payment timestamps and prior interaction touchpoints.
  - Evaluated naive `account_id` joins between `fct_payments` and `fct_daily_targeting`.
* **Findings:**
  - **The Post-Payment Trap:** When joining payments to `daily_targeting` on `account_id` without temporal logic, **50.03% (13,144 matches) occurred AFTER the borrower had already paid**. Naive dashboards were giving credit to collection campaigns dispatched weeks after debt settlement.
  - **The 7-Day Window Reality:** Restricting attribution to interactions occurring within 7 days prior to payment reveals that **79.9% of payments (14,010 payments, ₹105.10 Cr) had NO preceding interaction in the prior 7 days**. 
  - True attributed recovery is distributed as: Voice (8.45%, ₹11.11 Cr), WhatsApp (5.26%, ₹6.93 Cr), SMS (4.18%, ₹5.50 Cr), and Field Visits (2.22%, ₹2.93 Cr).

### C. Timezone Problems: Operational Day-Boundary Distortion
* **Forensic Question:** Are calls being classified into the wrong hour/day?
* **Detection Methodology:** Checked stated timezones in `calls.csv`, `accounts.csv`, and `agent_sessions.csv`. Analyzed hourly calling distributions before and after conversion.
* **Findings:**
  - `calls.csv` labels timestamps across three timezones: `Asia/Kolkata` (30,038), `Asia/Dubai` (29,996), and `UTC` (29,966).
  - Timestamps in the raw file were generated without time offsets, creating an artificial 24/7 uniform distribution across all 24 hours.
  - Without converting `UTC` (+5:30) and `Asia/Dubai` (+1:30) to standardized Indian Standard Time (`Asia/Kolkata`), calls occurring near midnight cross calendar day boundaries, corrupting daily-level reconciliation.

### D. Vendor Mapping Changes & Legacy Disposition Splitting
* **Forensic Question:** Did telephony response/disposition codes change during the period?
* **Detection Methodology:** Cross-tabulated `disposition_code` across `disposition_version` (`legacy`, `v1`, `v2`) and telephony vendors.
* **Findings:**
  - Promise-to-pay commitments were split across two distinct disposition codes: `PROMISE_TO_PAY` (3,926 records) and `PTP` (3,904 records).
  - Both codes appeared across all vendors and versions in equal measure.
  - **The Reporting Flaw:** Any operational query filtering strictly for `WHERE disposition_code = 'PTP'` **omitted exactly 50.1% of valid promises to pay**, artificially cutting reported contact-to-PTP rates in half.
  - **Treatment:** Harmonized both codes into `PROMISE_TO_PAY` in the Golden Dataset layer.

### E. Agent Identity Problems & Employee Code Collisions
* **Forensic Question:** Does the same agent appear under multiple identifiers?
* **Detection Methodology:** Evaluated cardinality between `agent_id` (1,000 unique) and `employee_code` (1,099 unique) in `agents.csv`.
* **Findings:**
  - `agents.csv` contains 30,000 rows. Every single `agent_id` is associated with 20 to 35 different `employee_code` values, and every `employee_code` maps to multiple `agent_id`s.
  - In 4,078 records, `joined_at` is chronologically *after* `updated_at`.
  - Critically, **`agent_id` is the sole foreign key utilized across all operational tables** (`calls`, `call_attempts`, `agent_sessions`, `field_visits`).
  - **Treatment:** Selected `agent_id` as the primary key. Resolved agent dimensions by taking the latest valid snapshot by `updated_at`.

### F. Portfolio Mix Changes: Vintage & Risk Stability
* **Forensic Question:** Did the business acquire a fundamentally different portfolio?
* **Detection Methodology:** Tracked account opening vintages from Jan 2024 to Nov 2025 across DPD, loan types, and risk segments.
* **Findings:**
  - The portfolio mix has been completely invariant over time.
  - Every month's opening vintage consists of ~25% HIGH, ~25% MEDIUM, ~25% LOW, and ~25% NPA accounts.
  - Loan types (Auto, BNPL, Consumer, Credit Card, Personal) each represent exactly 20.0% of accounts.
  - Observed performance changes cannot be attributed to shifting underwriting or debtor mix.

### G. Denominator Manipulation & Invalid Targeting Waste
* **Forensic Question:** Are unsuccessful accounts disappearing from the population used to calculate conversion?
* **Detection Methodology:** Joined `daily_targeting.csv` (45,000 rows) against `dim_accounts` master status.
* **Findings:**
  - **Severe Operational Breakdown:** 
    - 24.90% of targeted accounts are already **CLOSED**
    - 24.89% of targeted accounts are already **PAID**
    - 24.80% of targeted accounts are already **WRITEOFF**
    - Only **25.41%** of targeted accounts are **ACTIVE**
  - **Business Impact:** **74.59% of daily collection outreach (33,564 out of 45,000 daily targets) is directed at accounts that cannot or do not need to pay.**
  - If analysts calculate conversion rates dividing payments by total targeted accounts, the denominator is artificially inflated by 4x, artificially depressing conversion metrics. Conversely, if failed accounts are arbitrarily purged, conversion appears inflated.

---

## 3. Data Governance & Architecture Recommendations

1. **Implement Primary Key & Unique Constraints at Gateway Ingestion:**
   - Enforce database-level uniqueness on `(payment_id)` and `(account_id, payment_reference)`. Ingested records violating uniqueness must be quarantined into a dead-letter queue (DLQ) rather than merged into analytics tables.
2. **Standardize Storage on UTC with Explicit Client Timezones:**
   - Store all operational timestamps in UTC ISO 8601 (`YYYY-MM-DDTHH:MM:SSZ`) with an accompanying timezone column.
3. **Automate Status Hierarchy & Target Eligibility Rules:**
   - Prevent the campaign engine from ingesting accounts whose master status is `CLOSED`, `PAID`, or `WRITEOFF`.
4. **Mandate Attribution Windows:**
   - Enforce an organization-wide data contract that prohibits unconstrained account joins. Attribution must require `interaction_at <= payment_at` and `payment_at - interaction_at <= 7 DAYS`.
