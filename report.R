
suppressPackageStartupMessages({
  require(data.table)
})

.args <- if (interactive()) c(
  "results/consolidated.rds"
) else commandArgs(trailingOnly = TRUE)

cons.dt <- readRDS(.args[1])

cat(sprintf("%i of %i (%0.2g%%) finished first wave.",
  cons.dt[done_first == TRUE,.N], cons.dt[,.N], cons.dt[,sum(done_first)/.N*100]
))

cat(sprintf("%i have second wave (%i have terminated 2 or more waves).",
  cons.dt[have_second == TRUE,.N], cons.dt[done_more == TRUE,.N]
))
