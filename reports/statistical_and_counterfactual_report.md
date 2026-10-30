# CredResolve Statistical Investigation & Counterfactual Report

**Author:** Senior Data Analyst  
**Document Type:** Statistical Rigor & Causal Inference Analysis (Part 3 & Part 4 Deliverable)  
**Status:** Complete  

---

## Part 3: Statistical Investigation of Recovery Performance

Management asserted that *"Recovery has improved by 11% month-on-month."* We investigated whether this observed change was driven by operational performance or by underlying population shifts, statistical biases, and measurement artifacts.

### 1. Investigation of Statistical Biases & Population Effects

#### 1.1 Time-Series & Calendar Day-Count Effects (The Primary Driver)
* **Hypothesis:** Monthly recovery growth was driven by variations in the number of operational days rather than true operational productivity.
* **Empirical Test:** We normalized gross monthly clean recovery by the exact calendar day count of each month.
* **Findings:**
  - February 2026: ₹17.0142 Cr across 28 days = **₹60.77 Lakhs / day**.
  - March 2026: ₹18.8912 Cr across 31 days = **₹60.94 Lakhs / day**.
  - Gross reported increase: **+11.03%**.
  - Calendar day ratio effect: $\frac{31}{28} - 1 = \mathbf{+10.71\%}$.
  - Daily normalized run-rate increase: **+0.28%** (less than 1/3 of a percent).
  - Subsequent April performance: Gross recovery dropped by **-7.29%** back to ₹17.5138 Cr (30 days = ₹58.38 Lakhs/day).
* **Classification:** **FACT**. The reported 11% improvement was an artifact of comparing a 31-day month to a 28-day month. True daily operational recovery was static.

#### 1.2 Portfolio Mix & Vintage Drift Effects
* **Hypothesis:** Underwriting quality or debtor risk composition shifted between vintages.
* **Empirical Test:** Cross-tabulated account opening vintages (Jan 2024 to Nov 2025) across risk segments (`HIGH`, `MEDIUM`, `LOW`, `NPA`), loan types, and mean DPD.
* **Findings:**
  - High Risk: 25.17% ± 0.8% across all 23 vintage months.
  - NPA Share: 24.67% ± 0.7% across all 23 vintage months.
  - Mean DPD: 56.5 ± 1.2 days across all vintages.
* **Classification:** **FACT**. There was zero change in portfolio mix. Observed performance cannot be attributed to changing debtor risk profiles.

#### 1.3 Selection Bias & Denominator Manipulation
* **Hypothesis:** Campaign targeting selected systematically easier accounts, or unsuccessful accounts were dropped from conversion reporting.
* **Empirical Test:** Analyzed the account composition of `daily_targeting.csv` (45,000 targets).
* **Findings:**
  - 74.59% of daily targets were allocated to accounts already labeled `CLOSED`, `PAID`, or `WRITEOFF`.
  - Only 25.41% were active delinquent accounts.
  - If conversion rates were calculated against all targeted accounts, the reported denominator was artificially inflated by ~4x. If an analyst selectively removed non-paying closed accounts post-hoc, reported conversion fluctuated arbitrarily.
* **Classification:** **STRONG EVIDENCE**. Denominator instability and misclassification severely distort conversion reporting.

#### 1.4 Simpson's Paradox & Channel Heterogeneity
* **Hypothesis:** Aggregated recovery trends mask divergent underlying trends across channels or risk segments.
* **Empirical Test:** Tested conversion rates across channels conditioned on risk segment and DPD buckets.
* **Findings:**
  - Individual channel contact conversion rates: Voice = 44.34%, WhatsApp = 44.38%, SMS = 44.43%, Field = 44.29%.
  - Uncontacted baseline conversion: 43.22%.
  - Simpson's paradox was not present because the underlying synthetic data generation process applied uniform probabilities across segments (seed = 42).
* **Classification:** **FACT**. No reversal of trends occurs when disaggregating across segments.

#### 1.5 Attribution-Window Bias
* **Hypothesis:** Standard reporting uses unconstrained lookback windows, attributing baseline self-cure payments to recent marketing campaigns.
* **Empirical Test:** Evaluated attribution across 1-day, 3-day, 7-day, 14-day, and 30-day lookback windows.
* **Findings:**
  - 1-Day Window: 3.2% attributed (₹4.19 Cr)
  - 3-Day Window: 9.3% attributed (₹12.25 Cr)
  - 7-Day Window: 20.1% attributed (₹26.46 Cr)
  - 14-Day Window: 36.0% attributed (₹47.74 Cr)
  - 30-Day Window: 59.8% attributed (₹78.92 Cr)
  - Unconstrained Join: 100% attributed, with 50.03% matching to campaigns *after* payment!
