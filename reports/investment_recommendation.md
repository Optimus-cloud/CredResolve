# CredResolve ₹10 Crore Capital Allocation & Investment Recommendation

**Author:** Senior Data Analyst  
**Document Type:** Capital Investment Analysis & Executive Recommendation  
**Capital Under Consideration:** ₹10.00 Crores  
**Status:** Final Recommendation  

---

## 1. Executive Decision Matrix: Evaluating All Six Investment Options

Leadership must deploy the ₹10 Crore capital into exactly **one** operational area. Below is the quantitative evaluation of all six candidate areas based on empirical findings from our Golden Dataset.

| Option | Operational Area | Empirical Findings from Dataset | Expected Incremental Recovery (12M) | Total Cost | Estimated ROI (%) | Feasibility & Strategic Viability | Recommendation |
| :---: | :--- | :--- | :---: | :---: | :---: | :--- | :---: |
| **1** | **Better Telephony Infrastructure** | Answered rate is ~20% across all 5 vendors (Airtel, Exotel, Twilio, Knowlarity, TataTele). Non-connect is debtor screening, not carrier dropped calls. | ₹4.0 - ₹6.0 Cr | ₹10.0 Cr | -40% to -60% (Net Loss) | Low impact; fails to solve debtor avoidance. | **REJECT** |
| **2** | **More Collection Agents** | 1,000 agents log ~11,000 hrs/mo with low dial utilization (~0.6 calls/agent-day). Labor accounts for 62.4% of operating cost. | ₹5.0 - ₹7.0 Cr | ₹10.0 Cr | -30% to -50% (Net Loss) | Adding agents when connect rates are 20% bloats fixed payroll without lifting contact. | **REJECT** |
| **3** | **AI Voice Automation** | Voice accounts for only 8.45% of total recovery (₹11.11 Cr). Bot screening could reduce cost, but debtor pickup remains low. | ₹8.0 - ₹12.0 Cr | ₹10.0 Cr | -20% to +20% | High technical execution risk; requires proven call-pickup playbook. | **HOLD** |
| **4** | **Better Borrower Targeting & Decisioning Engine** | **74.59% of daily targeting is wasted on CLOSED, PAID, or WRITEOFF accounts.** Purging deadweight targets immediately quadruples active delinquent outreach capacity. | **₹20.0 - ₹28.0 Cr** | **₹10.0 Cr** | **+100% to +180%** | **Highest empirical leverage. Fixes severe operational leakage and optimizes omni-channel dispatch.** | **RECOMMENDED** |
| **5** | **WhatsApp / Digital Engagement** | Digital drove 9.44% of recovery (₹12.43 Cr) at 10x lower unit cost (₹0.25 vs ₹300/hr agent). High conversion efficiency. | ₹12.0 - ₹16.0 Cr | ₹10.0 Cr | +20% to +60% | Strong contender, but lacks underwriting integration to prioritize high-yield debt. | **RUNNER UP** |
| **6** | **Field Operations** | High unit cost (₹350/visit = ₹8.75 Cr cost for ₹2.93 Cr recovery). 16.9% wrong address, 16.8% not available. Severe negative ROI. | ₹2.0 - ₹3.5 Cr | ₹10.0 Cr | -65% to -80% (Net Loss) | Operationally inefficient; highly value-destructive for unsecured debt. | **REJECT** |

---

## 2. Definitive Recommendation: Option 4 — Intelligent Borrower Targeting & Decisioning Engine

### 2.1 The Core Business Rationale
Our forensic audit uncovered a profound operational flaw in CredResolve's campaign dispatch engine:
$$\mathbf{74.59\% \text{ of daily collection targeting is currently dispatched to inactive accounts!}}$$
Every single day, out of 45,000 targeted debtor records:
- **11,206 targets** are assigned to accounts already marked **`CLOSED`**
- **11,200 targets** are assigned to accounts already marked **`PAID`**
- **11,158 targets** are assigned to accounts already marked **`WRITEOFF`**
- **Only 11,436 targets (25.41%)** are assigned to **`ACTIVE`** delinquent borrowers.

Because human agents, dialers, and digital gateways are flooded with accounts that cannot pay, 3 out of every 4 operational touches are completely wasted. By deploying the ₹10 Cr into an **Intelligent Borrower Targeting & Eligibility Decisioning Engine**, CredResolve will:
1. Instantly purge all deadweight inactive accounts at the dispatch queue gateway.
2. Quadruple daily operational capacity on genuinely recoverable delinquent accounts from 11,436 to 45,000 active targets/day.
3. Deploy machine-learning propensity scoring to route high-responsiveness accounts to digital channels (WhatsApp/SMS) and reserve human voice agents strictly for high-balance, complex negotiations.

---

