# Opioid Mortality Policy Evaluation Using Difference-in-Differences

## Overview

This project evaluates whether state Prescription Drug Monitoring Program (PDMP) policies were associated with changes in opioid overdose mortality rates in the United States. Because states adopted these policies at different times, the analysis uses Difference-in-Differences and event-study methods for observational policy evaluation.

The project demonstrates how econometric methods can be used to evaluate policy effects when randomized controlled trials are not feasible, while also assessing whether the assumptions required for causal interpretation are plausible.

---

## Research Question

**Did implementation of state PDMP policies reduce opioid overdose mortality?**

Specifically, this project examines the association between PDMP adoption and opioid mortality using state and year fixed effects, while evaluating whether the identifying assumptions required for a causal interpretation are supported by the data.

---

## Methods

The analysis was conducted in **R** using a panel dataset of U.S. states observed over multiple years.

Key methods include:

* Difference-in-Differences (DiD)
* Event-study analysis
* State fixed effects
* Year fixed effects
* Clustered standard errors
* Parallel-trends assessment
* Directed Acyclic Graph (DAG) to motivate the causal structure

These methods account for time-invariant state differences and common national shocks, while the event-study analysis is used to assess pre-treatment trends and the plausibility of causal identification.

---

## Workflow

1. Import and clean state-level mortality and policy data.
2. Construct treatment timing indicators.
3. Create panel data indexed by state and year.
4. Estimate Difference-in-Differences models.
5. Estimate event-study specifications around policy adoption.
6. Evaluate pre-treatment trends and the parallel-trends assumption.
7. Conduct robustness and sensitivity analyses.
8. Interpret results in light of the identification assumptions and study limitations.

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
* Fixed-effects regression
* Event studies
* Policy evaluation
* Longitudinal (panel) data analysis
* Data visualization
* Assumption checking
* Sensitivity analysis

---

## Results

The baseline Difference-in-Differences estimate is positive but statistically imprecise. Event-study estimates show evidence of differential pre-treatment trends, and estimated effects are sensitive to model specification and sample restrictions.

These findings raise concerns about the credibility of a causal interpretation and suggest that policy adoption may be endogenous to worsening opioid conditions. Rather than providing evidence of a clear causal effect, the analysis highlights the difficulty of identifying policy effects when treatment timing is related to evolving outcome trends.

---

## Limitations

* Policy adoption may be influenced by state-specific and time-varying factors.
* Other opioid-related interventions and changes in illicit drug supply may occur simultaneously.
* The causal interpretation relies on the validity of the parallel-trends assumption.
* Missing mortality data are not uniformly distributed across states and time.
* Conventional two-way fixed-effects estimators may be difficult to interpret under staggered adoption and heterogeneous treatment effects.
* Estimated effects may vary across states, adoption cohorts, and time since policy implementation.

---

## Future Improvements

* Incorporate county-level analyses.
* Explore heterogeneous treatment effects.
* Compare multiple policy interventions.
* Apply staggered-adoption estimators such as Callaway & Sant'Anna or Sun & Abraham.
* Conduct additional robustness and sensitivity analyses.
* Explore alternative research designs with more credible sources of identifying variation.

---

## Reproducibility

To reproduce the analysis:

1. Clone this repository.
2. Install the required R packages used in the analysis script.
3. Run `OpioidMortalityDiD.R` from the repository root.
4. The script reads the included mortality and PDMP policy datasets and reproduces the main analyses and figures.

---

## Skills Demonstrated

* Applied causal inference
* Difference-in-Differences
* Event-study methodology
* Policy evaluation
* Panel data analysis
* Statistical modeling in R
* Data cleaning and integration
* Data visualization
* Assumption checking
* Research communication
