### Does the rate of change in total firearms background checks over time vary across states?

library(tidyverse)
library(lubridate)
library(tseries)
library(plotly)


nics_data <- read_csv("data/partial/nics-checks-last-five-years.csv",
                      col_types = cols(
                        month = col_character(),
                        state = col_character(),
                        .default = col_integer()
                      )
) |>
  mutate(
    month = ym(month),
    year  = year(month)
  )

# very naive messing around
state_totals <- nics_data |>
  select(month, state, totals) |>
  arrange(state, month)

# 1:10
state_totals |>
  filter(state %in% unique(state_totals$state)[1:10]) |>
  ggplot(aes(x = month, y = totals)) +
  geom_line(colour = "blue") +
  geom_smooth(method = "loess", se = FALSE,
              colour = "red") +
  facet_wrap(~state, scales = "free_y", ncol = 2) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme_bw()

# 11:20
state_totals |>
  filter(state %in% unique(state_totals$state)[11:20]) |>
  ggplot(aes(x = month, y = totals)) +
  geom_line(colour = "blue") +
  geom_smooth(method = "loess", se = FALSE,
              colour = "red") +
  facet_wrap(~state, scales = "free_y", ncol = 2) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme_bw()

# 21:30
state_totals |>
  filter(state %in% unique(state_totals$state)[21:30]) |>
  ggplot(aes(x = month, y = totals)) +
  geom_line(colour = "blue") +
  geom_smooth(method = "loess", se = FALSE,
              colour = "red") +
  facet_wrap(~state, scales = "free_y", ncol = 2) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme_bw()

# 31:40
state_totals |>
  filter(state %in% unique(state_totals$state)[31:40]) |>
  ggplot(aes(x = month, y = totals)) +
  geom_line(colour = "blue") +
  geom_smooth(method = "loess", se = FALSE,
              colour = "red") +
  facet_wrap(~state, scales = "free_y", ncol = 2) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme_bw()

# 41:50
state_totals |>
  filter(state %in% unique(state_totals$state)[41:50]) |>
  ggplot(aes(x = month, y = totals)) +
  geom_line(colour = "blue") +
  geom_smooth(method = "loess", se = FALSE,
              colour = "red") +
  facet_wrap(~state, scales = "free_y", ncol = 2) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme_bw()

# 51:55
state_totals |>
  filter(state %in% unique(state_totals$state)[51:55]) |>
  ggplot(aes(x = month, y = totals)) +
  geom_line(colour = "blue") +
  geom_smooth(method = "loess", se = FALSE,
              colour = "red") +
  facet_wrap(~state, scales = "free_y", ncol = 1) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme_bw()

# Aggregate figures

# Reading in some more data
annual_gross_pop <- read_csv("data/other_sources/population/POPTOTUSA647NWDB.csv") |>
  rename(pop = POPTOTUSA647NWDB) |>
  mutate(year = year(observation_date)) |>
  select(-c(observation_date))

nics_participation <- readRDS("data/other_sources/nics_participation.RDS")

state_pop_2000_2023 <- readRDS("data/other_sources/population/state_pop_2000_2023.RDS")

# actual plots
nics_data |>
  group_by(year) |>
  summarise(avg_firearms = mean(totals)) |>
  left_join(annual_gross_pop, by = "year") |>
  mutate(pop = (pop)/8378.675) |>
  ggplot(aes(x = year, y = avg_firearms)) +
  geom_point(colour = "blue") +
  geom_smooth(method = "loess", se = FALSE,
              colour = "red") +
  geom_smooth(aes(x = year, y = pop), colour = "green")
# Here we can see the last 5 years of population growth, and aggregate firearms change

nics_data |>
  group_by(month) |>
  summarise(avg_firearms = mean(totals)) |>
  ggplot(aes(x = month, y = avg_firearms)) +
  geom_point(colour = "blue") +
  geom_smooth(method = "loess", se = FALSE,
              colour = "red")
# Rather than just annual summaries, here we have 1 point per month and a a smooth

