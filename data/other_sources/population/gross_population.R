# I believe it may be good to make considerations of populations levels alongside these figures.
# This will allow us to get permit-per-person figures, a more common scale we can use to compare across years at a national level.

# to do this I started as such:

library(tidyverse)
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

# max(nics_data$year) # 2023
# min(nics_data$year) # 1998


# This informed me that in our most complete data the range is from 1998 to 2023
# I then went to https://fred.stlouisfed.org/series/POPTOTUSA647NWDB (first relevant result via google search)
# I inputted the range and downloaded the relevant data as a csv.

annual_gross_pop <- read_csv("data/other_sources/POPTOTUSA647NWDB.csv") |>
  rename(pop = POPTOTUSA647NWDB) |>
  mutate(year = year(observation_date)) |>
  select(-c(observation_date))
head(annual_gross_pop)

nics_joined <- nics_data |>
  left_join(annual_gross_pop, by = "year")
head(nics_joined)




# Which enables stuff like this:
mock_summary <- nics_joined |>
  group_by(year) |>
  summarise(
    total_checks      = sum(totals, na.rm = TRUE),
    pop               = first(pop)
  ) |>
  mutate(avg_checks_p1000 = total_checks / (pop / 1000))

mock_summary_by_state <- nics_joined |>
  group_by(year, state) |>
  summarise(
    total_checks = sum(totals, na.rm = TRUE),
    pop          = first(pop),
    .groups      = "drop"
  ) |>
  mutate(avg_checks_p1000 = total_checks / (pop / 1000))

mock_summary_by_state |>
  ggplot(aes(x = year, y = avg_checks_p1000, colour = state)) +
  geom_point()