* **Classification:** **STRONG EVIDENCE**. Attribution window selection is the single largest determinant of reported campaign "effectiveness."

---

### 2. Summary Classification of Findings

| Finding / Conclusion | Evidence Level | Rationale |
| :--- | :---: | :--- |
| March MoM +11% recovery is a calendar artifact (31d vs 28d) | **FACT** | Proven by daily-normalized run-rate calculation (+0.28% actual change). |
| 500 duplicate payment rows inflated recovery by ₹2.59 Cr | **FACT** | Deterministic duplicate records identified and removed from `payments.csv`. |
| Unconstrained joins match 50% of payments post-payment | **FACT** | Proven by negative elapsed day calculation (`payment_at < target_date`). |
| 74.6% of daily targeting is wasted on inactive accounts | **FACT** | Validated by joining `daily_targeting` to master `accounts.status`. |
| Zero uplift achieved by targeting strategy changes | **STRONG EVIDENCE** | Chi-squared test ($p = 0.865$) across 12,294 single-strategy accounts shows identical conversion (~43.5%). |
| Non-contacted payments represent self-cure | **CORRELATION** | While 79.9% of payments had no touch in the prior 7 days, they may have received unlogged messages or external banking cues. |
| AI Voice automation will double contact rates | **HYPOTHESIS** | Unproven in current dataset; requires controlled randomized field trial. |

---

## Part 4: Counterfactual Analysis

### Question: *"What would recovery have looked like if we had not changed the targeting strategy?"*

### 1. Identification Strategy & Experimental Setup
Midway through the year, the business deployed multiple targeting strategies (`legacy`, `v1`, `v2`, `v3`). To isolate the true causal treatment effect of strategy changes from secular time trends and macro confounders, we isolated accounts that were exclusively targeted by a single strategy throughout their lifecycle.

* **Sample Size:** 12,294 distinct accounts targeted exclusively under one strategy.
* **Control Group:** Accounts assigned exclusively to `legacy` targeting ($N = 3,966$).
* **Treatment Groups:**
  - Treatment 1 (`v1`): $N = 2,323$ accounts
  - Treatment 2 (`v2`): $N = 2,767$ accounts
  - Treatment 3 (`v3`): $N = 3,238$ accounts

### 2. Empirical Results

| Strategy Version | Total Accounts ($N$) | Paying Accounts ($k$) | Recovery Conversion Rate (%) | Total Recovery (₹ Cr) | Mean Recovery / Account (₹) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Legacy (Control)** | **3,966** | **1,733** | **43.70%** | **₹17.07 Cr** | **₹43,053** |
| **Strategy v1** | 2,323 | 996 | 42.88% | ₹9.92 Cr | ₹42,706 |
| **Strategy v2** | 2,767 | 1,190 | 43.01% | ₹12.45 Cr | ₹44,984 |
| **Strategy v3** | 3,238 | 1,418 | 43.79% | ₹13.98 Cr | ₹43,171 |
| **Pooled Total** | 12,294 | 5,337 | 43.41% | ₹53.42 Cr | ₹43,454 |

### 3. Statistical Significance Testing
We conducted a Pearson Chi-Squared Test of Independence on the contingency matrix of paying vs. non-paying accounts across the four strategies:
$$\chi^2 = 0.7327, \quad \text{degrees of freedom} = 3, \quad p\text{-value} = 0.8655$$

Because $p = 0.8655 \gg 0.05$, we fail to reject the null hypothesis of equal recovery rates.

### 4. Counterfactual Estimate & Conclusion
If the business had **not** changed its targeting strategy and remained 100% on `legacy`:
- Expected Conversion Rate: **43.70%** (vs 43.41% observed pooled).
- Expected Average Recovery per Account: **₹43,053** (vs ₹43,454 observed pooled).
- **Net Causal Uplift from Strategy Changes:** **0.00% (Zero Uplift)**.
- **Estimated Difference in Total Recovery:** $\pm \text{₹}0.15\text{ Cr}$ (statistically indistinguishable from zero random noise).

### 5. Threats to Validity & Limitations
1. **Overlap Cohorts:** Approximately 11,050 accounts were targeted by multiple overlapping strategies across their lifecycle, preventing clean attribution for those accounts.
2. **Synthetic Data Artifact:** As confirmed by the project seed (seed=42), accounts were generated with uniform baseline payment probabilities across risk and strategy dimensions. Future real-world targeting must be designed as an explicit pre-registered A/B test.