nics_data |>
  left_join(state_pop_2000_2023, by = c("year", "state")) |>
  mutate(total_checks_per_thousand = totals/(population/1000)) |>
  left_join(nics_participation, by = "state") |>
  ggplot(aes(x = month, y = total_checks_per_thousand, colour = participation)) +
  geom_point() +
  geom_smooth()
# 

nics_data |>
  left_join(state_pop_2000_2023, by = c("year", "state")) |>
  left_join(nics_participation, by = "state") |>
  arrange(state, month) |>
  group_by(state) |>
  mutate(pct_change = (totals - lag(totals)) / lag(totals) * 100) |>
  filter(abs(pct_change) < 500) |> # big outlier
  ungroup() |>
  ggplot(aes(x = month, y = pct_change, group = participation, colour = participation)) +
  geom_point(alpha = 0.9) +
  geom_smooth() +
  labs(y = "Month-on-Month Change in Checks (%)", x = "Month")

nics_data |>
  left_join(state_pop_2000_2023, by = c("year", "state")) |>
  left_join(nics_participation, by = "state") |>
  arrange(state, month) |>
  group_by(state) |>
  mutate(diff_checks = totals - lag(totals)) |>
  ungroup() |>
  ggplot(aes(x = month, y = diff_checks, group = participation, colour = participation)) +
  geom_point(alpha = 0.9) +
  geom_smooth() +
  labs(y = "First Difference in Total Checks", x = "Month")

nics_data |>
  left_join(state_pop_2000_2023, by = c("year", "state")) |>
  left_join(nics_participation, by = "state") |>
  mutate(checks_per_thousand = totals / (population / 1000)) |>
  arrange(state, month) |>
  group_by(state) |>
  mutate(diff_checks_per_thousand = checks_per_thousand - lag(checks_per_thousand)) |>
  ungroup() |>
  ggplot(aes(x = month, y = diff_checks_per_thousand, group = state, colour = participation)) +
  geom_point(alpha = 0.9) +
  geom_smooth()

nics_data |>
  left_join(state_pop_2000_2023, by = c("year", "state")) |>
  left_join(nics_participation, by = "state") |>
  filter(!is.na(participation)) |>
  arrange(state, month) |>
  group_by(state) |>
  mutate(checks_per_thousand = totals / (population / 1000),
         movement = checks_per_thousand - first(checks_per_thousand)) |>
  ungroup() |>
  ggplot(aes(x = month, y = movement, group = state, colour = participation)) +
  geom_line(alpha = 0.6, linewidth = 0.4) +
  theme(legend.position = "none") +
  facet_wrap(~ participation, ncol = 2)

big_nics_data <- read_csv("data/nics-firearm-background-checks.csv",
                          col_types = cols(
                            month = col_character(),
                            state = col_character(),
                            .default = col_integer()
                          )
) |>
  mutate(
    month = ym(month),
    year  = year(month)
  )

big_nics_data |>
  left_join(state_pop_2000_2023, by = c("year", "state")) |>
  left_join(nics_participation, by = "state") |>
  filter(!is.na(participation),
         !is.na(population),
         !is.na(totals)) |>
  arrange(state, month) |>
  group_by(state) |>
  mutate(checks_per_thousand = totals / (population / 1000),
         movement = checks_per_thousand - first(checks_per_thousand)) |>
  ungroup() |>
  ggplot(aes(x = month, y = movement, group = state, colour = participation)) +
  geom_line(alpha = 0.6, linewidth = 0.4) +
  theme_minimal() +
  theme(legend.position = "none") +
  facet_wrap(~ participation, ncol = 2)

highlight_states <- c("Kentucky", "Illinois", "Utah", "Indiana", "North Carolina")

label_positions <- tibble::tribble(
  ~state,            ~label_x,               ~label_y,
  "Kentucky",        as.Date("2016-01-01"),   95,
  "Illinois",        as.Date("2018-08-01"),   90,
  "Utah",            as.Date("2010-04-01"),   60,
  "Indiana",         as.Date("2017-04-01"),   45,
  "North Carolina",  as.Date("2011-01-01"),   65
)

