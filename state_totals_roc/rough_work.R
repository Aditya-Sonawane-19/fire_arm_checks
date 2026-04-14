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

nics_data |>
  group_by(month) |>
  summarise(avg_firearms = mean(totals)) |>
  ggplot(aes(x = month, y = avg_firearms)) +
  geom_point(colour = "blue") +
  geom_smooth(method = "loess", se = FALSE,
              colour = "red")

nics_data |>
  left_join(state_pop_2000_2023, by = c("year", "state")) |>
  mutate(total_checks_per_thousand = totals/(population/1000)) |>
  left_join(nics_participation, by = "state") |>
  ggplot(aes(x = month, y = total_checks_per_thousand, colour = participation)) +
  geom_point() +
  geom_smooth()

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

p <- big_nics_data |>
  left_join(state_pop_2000_2023, by = c("year", "state")) |>
  left_join(nics_participation, by = "state") |>
  filter(!is.na(participation),
         !is.na(population),
         !is.na(totals),
         !state %in% c("Kentucky", "Illinois", "Utah", "Indiana"))) |>
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

