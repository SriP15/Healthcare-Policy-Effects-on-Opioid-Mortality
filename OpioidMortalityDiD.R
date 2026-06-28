library(dplyr)
library(readxl)
library(lubridate)
library(fixest)

# Load required packages:
# dplyr: data manipulation
# readxl: reading Excel files
# lubridate: working with dates
# fixest: fixed effects regression models, useful for DiD/event-study models

# -----------------------------
# 1. Load opioid mortality data
# -----------------------------

# Load mortality data for prescription opioid deaths.
presc <- read.csv("prescription_opioids.csv", stringsAsFactors = FALSE)

# Load mortality data for illicit opioid deaths.
illicit <- read.csv("illicit_opioids.csv", stringsAsFactors = FALSE)


# ---------------------------------------
# 2. Clean prescription opioid death data
# ---------------------------------------

# CDC WONDER-style data often contains non-numeric values such as
# "Unreliable" or "Suppressed" when rates are not reported.
# These need to be converted to NA before numeric analysis.
bad_vals <- c("Unreliable", "Suppressed", "", "Not Applicable")

# Keep only the state, year, and crude mortality rate columns.
# Rename Crude.Rate to presc_rate for clarity.
presc_clean <- presc %>%
  select(State, Year, Crude.Rate) %>%
  rename(presc_rate = Crude.Rate)

# Replace non-numeric suppressed/unreliable values with NA.
presc_clean$presc_rate[presc_clean$presc_rate %in% bad_vals] <- NA

# Remove commas from numeric strings and convert the rate to numeric.
presc_clean$presc_rate <- as.numeric(gsub(",", "", presc_clean$presc_rate))

# Convert Year to numeric so it can be used in panel construction and models.
presc_clean$Year <- as.numeric(presc_clean$Year)


# -----------------------------------
# 3. Clean illicit opioid death data
# -----------------------------------

# Repeat the same cleaning process for illicit opioid mortality data.
# Rename Crude.Rate to illicit_rate so the two outcomes are distinct.
illicit_clean <- illicit %>%
  select(State, Year, Crude.Rate) %>%
  rename(illicit_rate = Crude.Rate)

# Replace suppressed/unreliable values with NA.
illicit_clean$illicit_rate[illicit_clean$illicit_rate %in% bad_vals] <- NA

# Convert the crude rate to numeric.
illicit_clean$illicit_rate <- as.numeric(gsub(",", "", illicit_clean$illicit_rate))

# Convert Year to numeric.
illicit_clean$Year <- as.numeric(illicit_clean$Year)


# --------------------------------------
# 4. Build a complete state-year panel
# --------------------------------------

# Get all unique states and years from the prescription opioid dataset.
# These will define the full panel structure.
all_states <- sort(unique(presc_clean$State))
all_years  <- sort(unique(presc_clean$Year))

# Create every possible State x Year combination.
# This is useful for DiD because each state should have one row per year.
df_panel <- expand.grid(State = all_states, Year = all_years, stringsAsFactors = FALSE) %>%
  arrange(State, Year)

# Merge prescription and illicit opioid mortality outcomes into the panel.
# left_join keeps the full state-year panel even when some outcome values are missing.
df_panel <- df_panel %>%
  left_join(presc_clean, by = c("State", "Year")) %>%
  left_join(illicit_clean, by = c("State", "Year"))


# --------------------------
# 5. Check the panel quality
# --------------------------

# These checks help confirm that the panel was created correctly.
cat("Rows:", nrow(df_panel), "\n")
cat("Expected rows:", length(all_states) * length(all_years), "\n")
cat("Unique states:", length(unique(df_panel$State)), "\n")
cat("Year range:", paste(range(df_panel$Year, na.rm = TRUE), collapse = " to "), "\n")

# Check whether any State-Year combinations are duplicated.
cat("Duplicates:", any(duplicated(df_panel[, c("State", "Year")])), "\n")

# Count missing outcome values.
cat("Missing presc:", sum(is.na(df_panel$presc_rate)), "\n")
cat("Missing illicit:", sum(is.na(df_panel$illicit_rate)), "\n\n")


# -------------------------------------
# 6. Create year-level descriptive data
# -------------------------------------

# Compute average prescription and illicit opioid mortality rates by year.
# This is used for visualizing broad national trends before modeling.
df_summary <- df_panel %>%
  group_by(Year) %>%
  summarize(
    presc = mean(presc_rate, na.rm = TRUE),
    illicit = mean(illicit_rate, na.rm = TRUE),
    n_presc = sum(!is.na(presc_rate)),
    n_illicit = sum(!is.na(illicit_rate)),
    .groups = "drop"
  )


