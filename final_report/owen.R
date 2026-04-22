# Owen's relevant code
# ── Libraries ──────────────────────────────────────────────────────────────────
library(tidyverse)
library(lubridate)

# ── Data In ────────────────────────────────────────────────────────────────────
nics               <- read_csv("data/nics-firearm-background-checks.csv") |>
  mutate(date = ym(month), year = year(date))
state_pop          <- readRDS("data/other_sources/population/state_pop_2000_2023.RDS")

# ── Transformations ────────────────────────────────────────────────────────────
us_states      <- c(state.name, "District of Columbia")
segment_levels <- c("2000–2005", "2006–2011", "2012–2017", "2018–2023")
bad_states     <- c("Kentucky", "Illinois", "Utah", "Indiana", "North Carolina", "California", "North Dakota")

annual_pop <- nics |>
  filter(state %in% us_states, year >= 2000, year <= 2023) |>
  group_by(state, year) |>
  summarise(annual_total = sum(totals, na.rm = TRUE), .groups = "drop") |>
  left_join(state_pop, by = c("state", "year")) |>
  mutate(
    checks_per_100k = (annual_total / population) * 1e5,
    checks_per_1k   = (annual_total / population) * 1000,
    segment = case_when(
      year %in% 2000:2005 ~ "2000–2005",
      year %in% 2006:2011 ~ "2006–2011",
      year %in% 2012:2017 ~ "2012–2017",
      year %in% 2018:2023 ~ "2018–2023",
      TRUE                ~ NA_character_
    )
  ) |>
  filter(!is.na(checks_per_100k), checks_per_100k > 0,
         !is.na(segment), checks_per_1k > 0) |>
  mutate(segment = factor(segment, levels = segment_levels))

extract_slope <- function(d) {
  fit <- lm(checks_per_1k ~ year, data = d)
  cf  <- coef(summary(fit))
  ci  <- confint(fit)
  tibble(
    slope    = cf["year", "Estimate"],
    se       = cf["year", "Std. Error"],
    conf.low = ci["year", 1],
    conf.high = ci["year", 2],
    p.value  = cf["year", "Pr(>|t|)"]
  )
}

segment_slopes <- annual_pop |>
  group_by(state, segment) |>
  nest() |>
  mutate(tidied = purrr::map(data, extract_slope)) |>
  unnest(tidied) |>
  select(state, segment, slope, se, conf.low, conf.high, p.value) |>
  ungroup()

run_ftest <- function(d) {
  mod_full    <- lm(checks_per_1k ~ year * segment, data = d)
  mod_reduced <- lm(checks_per_1k ~ year + segment, data = d)
  av <- anova(mod_reduced, mod_full)
  tibble(
    df        = av$Df[2],
    statistic = av$F[2],
    p.value   = av$'Pr(>F)'[2]
  )
}

ftest_results <- annual_pop |>
  group_by(state) |>
  nest() |>
  mutate(res = purrr::map(data, run_ftest)) |>
  unnest(res) |>
  select(state, df, statistic, p.value) |>
  mutate(
    significant = p.value < 0.05,
    sig_label   = if_else(significant, "Significant (p < 0.05)", "Not Significant")
  ) |>
  ungroup()

good_sig_states <- ftest_results |>
  filter(significant, !state %in% bad_states)

# ── Output ─────────────────────────────────────────────────────────────────────
n_sig <- sum(ftest_results$significant)
n_tot <- nrow(ftest_results)

cat(n_sig, "of", n_tot, "terratories show significantly different slopes across segments (α = 0.05)")

ftest_results |>
  filter(significant) |>
  arrange(p.value) |>
  select(State = state, 'F-statistic' = statistic, 'p-value' = p.value) |>
  mutate(across(where(is.numeric), \(x) round(x, 4))) |>
  print(n = Inf)

segment_slopes |>
  filter(state %in% good_sig_states$state) |>
  ggplot(aes(x = segment, y = slope, group = state, colour = state)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey55", linewidth = 0.5) +
  geom_errorbar(aes(ymin = conf.low, ymax = conf.high), width = 0.25, alpha = 0.5) +
  geom_line() +
  geom_point(size = 2) +
  facet_wrap(~ state, scales = "free_y", ncol = 3) +
  labs(x = "", y = "rate of change of firearmchecks/1000", title = "Slopes for final candidiates") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
