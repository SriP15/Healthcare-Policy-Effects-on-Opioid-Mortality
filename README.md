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
* Two-way fixed-effects regression
* Sun & Abraham staggered-adoption event study
* Conventional event-study analysis for diagnostic comparison
* State fixed effects
* Year fixed effects
* Clustered standard errors
* Parallel-trends assessment
* State-specific trend sensitivity analysis
* Early-adopter sensitivity analysis
* Directed Acyclic Graph (DAG) to motivate the causal structure

The baseline two-way fixed-effects models account for time-invariant state differences and common national shocks. Because PDMP policies were adopted at different times across states, the analysis also applies a Sun & Abraham staggered-adoption event-study specification to allow treatment effects to vary across adoption cohorts and relative time.

Pre-treatment estimates are used to assess the plausibility of the parallel-trends assumption and identify potential threats to causal interpretation.

---

## Workflow

1. Import and clean state-level mortality and PDMP policy data.
2. Construct policy adoption years and treatment indicators.
3. Create a state-year panel dataset.
4. Estimate baseline two-way fixed-effects Difference-in-Differences models.
5. Estimate a Sun & Abraham staggered-adoption event study.
6. Compare results with a conventional TWFE event-study diagnostic.
7. Evaluate pre-treatment trends and the parallel-trends assumption.
8. Conduct state-specific trend and early-adopter sensitivity analyses.
9. Interpret results in light of the identifying assumptions and study limitations.

---

## Technologies

* R
* tidyverse
* fixest
* ggplot2
* dplyr
* readxl
* lubridate

---

## Key Concepts Demonstrated

* Causal inference
* Difference-in-Differences
* Staggered treatment adoption
* Fixed-effects regression
* Event studies
* Policy evaluation
* Longitudinal panel data analysis
* Data visualization
* Assumption checking
* Sensitivity analysis

---

## Results

The baseline Difference-in-Differences estimate is positive but statistically imprecise. Event-study analyses provide evidence of differential pre-treatment trends, raising concerns about the parallel-trends assumption and the credibility of a causal interpretation.

Because treatment adoption is staggered across states, the analysis also applies a Sun & Abraham event-study specification designed to accommodate variation in treatment timing and treatment effects across cohorts. Results remain sensitive to modeling choices and sample restrictions.

Overall, the analysis does not provide credible evidence of a clearly identified causal effect of PDMP adoption on illicit opioid mortality. Instead, the findings suggest that policy adoption may be related to worsening opioid conditions, highlighting the challenges of causal policy evaluation when treatment timing is endogenous to evolving outcome trends.

---

## Limitations

* Policy adoption may be influenced by state-specific and time-varying factors.
* Other opioid-related interventions and changes in illicit drug supply may occur simultaneously.
* The causal interpretation relies on the validity of the parallel-trends assumption.
* Missing mortality data are not uniformly distributed across states and time.
* Conventional two-way fixed-effects estimates may be difficult to interpret under staggered adoption and heterogeneous treatment effects; a Sun & Abraham specification is included to partially address this concern.
* Estimated effects may vary across states, adoption cohorts, and time since policy implementation.

---

## Future Improvements

* Incorporate county-level analyses.
* Explore additional sources of treatment-effect heterogeneity.
* Compare multiple opioid-related policy interventions.
* Compare the Sun & Abraham estimates with alternative staggered-adoption estimators such as Callaway & Sant'Anna.
* Conduct additional robustness and sensitivity analyses.
* Explore alternative research designs with more credible sources of identifying variation.

---

## Reproducibility

To reproduce the analysis:

1. Clone this repository.
2. Install the required R packages used in the analysis script.
3. Run `OpioidMortalityDiD.R` from the repository root.
4. The script reads the included mortality and PDMP policy datasets and reproduces the main analyses and figures.
5. Data: The mortality CSVs are raw exports from CDC WONDER and retain the source metadata and caveat text appended by CDC to each export; the analysis script selects and cleans the relevant state-year mortality fields before constructing the panel.

---

## Skills Demonstrated

* Applied causal inference
* Difference-in-Differences
* Staggered-adoption event studies
* Policy evaluation
* Panel data analysis
* Statistical modeling in R
* Data cleaning and integration
* Data visualization
* Assumption checking
* Sensitivity analysis
* Research communication
