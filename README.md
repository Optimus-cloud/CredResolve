# CredResolve Data Analyst Recruitment Assignment — Complete Repository

**Candidate:** Senior Data Analyst Submission  
**Dataset Coverage:** ~12 Months Synthesized Relational Event Streams (Jan 2026 – Aug 2026 Operations; 2024–2025 Account Vintages)  
**Database Built:** `credresolve_analytics.db` (High-Performance SQLite3 Analytics Layer)  
**Deliverables Status:** **All 7 Required Deliverables Complete, Validated & Executed**  

---

## Executive Summary of Core Findings

1. **The "11% Recovery Improvement" Deconstruction:**
   - Management reported that collections recovery improved by 11% month-on-month between February and March 2026.
   - **Empirical Reality:** February 2026 has 28 days (Clean Recovery = ₹17.01 Cr = **₹60.77 Lakhs/day**); March 2026 has 31 days (Clean Recovery = ₹18.89 Cr = **₹60.94 Lakhs/day**).
   - The reported gross jump of **+11.03%** was an artifact of the **+10.71% calendar day-count expansion**.
   - Real daily normalized recovery improved by merely **+0.28%**. In April, recovery dropped by **-7.29%** back to ₹17.51 Cr. Performance has remained strictly flat across all 7 months.
2. **Injected Duplicate Payments & Phantom Inflation:**
   - `payments.csv` contained **500 duplicate rows** (486 exact copies + 14 pairs with nullified reference).
   - Removing these duplicates eliminated **₹2.59 Crores** in phantom recovery.
3. **Targeting Denominator Waste & Operational Leakage:**
   - In `daily_targeting.csv`, **74.59% of daily targets** are assigned to accounts that are already `CLOSED` (24.90%), `PAID` (24.89%), or `WRITEOFF` (24.80%). Only 25.41% are active delinquent accounts.
   - 3 out of every 4 operational touches are completely wasted on non-recoverable accounts.
4. **Capital Allocation Recommendation (₹10.0 Crore Budget):**
   - **Recommended:** **Option 4 — Better Borrower Targeting & Decisioning Engine**.
   - **Financial Return:** Expected incremental recovery of **₹24.0 Cr** over 12 months, **140% Net ROI**, and a **6-month break-even horizon**.

---

## Repository Structure & Deliverables Map

```
CredResolve/
├── pipeline/
│   ├── build_golden_dataset.py       # [DELIVERABLE 3] Reproducible Golden Dataset Pipeline
│   └── generate_ipynb.py             # Jupyter Notebook generator
├── sql/                              # [DELIVERABLE 1] Production SQL Repository
│   ├── 01_clean.sql                  # Data cleaning, deduplication, and coalescing
│   ├── 02_transform.sql              # Entity resolution, timezones, and 7-day attribution
│   ├── 03_metrics.sql                # Independent calculation of 9 core collections metrics
│   └── 04_forensics_analytics.sql    # Part 2 Forensics, Part 3 Bias tests & Part 4 Counterfactual
├── golden_dataset/                   # [DELIVERABLE 3] Clean Golden Layer & Audit Trail
│   ├── audit_cleaning_trail.csv      # Complete record-level audit trail of all transformations
│   ├── dim_accounts.csv              # Conformed Accounts Dimension
│   ├── dim_borrowers.csv             # Entity-resolved Borrowers Dimension (11,015 entities)
│   ├── dim_agents.csv                # Entity-resolved Agents Dimension (1,000 entities)
│   ├── dim_campaigns.csv             # Clean Campaigns Reference
│   ├── fct_payments.csv              # Deduplicated Payments Fact (25,000 records)
│   ├── fct_calls.csv                 # Harmonized Calls Fact with IST timezones (90,000 records)
│   ├── fct_whatsapp_events.csv       # Deduplicated WhatsApp Events Fact (60,000 records)
│   ├── fct_sms_events.csv            # SMS Events Fact (45,000 records)
│   ├── fct_field_visits.csv          # Field Visits Fact with imputed timestamps (25,000 records)
│   ├── fct_promises_to_pay.csv       # Promises to Pay Fact (18,000 records)
│   ├── fct_daily_targeting.csv       # Targeting Fact with account eligibility flags (45,000 records)
│   └── fct_payment_attribution_7d.csv# 7-Day Last-Touch Attribution Layer (17,534 payments)
├── notebooks/                        # [DELIVERABLE 2] Analysis Notebook
│   ├── analysis_notebook.ipynb       # Jupyter Notebook showing reasoning, code, and outputs
│   └── analysis_notebook.py          # Standalone executable Python analysis pipeline
├── reports/                          # [DELIVERABLES 4, 5, 6, 7] Executive Reports & Visuals
│   ├── data_quality_report.md        # [DELIVERABLE 4] Data Quality & Part 2 Forensic Report
│   ├── statistical_and_counterfactual_report.md # Part 3 Statistical Tests & Part 4 Counterfactual
│   ├── investment_recommendation.md  # Detailed ₹10 Cr Investment Analysis across 6 Options
│   ├── executive_memo.md             # [DELIVERABLE 6] Maximum 2-Page Executive Memo
│   ├── executive_dashboard.html      # [DELIVERABLE 5] 1-Screen Interactive CEO Dashboard
│   ├── architecture_diagram.md       # [DELIVERABLE 7] Production Architecture Design & Lineage
│   └── figures/                      # High-resolution analytical charts
│       ├── monthly_recovery_deconstruction.png
│       ├── attribution_channel_breakdown.png
│       ├── denominator_waste_pie.png
│       └── targeting_strategies_comparison.png
├── credresolve_analytics.db          # Unified SQLite3 Analytical Database
├── accounts.csv ... whatsapp_events.csv # Original Immutable Raw CSV Files
└── README.md                         # Project documentation and reproduction instructions
```

