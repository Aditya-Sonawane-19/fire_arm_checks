# Kate's relevant code
# ── Libraries ──────────────────────────────────────────────────────────────────
library(tidyverse)
library(plotly)

# ── Data In ────────────────────────────────────────────────────────────────────
nics_checks_last_five_years <- read_csv("data/partial/nics-checks-last-five-years.csv")
us_map <- map_data("state")

# ── Transformations ────────────────────────────────────────────────────────────
nics_checks_last_five_years <- nics_checks_last_five_years |>
  mutate(state = tolower(state))

state_permit_totals <- nics_checks_last_five_years |>
  group_by(state) |>
  summarise(total_permit = sum(permit))

state_rechecks_totals <- nics_checks_last_five_years |>
  group_by(state) |>
  summarise(total_rechecks = sum(permit_recheck))

map_permits <- us_map |>
  left_join(state_permit_totals, by = c("region" = "state")) |>
  mutate(scaled_values = 2 * (percent_rank(log10(total_permit + 1)) - 0.5))

map_rechecks <- us_map |>
  left_join(state_rechecks_totals, by = c("region" = "state")) |>
  mutate(scaled_values = 2 * (percent_rank(log10(total_rechecks + 1)) - 0.5))

# ── Plotting ───────────────────────────────────────────────────────────────────
g3 <- ggplot(map_permits, aes(x = long, y = lat, group = group, fill = scaled_values,
                              text = paste("State:", region, "<br>Permits:", total_permit))) +
  geom_polygon(color = "white") +
  scale_fill_gradient2(
    low = "blue",
    mid = "white",
    high = "red",
    midpoint = 0) +
  labs(
    title = "Total Firearm Permits by State",
    fill = "permits") +
  theme_dark()

ggplotly(g3, tooltip = "text")

g4 <- ggplot(map_rechecks, aes(x = long, y = lat, group = group, fill = scaled_values,
                               text = paste("State:", region, "<br>Permit rechecks:", total_rechecks))) +
  geom_polygon(color = "white") +
  scale_fill_gradient2(
    low = "red",
    mid = "white",
    high = "blue",
    midpoint = 0) +
  labs(
    title = "Total Firearm Permits rechecks by State",
    fill = "permit rechecks") +
  theme_dark()

ggplotly(g4, tooltip = "text")