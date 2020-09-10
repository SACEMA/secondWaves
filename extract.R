
suppressPackageStartupMessages({
  require(data.table)
})

.debug <- "ZAF"
.debug <- "GRC"
.debug <- "JAM"
.args <- if (interactive()) sprintf(c(
  "results/%s/result.rds", "results/%s/stats.rds"
), .debug) else commandArgs(trailingOnly = TRUE)

annotated.dt <- readRDS(.args[1])

waves <- annotated.dt[
  range_annotation %in% c("endwave","newwave"),
  rle(as.character(range_annotation))
]

done_first <- length(waves$values) > 0
have_second <- length(waves$values) > 1
done_more <- length(waves$values) > 2

wave1timing <- if (done_first) {
  pkdt <- annotated.dt[point_annotation == "peak", date[1]]
  edt <- annotated.dt[range_annotation == "endwave", date[1]]
  if (is.na(pkdt) | edt < pkdt) {
    pkdt <- annotated.dt[date < edt][which.max(inc_cases), date]
  }
  edt - pkdt
} else NA_integer_

wave1cases <- if (done_first) {
  annotated.dt[range_annotation == "endwave", cum_cases[1]]
} else NA_real_

peaktotrough <- if (done_first) {
  pk <- annotated.dt[date == pkdt, inc_cases]
  trdt <- if (have_second) {
    dt2 <- annotated.dt[range_annotation == "newwave", date[1]]
    annotated.dt[between(date, pkdt, dt2), date[which.min(inc_cases)]]
  } else annotated.dt[date > pkdt, date[which.min(inc_cases)]]
  pk/annotated.dt[date == trdt, inc_cases]
} else NA_real_

tposratio <- if (done_first) {
  peakpos <- annotated.dt[date == pkdt, positive_rate]
  trpos <- annotated.dt[date == trdt, positive_rate]
  peakpos/trpos
} else NA_real_

one_to_two <- if (have_second) {
  twostart <- annotated.dt[range_annotation == "newwave", date[1]]
  twostart - edt
} else NA_integer_

days_resurge_28 <- if (have_second) {
  annotated.dt[between(date, twostart-28, twostart) & range_annotation == "resurge", .N]
} else NA_integer_

days_resurge_14 <- if (have_second) {
  annotated.dt[between(date, twostart-14, twostart) & range_annotation == "resurge", .N]
} else NA_integer_

have_post_resurge <- if (done_first) {
  if (have_second) {
    annotated.dt[between(date, edt, twostart), any(range_annotation == "resurge", na.rm = TRUE)]
  } else {
    annotated.dt[date > edt, any(range_annotation == "resurge", na.rm = TRUE)]
  }
} else NA

two_within_28 <- if (!is.na(have_post_resurge) & have_post_resurge) {
  rdt <- annotated.dt[date > edt][range_annotation == "resurge", date[1]]
  if (have_second) {
    (twostart - rdt) <= 28
  } else {
    lastdate <- annotated.dt[!is.na(inc_cases)][.N, date]
    if (lastdate - rdt > 28) {
      FALSE
    } else NA
  }
} else NA 

greater_follow <- if (have_second) {
  annotated.dt[date > pkdt, max(inc_cases, na.rm = TRUE)] > pk
} else NA

res <- data.table(
  done_first = done_first,
  have_second = have_second,
  done_more = done_more,
  wave1timing = wave1timing,
  wave1cases = wave1cases,
  peaktotrough = peaktotrough,
  tposratio = tposratio,
  one_to_two = one_to_two,
  days_resurge_28 = days_resurge_28,
  days_resurge_14 = days_resurge_14,
  have_post_resurge = have_post_resurge,
  two_within_28 = two_within_28,
  greater_follow = greater_follow
)

saveRDS(res, tail(.args, 1))