# -------------------------------
# 7. Plot average mortality trends
# -------------------------------

# Set the y-axis maximum based on both outcomes.
y_max <- max(df_summary$presc, df_summary$illicit, na.rm = TRUE)

# Plot average prescription opioid mortality over time.
plot(df_summary$Year, df_summary$presc, type = "l", lwd = 2,
     ylim = c(0, y_max),
     main = "Average Prescription vs Illicit Opioid Mortality",
     xlab = "Year", ylab = "Rate")

# Add illicit opioid mortality trend to the same plot.
lines(df_summary$Year, df_summary$illicit, col = "red", lwd = 2)

# Add legend.
legend("topleft",
       legend = c("Prescription opioids", "Illicit opioids"),
       col = c("black", "red"),
       lty = 1, lwd = 2, bty = "n")


# -------------------------
# 8. Load PDMP policy data
# -------------------------

# Load the PDMP law dataset.
# This contains policy adoption information by jurisdiction.
pdmp <- read_excel("~/Downloads/PDMP_Laws.xlsx", sheet = "Statistical Data")


# --------------------------------------
# 9. Create treatment adoption variable
# --------------------------------------

# PDMP_opchk indicates whether a PDMP mandate has opioid-specific provisions.
# The goal is to identify the first year each state adopted this opioid-specific mandate.
# This first adoption year is called G_i in staggered DiD notation.
pdmp_treatment <- pdmp %>%
  transmute(
    State = Jurisdictions,
    eff_date = as.Date(`Effective Date`),
    Year = year(eff_date),
    op_mandate = case_when(
      PDMP_opchk %in% c("1", 1) ~ 1,
      PDMP_opchk %in% c("0", 0) ~ 0,
      TRUE ~ NA_real_
    )
  ) %>%
  group_by(State) %>%
  summarize(
    G_i = ifelse(any(op_mandate == 1, na.rm = TRUE),
                 min(Year[op_mandate == 1], na.rm = TRUE),
                 NA_real_),
    .groups = "drop"
  )


# -----------------------------------------
# 10. Merge treatment timing into the panel
# -----------------------------------------

# Merge the first treatment year into the state-year panel.
# treated = 1 for years after adoption, and 0 before adoption.
# event_time measures years relative to treatment adoption.
df_main <- df_panel %>%
  left_join(pdmp_treatment, by = "State") %>%
  mutate(
    treated = ifelse(!is.na(G_i) & Year >= G_i, 1, 0),
    event_time = ifelse(!is.na(G_i), Year - G_i, NA_real_)
  )


# -----------------------------------
# 11. Inspect treatment timing
# -----------------------------------

# Print the first treatment year by state.
cat("Treatment timing\n")
df_main %>%
  distinct(State, G_i) %>%
  arrange(G_i, State)
cat("\n")

# Count how many states adopted in each year.
cat("Count of adoption years\n")
print(df_main %>% distinct(State, G_i) %>% count(G_i, sort = TRUE))
cat("\n")

# Count treated and untreated observations.
cat("Treated vs untreated observations\n")
print(table(df_main$treated, useNA = "ifany"))
cat("\n")


# --------------------------------------
# 12. Restrict to main analysis period
# --------------------------------------

# Restrict the sample to 2010 onward.
# This is done because illicit opioid mortality data are more complete after 2010.
df_analysis <- df_main %>%
  filter(Year >= 2010)

# Check missingness by year for each outcome.
print(
  df_analysis %>%
    group_by(Year) %>%
    summarize(
      missing_illicit = mean(is.na(illicit_rate)),
      missing_presc = mean(is.na(presc_rate)),
      .groups = "drop"
    )
)
cat("\n")


# -----------------------------------------------
# 13. Descriptive treated vs control group trends
# -----------------------------------------------

# Create ever_treated indicator:
# ever_treated = 1 if the state eventually adopts the policy.
# ever_treated = 0 if the state is never treated.
cat("Descriptive treated vs control trends\n")

print(
  df_analysis %>%
    mutate(ever_treated = ifelse(!is.na(G_i), 1, 0)) %>%
    group_by(Year, ever_treated) %>%
    summarize(
      illicit = mean(illicit_rate, na.rm = TRUE),
      presc = mean(presc_rate, na.rm = TRUE),
      .groups = "drop"
    )
)
cat("\n")


