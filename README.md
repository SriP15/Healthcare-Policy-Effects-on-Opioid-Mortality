# Opioid Mortality Policy Evaluation Using Difference-in-Differences

## Overview

This project evaluates whether state Prescription Drug Monitoring Program (PDMP) policies were associated with changes in opioid overdose mortality rates in the United States. Because states adopted these policies at different times, the analysis uses modern causal inference techniques designed for observational policy evaluation.

The project demonstrates how econometric methods can be applied to estimate policy effects when randomized controlled trials are not feasible.

---

## Research Question

**Did implementation of state PDMP policies reduce opioid overdose mortality?**

Specifically, this project estimates the average treatment effect of PDMP adoption while accounting for differences across states and changes over time.

---

## Methods

The analysis was conducted in **R** using a panel dataset of U.S. states observed over multiple years.

Key methods include:

* Difference-in-Differences (DiD)
* Event Study analysis
* State fixed effects
* Year fixed effects
* Clustered standard errors
* Parallel trends assessment
* Directed Acyclic Graph (DAG) to motivate the causal design

These methods help isolate the effect of policy implementation from broader national trends.

---

## Workflow

1. Import and clean state-level mortality and policy data.
2. Construct treatment timing indicators.
3. Create panel data indexed by state and year.
4. Estimate Difference-in-Differences models.
5. Estimate dynamic treatment effects using an event study.
6. Evaluate the parallel trends assumption.
7. Interpret policy impacts and discuss limitations.

---

## Repository Structure

```
├── data/
│   ├── raw/
│   └── processed/
│
├── scripts/
│   ├── data_cleaning.R
│   ├── did_analysis.R
│   ├── event_study.R
│   └── visualization.R
│
├── figures/
│
├── output/
│
└── README.md
```

---

## Technologies

* R
* tidyverse
* fixest
* ggplot2
* dplyr

---

## Key Concepts Demonstrated

* Causal inference
* Difference-in-Differences
* Fixed effects regression
* Event studies
* Policy evaluation
* Longitudinal (panel) data analysis
* Data visualization
* Assumption checking

---

## Results

The analysis estimates the association between PDMP adoption and opioid mortality using modern Difference-in-Differences techniques. Event study estimates are used to examine treatment dynamics before and after policy implementation and to assess whether the parallel trends assumption appears reasonable.

Because policy adoption is not randomized, the estimated effects should be interpreted as observational causal estimates under the assumptions of the Difference-in-Differences framework.

---

## Limitations

* Policy adoption may be influenced by state-specific factors.
* Other opioid-related interventions may occur simultaneously.
* Results rely on the validity of the parallel trends assumption.
* Effects represent average policy impacts and may vary across states.

---

## Future Improvements

* Incorporate county-level analyses.
* Explore heterogeneous treatment effects.
* Compare multiple policy interventions.
* Apply staggered adoption estimators (e.g., Callaway & Sant'Anna or Sun & Abraham).
* Conduct additional robustness and sensitivity analyses.

---

## Skills Demonstrated

* Applied causal inference
* Difference-in-Differences
* Event study methodology
* Policy evaluation
* Panel data analysis
* Statistical modeling in R
* Data visualization
* Research communication