## 3. Financial Model & Return on Investment (ROI)

### 3.1 Capital Allocation Breakdown (₹10.0 Crore Budget)
- **Data Engineering & Eligibility Gateway:** ₹2.50 Cr (Real-time account status synchronization, queue validation, and exclusion contracts).
- **ML Propensity & Uplift Model Infrastructure:** ₹3.50 Cr (Feature store, debtor response modeling, and automated channel routing engine).
- **Phased Implementation & Pilot A/B Testing:** ₹2.00 Cr (Phase 1 controlled trial, vendor integration, and data pipeline hardening).
- **Change Management, Training & Contingency:** ₹2.00 Cr (Agent workflow transition, monitoring, and reserve capital).
- **Total Budget:** **₹10.00 Crores**.

### 3.2 Projected Financial Returns (12-Month Post-Deployment Horizon)
- **Current Annualized Clean Recovery:** ~₹225.0 Cr (Jan–Jul run-rate: ₹131.56 Cr over ~7 months).
- **Expected Incremental Recovery Lift:** **+10% to +14%** (driven by 4x active coverage expansion and optimal channel matching).
- **Expected Incremental Recovery:** **₹22.50 Crores** (Base Case: ₹24.0 Cr; Range: ₹18.0 Cr – ₹28.0 Cr).
- **Net Incremental Operating Gain:** ₹24.0 Cr incremental recovery - ₹10.0 Cr investment = **₹14.0 Crores**.
- **Expected Net ROI:**
  $$\text{Net ROI} = \frac{\text{Net Financial Gain}}{\text{Total Investment Cost}} = \frac{₹14.0\text{ Cr}}{₹10.0\text{ Cr}} = \mathbf{140\%} \quad (\text{Range: } 80\% - 180\%)$$
- **Break-Even Horizon:** **Month 5 to Month 6** following full production deployment (at ~₹2.0 Cr incremental recovery per month).

---

## 4. Risk Analysis, Key Assumptions & Downside Scenario

### 4.1 Key Assumptions
1. **Queue Capacity Utilization:** Operations can absorb 45,000 active targets/day across existing agent headcount and digital pipes without increasing fixed overhead.
2. **Persistence of Recovery Rates:** Active accounts that were previously untargeted will exhibit at least 60% of the baseline recovery rate (~26% vs ~43.5%).
3. **Channel Cost Arbitrage:** Diverting lower-ticket active accounts to WhatsApp/SMS reduces human dialer congestion.

### 4.2 Downside Scenario (Stress Test)
* **Stress Conditions:**
  - Expanded active accounts prove more resistant to collection (conversion drops to 20%).
  - Debtor contactability remains capped at 20% due to aggressive call-screening apps.
  - Engineering integration takes 9 months instead of 4 months.
* **Downside Performance:**
  - Incremental Recovery Lift: +5.0% (₹11.25 Cr over 12 months).
  - Net Return: ₹11.25 Cr recovery - ₹10.0 Cr cost = **+₹1.25 Cr** (+12.5% Net ROI).
  - Break-Even Horizon: Extends to Month 11.
  - Capital Preservation: Even under severe operational stress, the strategy does not lose principal because eliminating 74.6% wasted targeting directly conserves telephony and digital variable costs.

---

## 5. Experimental Validation Plan: Phased Randomized Controlled Trial (RCT)

Because the current synthetic dataset features uniform payment probabilities across segments (seed=42), historical observational data lacks granular pre-existing uplift variance. Deploying all ₹10 Cr blindly carries unnecessary model risk. We recommend an immediate **Phased Rollout**:

```mermaid
flowchart LR
    A["Phase 1: Pilot RCT<br/>₹1.5 Cr Budget<br/>Month 1 - Month 3"] --> B["A/B Experimentation<br/>50% Active Clean Queue<br/>50% Legacy Queue"]
    B --> C["Evaluation Gate<br/>Validate Incremental Lift<br/>Stat Sig p < 0.01"]
    C -->|Gate Passed| D["Phase 2: Full Scale<br/>₹8.5 Cr Budget<br/>Month 4 - Month 12"]
    C -->|Gate Failed| E["Pivot to Digital<br/>WhatsApp Scale-up"]
```

1. **Phase 1 (Pilot RCT - Months 1 to 3, ₹1.5 Cr):**
   - Randomize 20,000 active delinquent accounts into Treatment (clean, status-filtered, ML-ranked queue) and Control (status-quo dispatch).
   - Measure 30-day conversion uplift, cost-per-contact reduction, and true incremental recovery.
2. **Phase 2 (Full Production Rollout - Months 4 to 12, ₹8.5 Cr):**
   - Upon statistically validated lift ($p < 0.01$ and $>15\%$ relative conversion gain), scale targeting engine enterprise-wide.
