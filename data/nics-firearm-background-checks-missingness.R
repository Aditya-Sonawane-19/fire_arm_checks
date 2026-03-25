library(tidyverse)
library(lubridate)
library(naniar)
library(grid)

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

# Missing-ness plot
missingness <- vis_miss(nics_data, sort_miss = TRUE) +
  theme(
    axis.text.x = element_text(size = 9, angle = 90),
    axis.text.y = element_text(size = 8, angle = 90),
    legend.text = element_text(angle = 90)
  )

print(missingness, vp = viewport(angle = 270, width = 0.8, height = 0.8))

# Upset plot
gg_miss_upset(nics_data)


# What these plots and the plots in the partial directory tell us is that most
# data that is missing is missing because it wasn't being recorded years ago.
# Within the last 5 years the data is complete, but before then there were 
# fields that weren't recorded. This aligns with our prior expectation.