---

## Instructions to Reproduce All Analyses

### 1. Build the Golden Dataset & Analytical Database
To run the automated cleaning pipeline, resolve entities, enforce deduplication, and populate `credresolve_analytics.db` and the `golden_dataset/` directory:
```bash
python pipeline/build_golden_dataset.py
```

### 2. Execute and Test the SQL Repository
To execute the production SQL transformations, metric calculations, and forensic queries:
```bash
python -c "
import sqlite3
conn = sqlite3.connect('credresolve_analytics.db')
for f in ['sql/01_clean.sql', 'sql/02_transform.sql', 'sql/03_metrics.sql', 'sql/04_forensics_analytics.sql']:
    with open(f, 'r', encoding='utf-8') as sql_file:
        conn.cursor().executescript(sql_file.read())
print('All SQL files executed successfully.')
conn.close()
"
```

### 3. Run the Statistical Analysis & Generate Visualizations
To execute the end-to-end Python statistical tests, day-count deconstructions, counterfactual evaluations, and chart generation:
```bash
python notebooks/analysis_notebook.py
```

### 4. Open the One-Screen Executive Dashboard
Open `reports/executive_dashboard.html` in any modern web browser to view the interactive, decision-oriented CEO dashboard.

---

## Summary of Core Metric Definitions

| Metric | Grain | Numerator | Denominator | Observed Value |
| :--- | :---: | :--- | :--- | :---: |
| **Contact Rate** | Monthly | Calls with `call_status = 'ANSWERED'` | Total Clean Call Events | **19.86%** |
| **Right Party Contact (RPC) Rate** | Monthly | Answered Calls with confirmed debtor disposition | Total Answered Calls | **24.81%** (of total calls) |
| **Promise-to-Pay (PTP) Rate** | Monthly | Total PTP Commitments Generated | Answered Calls | **99.5%** |
| **PTP Kept Rate** | Monthly | Matured PTPs with `status = 'KEPT'` | Matured PTPs (`KEPT` + `BROKEN` + `CANCELLED`) | **33.02%** |
| **Recovery Rate (Financial)** | Total | Clean Successful Recovery Amount | Portfolio Total Outstanding Balance | **12.52%** |
| **Recovery Rate (Account)** | Total | Distinct Accounts with $\ge 1$ Clean Success Payment | Total Portfolio Accounts (30,000) | **44.28%** |
| **Recovery per Account** | Monthly | Total Monthly Clean Successful Recovery | Distinct Paying Accounts | **₹78,125** |
| **Recovery per Agent-Hour** | Monthly | Total Attributed Clean Recovery | Productive Agent Session Hours | **₹16,680 / hr** |
| **Cost per Rupee Recovered** | Total | Total Operating Expenses (Labor + Telecom + Field + Digital) | Total Clean Successful Recovery | **₹0.0988** (~9.9 paise / ₹) |
| **Channel Conversion** | Channel | Paying Accounts within 7-Day Window | Accounts Contacted via Specific Channel | Voice: 44.3%, WA: 44.4%, SMS: 44.4%, Field: 44.3% |
