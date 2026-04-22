# Adi's relevant code
# ── Libraries ──────────────────────────────────────────────────────────────────
library(tidyverse)

# ── Data In ────────────────────────────────────────────────────────────────────
df <- read_csv("data/nics-firearm-background-checks.csv")

# ── Transformations ────────────────────────────────────────────────────────────

# Permit vs. Sales-like checks by state
df_compare <- df |>
  mutate(
    permit_total = permit + permit_recheck,
    sales_total  = handgun + long_gun + other + multiple
  ) |>
  group_by(state) |>
  summarise(
    permit = sum(permit_total, na.rm = TRUE),
    sales  = sum(sales_total,  na.rm = TRUE)
  ) |>
  pivot_longer(cols = c(permit, sales), names_to = "type", values_to = "value")

# US-level trend over time
us_trend <- df |>
  mutate(month = as.Date(paste0(month, "-01"))) |>
  group_by(month) |>
  summarise(total_checks = sum(totals, na.rm = TRUE)) |>
  ungroup()

# ── Plotting ───────────────────────────────────────────────────────────────────

# Plot 1: Permit vs Sales-like checks by state
df_compare |>
  ggplot(aes(x = reorder(state, value), y = value, fill = type)) +
  geom_col(position = "dodge") +
  coord_flip() +
  labs(
    title = "Permit vs Sales-like Checks by State",
    x     = "State",
    y     = "Count"
  ) +
  theme_minimal()

# Plot 2: US firearm background checks over time
us_trend |>
  ggplot(aes(x = month, y = total_checks)) +
  geom_line() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "US Firearm Background Checks Over Time",
    y     = "Total Checks",
    x     = "Year"
  ) +
  theme_minimal()
