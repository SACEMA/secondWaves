
suppressPackageStartupMessages({
  require(data.table)
})

.args <- if (interactive()) c(
  "results", "results/consolidated.rds"
) else commandArgs(trailingOnly = TRUE)

fls <- list.files(.args[1], "stats\\.rds$", recursive = TRUE, full.names = TRUE)

patsubst <- sprintf("%s/(\\w{3})/stats\\.rds", .args[1])

res <- rbindlist(lapply(
  fls, function(fl) {
    readRDS(fl)[, iso := gsub(patsubst, "\\1", fl)]
  }
))

saveRDS(res, tail(.args, 1))