plot_data <- big_nics_data |>
  left_join(state_pop_2000_2023, by = c("year", "state")) |>
  left_join(nics_participation, by = "state") |>
  filter(!is.na(participation),
         !is.na(population),
         !is.na(totals)) |>
  arrange(state, month) |>
  group_by(state) |>
  mutate(
    checks_per_thousand = totals / (population / 1000),
    movement = checks_per_thousand - first(checks_per_thousand)
  ) |>
  ungroup() |>
  mutate(highlight = state %in% highlight_states)

# Join participation group onto label_positions so faceting works correctly
label_data <- label_positions |>
  left_join(
    plot_data |> distinct(state, participation),
    by = "state"
  )

highlight_colours <- c(
  "Kentucky"       = "#E63946",
  "Illinois"       = "#F4A261",
  "Utah"           = "#2A9D8F",
  "Indiana"        = "#457B9D",
  "North Carolina" = "#8338EC"
)

ggplot() +
  geom_line(
    data = filter(plot_data, !highlight),
    aes(x = month, y = movement, group = state, colour = participation),
    alpha = 0.6, linewidth = 0.4
  ) +
  geom_line(
    data = filter(plot_data, highlight),
    aes(x = month, y = movement, group = state, colour = state),
    alpha = 0.9, linewidth = 0.7
  ) +
  geom_text(
    data = label_data,
    aes(x = label_x, y = label_y, label = state, colour = state),
    size = 2.5, hjust = 0
  ) +
  scale_colour_manual(
    values = highlight_colours,
    na.value = "grey60"   # fallback for participation-coloured non-highlight lines
  ) +
  theme_minimal() +
  theme(legend.position = "none") +
  facet_wrap(~ participation, ncol = 2)

p <- big_nics_data |>
  left_join(state_pop_2000_2023, by = c("year", "state")) |>
  left_join(nics_participation, by = "state") |>
  filter(!is.na(participation),
         !is.na(population),
         !is.na(totals),
         !state %in% c("Kentucky", "Illinois", "Utah", "Indiana", "North Carolina")) |>
  arrange(state, month) |>
  group_by(state) |>
  mutate(checks_per_thousand = totals / (population / 1000),
         movement = checks_per_thousand - first(checks_per_thousand)) |>
  ungroup() |>
  ggplot(aes(x = month, y = movement, group = state, 
             colour = participation, text = state)) +   # <-- text = state for tooltip
  geom_line(alpha = 0.6, linewidth = 0.4) +
  theme_minimal() +
  theme(legend.position = "none") +
  facet_wrap(~ participation, ncol = 2)

ggplotly(p, tooltip = "text") 


big_nics_data |>
  left_join(state_pop_2000_2023, by = c("year", "state")) |>
  left_join(nics_participation, by = "state") |>
  filter(!is.na(participation),
         !is.na(population),
         !is.na(totals),
         !state %in% c("Kentucky", "Illinois", "Utah", "Indiana", "North Carolina")) |>
  arrange(state, month) |>
  group_by(state) |>
  mutate(checks_per_thousand = totals / (population / 1000),
         movement = checks_per_thousand - first(checks_per_thousand)) |>
  ungroup() |>
  ggplot(aes(x = month, y = movement, colour = participation)) +
  geom_line(aes(group = state), alpha = 0.3, linewidth = 0.4) +
  geom_smooth(aes(group = participation), linewidth = 1.2,
              se = TRUE, colour = "red") +
  theme_minimal() +
  theme(legend.position = "none") +
  facet_wrap(~ participation, ncol = 2)









# seperate yoke.


nics <- read_csv("data/nics-firearm-background-checks.csv") |>
  mutate(date = ym(month), year = year(date))

state_pop        <- readRDS("data/other_sources/population/state_pop_2000_2023.RDS")
nics_participation <- readRDS("data/other_sources/nics_participation.RDS")

