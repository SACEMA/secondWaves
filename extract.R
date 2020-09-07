
suppressPackageStartupMessages({
  require(data.table)
})

.debug <- "ZAF"
.args <- if (interactive()) sprintf(c(
  "results/%s/result.rds", "results/%s/stats.rds"
), .debug) else commandArgs(trailingOnly = TRUE)

annotated.dt <- readRDS(.args[1])

waves <- annotated.dt[
  range_annotation %in% c("endwave","newwave"),
  rle(as.character(range_annotation))
]

done_first <- length(waves$values) > 0
done_more <- length(waves$values) > 2

res <- data.table(
  done_first = done_first, done_more = done_more
)

saveRDS(res, tail(.args, 1))