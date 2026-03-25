library(tidyverse)
library(lubridate)
library(naniar)
library(grid)

# Read and clean
nics_last_five_years_data <- read_csv("data/partial/nics-checks-last-five-years.csv",
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

# Missing-ness plot
missingness <- vis_miss(nics_last_five_years_data, sort_miss = TRUE) +
  theme(
    axis.text.x = element_text(size = 9, angle = 90),
    axis.text.y = element_text(size = 8, angle = 90),
    legend.text = element_text(angle = 90)
  )

print(missingness, vp = viewport(angle = 270, width = 0.8, height = 0.8))

# Upset plot - THERE IS NONE!
gg_miss_upset(nics_last_five_years_data)
