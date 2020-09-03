
suppressPackageStartupMessages({
  require(data.table)
})

.args <- if (interactive()) c(
  "data/owid.rds", "data/isos.csv"
) else commandArgs(trailingOnly = TRUE)

dt <- readRDS(.args[1])[,.(iso=unique(iso_code))][nchar(iso)==3][order(iso)]

fwrite(dt, tail(.args, 1), col.names = FALSE)