us_states <- c(state.name, "District of Columbia")

annual_pop <- nics |>
  filter(state %in% us_states, year >= 2000, year <= 2023) |>
  group_by(state, year) |>
  summarise(annual_total = sum(totals, na.rm = TRUE), .groups = "drop") |>
  left_join(state_pop, by = c("state", "year")) |>
  left_join(nics_participation, by = "state") |>
  mutate(checks_per_100k = (annual_total / population) * 1e5) |>
  filter(!is.na(checks_per_100k), checks_per_100k > 0)

segment_levels <- c("2000–2005", "2006–2011", "2012–2017", "2018–2023")

annual_pop <- annual_pop |>
  mutate(
    checks_per_1k = (annual_total / population) * 1000,
    segment = case_when(
      year %in% 2000:2005 ~ "2000–2005",
      year %in% 2006:2011 ~ "2006–2011",
      year %in% 2012:2017 ~ "2012–2017",
      year %in% 2018:2023 ~ "2018–2023",
      TRUE                ~ NA_character_
    )
  ) |>
  filter(!is.na(segment), checks_per_1k > 0) |>
  mutate(segment = factor(segment, levels = segment_levels))

segment_slopes <- annual_pop |>
  group_by(state, segment) |>
  nest() |>
  mutate(
    fit    = map(data, \(d) lm(checks_per_1k ~ year, data = d)),
    tidied = map(fit,  \(m) tidy(m, conf.int = TRUE))
  ) |>
  unnest(tidied) |>
  filter(term == "year") |>
  select(state, segment,
         slope = estimate, se = std.error,
         conf.low, conf.high, p.value) |>
  ungroup()

ftest_results <- annual_pop |>
  group_by(state) |>
  nest() |>
  mutate(
    mod_full    = map(data, \(d) lm(checks_per_1k ~ year * segment, data = d)),
    mod_reduced = map(data, \(d) lm(checks_per_1k ~ year + segment, data = d)),
    anova_res   = map2(mod_reduced, mod_full, anova),
    anova_tidy  = map(anova_res, tidy)
  ) |>
  unnest(anova_tidy) |>
  filter(!is.na(p.value)) |>          # row 2 of anova() — the F-test row
  select(state, df, statistic, p.value) |>
  mutate(
    significant = p.value < 0.05,
    sig_label   = if_else(significant, "Significant (p < 0.05)", "Not Significant")
  ) |>
  ungroup()

# looking at significant states
sig_states <- ftest_results |> filter(significant) |> pull(state)
traj_states <- c(sig_states, setdiff(unique(segment_slopes$state), sig_states))

traj_data <- segment_slopes |>
  mutate(
    state = factor(state, levels = traj_states),
    segment = factor(segment, levels = segment_levels),
    slope_z = as.numeric(scale(slope))
  )

ggplot(traj_data, aes(x = segment, y = slope_z, group = 1)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey55", linewidth = 0.4) +
  geom_errorbar(aes(ymin = as.numeric(scale(conf.low)), ymax = as.numeric(scale(conf.high))),
                width = 0.15, alpha = 0.45, linewidth = 0.5) +
  geom_line(aes(colour = if_else(state %in% sig_states, "Significant", "Other")),
            linewidth = 0.7) +
  geom_point(aes(colour = if_else(state %in% sig_states, "Significant", "Other")),
             size = 2) +
  facet_wrap(~ state, ncol = 3) +
  scale_colour_manual(values = c("Significant" = "red", "Other" = "grey40"), guide = "none") +
  labs(
    title = "Slope Trajectories Across Segments",
    subtitle = "Slopes standardized to a common scale; significant states shown in red",
    x = NULL,
    y = "Standardized slope (z-score)",
    caption = "Source: FBI NICS"
  ) +
  theme_minimal(base_size = 9) +
  theme(
    strip.text = element_text(face = "bold", size = 8),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    panel.grid.minor = element_blank(),
    plot.title = element_text(face = "bold", size = 12)
  )
