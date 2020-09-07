
suppressPackageStartupMessages({
  require(data.table)
})

.args <- if (interactive()) c(
  "data/owid.rds", "data/isos.csv"
) else commandArgs(trailingOnly = TRUE)

dt <- readRDS(.args[1])[, .(
  pop = population[1],
  all_na = all(is.na(new_cases_smoothed_per_million)),
  neg_inc = any(new_cases_smoothed_per_million < 0, na.rm = TRUE)
#  , low_test = { v <- max(total_tests_per_thousand, na.rm = T); is.finite(v) & (v <= 10) }
), keyby=.(iso=iso_code) ][nchar(iso)==3]

red1.dt <- dt[pop > 1e6]
warning(sprintf("excluding locales w/ < 1M pop:\n%s", dt[pop < 1e6, paste0(iso, collapse = "\n")]))
red2.dt <- red1.dt[all_na == FALSE]
warning(sprintf("excluding locales w/ no incidence data:\n%s", red1.dt[all_na == TRUE, paste0(iso, collapse = "\n")]))
red3.dt <- red2.dt[neg_inc == FALSE]
warning(sprintf("excluding locales w/ any negative 7-day-average incidence:\n%s", red2.dt[neg_inc == TRUE, paste0(iso, collapse = "\n")]))

fwrite(red3.dt[order(iso), .(iso)], tail(.args, 1), col.names = FALSE)