
suppressPackageStartupMessages({
  require(data.table)
  require(dplyr)
})

.args <- if (interactive()) c(
  "data/usdat.rds"
) else commandArgs(trailingOnly = TRUE)

usdaturl <- "https://covidtracking.com/data/download/all-states-history.csv"

dt <- fread(usdaturl)
head(dt)

sts <- data.frame(name = c(state.name,'District of Columbia', 'Puerto Rico'), abb = c(state.abb, 'DC', 'PR'))
# Source: https://www2.census.gov/programs-surveys/popest/tables/2010-2019/state/totals/nst-est2019-01.xlsx
pop <- readxl::read_xlsx('./data/nst-est2019-01.xlsx', sheet = 2) # Census bureau population estimates for 2019-07-01
pop$name <- substr(pop$name, 2, nchar(pop$name))
pop <- left_join(sts, pop, by = 'name')

dt <- left_join(dt, pop, by = c('state' = 'abb')) %>% filter(!is.na(population), population >= 1000000)

dt <- (dt
       %>% rename(location = state
                  , total_cases = positiveCasesViral
                  , total_tests = totalTestsViral
                  , new_tests = totalTestsViralIncrease
                  , total_positive_tests = positiveTestsViral
                  , total_deaths = deathConfirmed # use `death` for confirmed plus probable
                  )
       %>% arrange(date)
       %>% group_by(location)
       %>% mutate(iso_code = paste('US', location, sep = '-')
                  # , check_dates = diff(c(NA, date)) # verify that no implicit missing dates
                  , new_cases = diff(c(0, total_cases)) # NA or 0?
                  , new_cases_smoothed = zoo::rollmeanr(new_cases, k = 7, fill = NA)
                  , new_positive_tests = diff(c(0, total_positive_tests))
                  , positive_rate = new_positive_tests / new_tests
                  , positive_rate_smoothed = zoo::rollmeanr(positive_rate, k = 7, fill = NA)
                  , new_tests_smoothed = zoo::rollmeanr(new_tests, k = 7, fill = NA)
                  , new_deaths = diff(c(0, total_deaths))
                  , new_deaths_smoothed = zoo::rollmeanr(new_deaths, k = 7, fill = NA)
                  )
       %>% ungroup()
       %>% mutate(total_cases_per_million = total_cases / population * 1000000
                  , new_cases_smoothed_per_million = new_cases_smoothed / population * 1000000
                  , total_tests_per_thousand = total_tests / population * 1000
                  , new_tests_smoothed_per_thousand = new_tests_smoothed / population * 1000
                  , total_deaths_per_million = total_deaths / population * 1000000
                  , new_deaths_smoothed_per_million = new_deaths_smoothed / population * 1000000
       )
)

saveRDS(dt, tail(.args, 1))