# ---------------------------------------------
# 14. Baseline Difference-in-Differences models
# ---------------------------------------------

# Estimate a two-way fixed effects DiD model for prescription opioid mortality.
# State fixed effects control for time-invariant differences across states.
# Year fixed effects control for national shocks common to all states.
# Standard errors are clustered by state because observations within a state
# are likely correlated over time.
model_presc <- feols(
  presc_rate ~ treated | State + Year,
  cluster = ~State,
  data = df_analysis
)

# Estimate the same model for illicit opioid mortality.
model_illicit <- feols(
  illicit_rate ~ treated | State + Year,
  cluster = ~State,
  data = df_analysis
)

# Print model results.
cat("The Baseline DiD for prescription outcome\n")
print(summary(model_presc))
cat("\n")

cat("Baseline DiD for illicit opioid outcome\n")
print(summary(model_illicit))
cat("\n")


# ----------------------------
# 15. Event-study specification
# ----------------------------

# Estimate an event-study model for illicit opioid mortality.
# The event_time coefficients show outcome differences in each year
# relative to the policy adoption year.
# ref = -1 means the year immediately before adoption is the reference period.
# Pre-treatment coefficients are used to assess whether treated states
# had different pre-trends before policy adoption.
model_event_illicit <- feols(
  illicit_rate ~ i(event_time, ref = -1) | State + Year,
  cluster = ~State,
  data = df_analysis
)

# Plot event-study coefficients.
iplot(model_event_illicit,
      main = "Event Study: Illicit Opioid Mortality",
      xlab = "Years relative to treatment",
      ylab = "Coefficient")


# --------------------------------
# 16. Restricted-window event study
# --------------------------------

# Restrict event time to five years before and after policy adoption.
# This reduces noise from very early or very late event-time periods,
# which may contain fewer observations.
df_restrict <- df_analysis %>%
  filter(event_time >= -5 & event_time <= 5)

# Estimate event-study model within the restricted window.
model_event_restrict <- feols(
  illicit_rate ~ i(event_time, ref = -1) | State + Year,
  cluster = ~State,
  data = df_restrict
)

# Plot restricted event-study coefficients.
iplot(model_event_restrict,
      main = "Restricted Event Study: Illicit Opioid Mortality",
      xlab = "Years relative to treatment",
      ylab = "Coefficient")


# ------------------------------------------
# 17. State-specific linear trend robustness
# ------------------------------------------

# Add a numeric year trend.
# This allows each state to have its own linear time trend in the robustness model.
df_analysis <- df_analysis %>%
  mutate(year_trend = Year)

# Estimate DiD model allowing each state to have its own linear trend.
# This checks whether the estimated policy effect is robust to different
# underlying state-level time trends.
model_trend_illicit <- feols(
  illicit_rate ~ treated + State:year_trend | State + Year,
  cluster = ~State,
  data = df_analysis
)

# Print robustness model.
cat("State-specific trend model for illicit outcome\n")
print(etable(model_trend_illicit))
cat("\n")


# ------------------------------------
# 18. Early-adopter robustness check
# ------------------------------------

# Keep only never-treated states and states treated by 2016.
# This robustness check focuses on earlier adopters and may reduce concerns
# that very late adopters differ systematically from earlier adopters.
df_early <- df_analysis %>%
  filter(is.na(G_i) | G_i <= 2016)

# Print treatment timing counts in the restricted sample.
print(df_early %>% distinct(State, G_i) %>% count(G_i, sort = TRUE))
cat("\n\n")

# Estimate baseline DiD model in the early-adopter sample.
model_early <- feols(
  illicit_rate ~ treated | State + Year,
  cluster = ~State,
  data = df_early
)

# Print results.
cat("Early adopter DiD for Illicit Outcome\n")
print(summary(model_early))
cat("\n\n\n")


# -----------------------------------------
# 19. Early-adopter event-study robustness
# -----------------------------------------

# Recalculate event time in the early-adopter sample.
df_early <- df_early %>%
  mutate(event_time = ifelse(!is.na(G_i), Year - G_i, NA_real_))

# Estimate event-study model in the early-adopter sample.
event_early <- feols(
  illicit_rate ~ i(event_time, ref = -1) | State + Year,
  cluster = ~State,
  data = df_early
)

# Plot early-adopter event-study coefficients.
iplot(event_early,
      main = "Early-Adopter Event Study: Illicit Opioid Mortality",
      xlab = "Years relative to treatment",
      ylab = "Coefficient")
