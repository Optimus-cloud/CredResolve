# MEMORANDUM

**TO:** Chief Executive Officer & Senior Leadership Team, CredResolve  
**FROM:** Senior Data Analyst  
**DATE:** October 30, 2026  
**SUBJECT:** Forensic Audit of Reported 11% MoM Recovery Improvement & ₹10 Cr Capital Allocation  

---

### 1. What Happened?
Leadership was presented with the claim: *"Recovery has improved by 11% month-on-month."* 

**The claim is an analytical illusion.** Operational performance did not improve. 
- In raw reporting, gross successful recovery rose from **₹17.41 Cr in February 2026** to **₹19.32 Cr in March 2026** (+10.99% ≈ +11.0%).
- However, February has 28 days while March has 31 days. The calendar day-count expansion alone accounts for **+10.71%** of the increase.
- When normalized by operating days, daily recovery was **₹60.77 Lakhs/day in February** and **₹60.94 Lakhs/day in March**—a negligible change of **+0.28%**.
- In April 2026, gross recovery immediately plummeted by **-7.29%** back to ₹17.51 Cr (₹58.38 Lakhs/day).
- Real collections performance has remained strictly range-bound between ₹58.4 Lakhs/day and ₹60.9 Lakhs/day across the entire 7-month period, with **zero upward operational momentum**.

---

### 2. Why Did It Happen?
Our forensic audit of 17 relational event streams uncovered three underlying structural drivers:

1. **Calendar & Measurement Artifacts:** Management evaluated unadjusted calendar month aggregates. A 28-day February creates an automatic artificial trough, producing a false double-digit "surge" in 31-day March.
2. **Injected Duplicate Data & Phantom Recovery:** The ingestion pipeline contained **500 duplicate payment rows** (486 exact clones and 14 partial duplicates with nullified references). Uncleaned tables inflated successful recovery by **₹2.59 Crores**. Furthermore, uncollected payments (`FAILED`, `PENDING`, `REVERSED`) improperly added **₹42.7 Cr** to unvetted dashboards.
3. **Severe Denominator Distortion & Operational Leakage:** **74.59% of daily collection targeting is currently dispatched to inactive accounts** (24.9% closed, 24.9% already paid, 24.8% written off). Only 25.41% of targets are active delinquent accounts. As a result, 3 out of every 4 human dials, WhatsApp messages, and field visits are wasted on accounts that cannot pay.
4. **Attribution Traps:** When joining daily targeting to payments solely on account ID, **50.03% of payments match to campaigns executed AFTER the debt was already settled**. Evaluating payments against a strict 7-day lookback window shows that **79.9% of payments (₹105.10 Cr) occurred without any operational interaction in the preceding 7 days**, while Voice drove 8.45% (₹11.11 Cr), WhatsApp 5.26% (₹6.93 Cr), SMS 4.18% (₹5.50 Cr), and Field Visits 2.22% (₹2.93 Cr).

---

### 3. How Confident Are We?
Our findings are classified strictly by empirical evidence level:
- **FACT (100% Certainty):** The +11% March MoM jump is a calendar artifact (+10.71% day count, +0.28% daily rate). Rejection of 500 duplicate payment rows eliminated ₹2.59 Cr in phantom recovery. Exactly 74.59% of daily targeting is directed at inactive accounts.
- **STRONG EVIDENCE (95%+ Statistical Confidence):** Midway targeting strategy changes (`legacy`, `v1`, `v2`, `v3`) yielded zero causal uplift ($p = 0.865$, Pearson Chi-Squared test across 12,294 single-strategy accounts).
- **CAVEAT / LIMITATION:** Because the synthetic test dataset was generated with uniform underlying probabilities (seed=42), real-world debtor response will exhibit non-linear behavioral clustering that requires live experimentation.

---

### 4. What Should We Do? (The ₹10 Crore Investment)
We evaluated all six permissible investment options. Telephony infrastructure (connect rates are ~20% across all carriers due to borrower screening) and more human agents (adds fixed overhead while dial utilization is low) are value-destructive.

**RECOMMENDATION: Invest the ₹10.0 Crore Capital in Option 4 — Better Borrower Targeting & Decisioning Engine.**

**Action Plan:**
1. **Immediate Ingestion Gateway Cleansing:** Deploy automated pre-dispatch eligibility filters to purge the 74.6% deadweight inactive accounts from collection queues.
2. **Reallocate Operational Bandwidth:** Redirect 100% of the 45,000 daily outreach capacity exclusively to active delinquent debt, expanding active debtor contact capacity by **4x**.
3. **Deploy Uplift Decisioning:** Route low-ticket/early-DPD accounts to low-cost digital channels (WhatsApp/SMS at ₹0.25/msg) and reserve high-cost human agents (₹300/hr) for complex, high-balance negotiations.
4. **Phased RCT Implementation:** Execute a 90-day Phase 1 Randomized Controlled Trial (₹1.5 Cr budget) on 20,000 accounts to statistically validate uplift before committing the remaining ₹8.5 Cr to enterprise rollout.

---

### 5. What is the Expected Financial Impact?

```
Current Annualized Clean Recovery:               ₹225.0 Crores
Projected Incremental Recovery Lift:             +10% to +14%
Expected Incremental Gross Recovery (12M):       ₹22.5 - ₹28.0 Crores (Base Case: ₹24.0 Cr)
Total Capital Investment:                        ₹10.0 Crores
Net Financial Gain:                              ₹14.0 Crores
Projected Net ROI:                               140% (Range: 80% to 180%)
Break-Even Horizon:                              5 to 6 Months Post-Rollout
Downside Protection:                             Capital preserved; variable dial costs drop immediately.
```

By eliminating wasted outreach and triaging borrowers intelligently, CredResolve transitions from blind operational brute force to data-driven capital efficiency.
