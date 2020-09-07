
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

peak2end <- cons.dt[done_first == TRUE, quantile(wave1timing, probs = c(.25, .5, .75))]

cat(peak2end)

cumEnd <- cons.dt[done_first == TRUE, quantile(wave1cases, probs = c(.25, .5, .75))]

cat(cumEnd)

cumEndCondTwo <- cons.dt[have_second == TRUE, quantile(wave1cases, probs = c(.25, .5, .75))]

cat(cumEndCondTwo)

cumEndCondNoTwo <- cons.dt[have_second == FALSE, quantile(wave1cases, probs = c(.25, .5, .75), na.rm = TRUE)]

cat(cumEndCondNoTwo)

ratPeakToTr <- cons.dt[, quantile(peaktotrough, probs = c(.25, .5, .75), na.rm = TRUE)]
cat(ratPeakToTr)

cat(cons.dt[, quantile(tposratio, probs = c(.25, .5, .75), na.rm = TRUE)])

cat(cons.dt[, quantile(one_to_two, probs = c(.25, .5, .75), na.rm = TRUE)])

cat(cons.dt[, quantile(days_resurge_28, probs = c(.25, .5, .75), na.rm = TRUE)])

cat(cons.dt[, quantile(days_resurge_14, probs = c(.25, .5, .75), na.rm = TRUE)])

cat(cons.dt[, c(sum(two_within_28, na.rm = TRUE), sum(have_post_resurge, na.rm = TRUE))])

cat(cons.dt[,c(sum(greater_follow, na.rm = TRUE), sum(have_second, na.rm = TRUE))])
