
suppressPackageStartupMessages({
  require(data.table)
})

.args <- if (interactive()) c(
  "data/owid.rds", "data/isos.csv"
) else commandArgs(trailingOnly = TRUE)

dt <- readRDS(.args[1])[, .(
  pop = population[1],
  all_na = all(is.na(new_cases_smoothed_per_million)),
  neg_inc = any(new_cases_smoothed_per_million < 0, na.rm = TRUE),
  low_inc = all(new_cases_smoothed_per_million < 10, na.rm = TRUE),
  erratic_rep = median(new_cases, na.rm = T)  == 0
), keyby=.(iso=iso_code) ][nchar(iso)==3]

red1.dt <- dt[pop > 1e6]
warning(sprintf("excluding %i locales w/ < 1M pop:\n%s", dt[pop < 1e6, .N], dt[pop < 1e6, paste0(iso, collapse = "\n")]))
red2.dt <- red1.dt[all_na == FALSE]
warning(sprintf("excluding %i locales w/ no incidence data:\n%s", red1.dt[all_na == TRUE,.N], red1.dt[all_na == TRUE, paste0(iso, collapse = "\n")]))
red3.dt <- red2.dt[neg_inc == FALSE]
warning(sprintf("excluding %i locales w/ any negative 7-day-average incidence:\n%s", red2.dt[neg_inc == TRUE,.N],red2.dt[neg_inc == TRUE, paste0(iso, collapse = "\n")]))
red4.dt <- red3.dt[low_inc == FALSE]
warning(sprintf("excluding %i locales w/ too low incidence:\n%s", red3.dt[low_inc == TRUE,.N], red3.dt[low_inc == TRUE, paste0(iso, collapse = "\n")]))
red5.dt <- red4.dt[erratic_rep == FALSE]
warning(sprintf("excluding %i locales w/ at least half of daily reports being 0:\n%s", red4.dt[erratic_rep == TRUE,.N], red4.dt[erratic_rep == TRUE, paste0(iso, collapse = "\n")]))

fwrite(red5.dt[order(iso), .(iso)], tail(.args, 1), col.names = FALSE)