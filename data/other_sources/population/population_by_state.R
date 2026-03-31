# I believe it may be good to make considerations of populations levels alongside these figures.
# This will allow us to get permit-per-person figures, a more common scale we can use to compare across states.
# My previous inclusion of population figures was at an aggregate national level, I'd like it to be at state level.

# to do this I started as such:

# This time I went to census.gov and used an assortment of files to find the necessary data. to cover 1998 to 2023 I looked here:
# https://www2.census.gov/programs-surveys/popest/datasets/1990-2000/intercensal/national/
#   us-est90int-07-1998
#   us-est90int-07-1999
#   This data is actually just such a pain to deal with that I'm not going to.

# https://www2.census.gov/programs-surveys/popest/datasets/2000-2010/intercensal/state/
#   st-est00int-alldata
# https://www2.census.gov/programs-surveys/popest/datasets/2010-2020/state/totals/
#   nst-est2020
# https://www2.census.gov/programs-surveys/popest/datasets/2020-2025/state/totals/
#   NST-EST2025-POPCHG2020-2025

library(tidyverse)
raw_2020_2025 <- read_csv("data/other_sources/population/NST-EST2025-POPCHG2020-2025.csv")
raw_2010_2020 <- read_csv("data/other_sources/population/nst-est2020.csv")
raw_2000_2010 <- read_csv("data/other_sources/population/st-est00int-alldata.csv")

clean_2021_2023 <- raw_2020_2025 |>
  filter(SUMLEV == "040") |>
  select(
    Region = NAME,
    "2021_pop" = POPESTIMATE2021,
    "2022_pop" = POPESTIMATE2022,
    "2023_pop" = POPESTIMATE2023
  )

clean_2010_2020 <- raw_2010_2020 |>
  filter(SUMLEV == "040") |>
  select(
    Region = NAME,
    "2010_pop" = POPESTIMATE2010,
    "2011_pop" = POPESTIMATE2011,
    "2012_pop" = POPESTIMATE2012,
    "2013_pop" = POPESTIMATE2013,
    "2014_pop" = POPESTIMATE2014,
    "2015_pop" = POPESTIMATE2015,
    "2016_pop" = POPESTIMATE2016,
    "2017_pop" = POPESTIMATE2017,
    "2018_pop" = POPESTIMATE2018,
    "2019_pop" = POPESTIMATE2019,
    "2020_pop" = POPESTIMATE2020
  )

clean_2000_2009 <- raw_2000_2010 %>%
  filter(
    STATE != 0,
    SEX    == 0,
    ORIGIN == 0,
    RACE   == 0,
    AGEGRP == 0
  ) |>
  select(
    Region = NAME,
    "2000_pop" = POPESTIMATE2000,
    "2001_pop" = POPESTIMATE2001,
    "2002_pop" = POPESTIMATE2002,
    "2003_pop" = POPESTIMATE2003,
    "2004_pop" = POPESTIMATE2004,
    "2005_pop" = POPESTIMATE2005,
    "2006_pop" = POPESTIMATE2006,
    "2007_pop" = POPESTIMATE2007,
    "2008_pop" = POPESTIMATE2008,
    "2009_pop" = POPESTIMATE2009
  )

state_pop_2000_2023 <- clean_2000_2009 |>
  left_join(clean_2010_2020, by = "Region") |>
  left_join(clean_2021_2023, by = "Region") |>
  pivot_longer(
    cols      = -Region,
    names_to  = "year",
    values_to = "population"
  ) |>
  mutate(year = as.integer(str_remove(year, "_pop")))

# Can used the clean data later without all this hassle.
saveRDS(state_pop_2000_2023, file = "data/other_sources/population/state_pop_2000_2023.RDS")

state_pop_2000_2023 |>
  ggplot(aes(x = year, y = log(population), group = Region)) +
  geom_point()
