
suppressPackageStartupMessages({
  require(data.table)
})

.args <- if (interactive()) c(
  "data/owid.rds", "KEN", "results/KEN/result.rds"
) else commandArgs(trailingOnly = TRUE)

ref <- readRDS(.args[1])[iso_code == .args[2]]

res <- ref[
  # filter to just the row with max new cases smoothed
  which.max(new_cases_smoothed_per_million),
  # select the new_cases_... and date
  .(new_cases_smoothed_per_million, date)
]

saveRDS(res, tail(.args, 1))