library(tidyverse)
library(lubridate)

# Weird behavior in Utah within this time frame, we wanted to take a closer look.
# Read and clean
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

utah_key_dates <- nics_data |>
  filter(state == "Utah") |>
  filter(month > ymd("2010-09-01")) |>
  filter(month < ymd("2013-09-01"))

write.csv(utah_key_dates, file = "UTAH.csv")
