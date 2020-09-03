
suppressPackageStartupMessages({
  require(data.table)
})

.args <- if (interactive()) c(
  "data/owid.rds"
) else commandArgs(trailingOnly = TRUE)

owidurl <- "https://covid.ourworldindata.org/data/owid-covid-data.csv"

dt <- fread(owidurl)

saveRDS(dt, tail(.args, 1))