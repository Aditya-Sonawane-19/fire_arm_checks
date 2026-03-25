library(tidyverse)
library(lubridate)

nics_data <- read_csv("data/nics-firearm-background-checks.csv",
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

# yearly aggregates
nics_data |>
  group_by(year) |>
  summarise(total_checks = sum(totals, na.rm = TRUE))
