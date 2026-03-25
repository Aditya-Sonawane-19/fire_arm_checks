### Does the rate of change in total firearms background checks over time vary across states?
  
library(tidyverse)
library(lubridate)
library(tseries)


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

