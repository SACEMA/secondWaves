
suppressPackageStartupMessages({
  require(data.table)
  require(TTR)
})

.debug <- "KEN"
.args <- if (interactive()) sprintf(c(
  "data/owid.rds", "featureFunctions.R", "%s", "results/%s/result.rds"
), .debug) else commandArgs(trailingOnly = TRUE)

rawpth <- .args[1]
funspth <- .args[2]
targetiso <- .args[3]

ref <- readRDS(rawpth)[
  iso_code == targetiso,
  .(
    new_cases_smoothed_per_million,
    new_deaths_smoothed_per_million,
    total_tests_per_thousand
  ),
  keyby = .(iso_code, location, date)
]

# censor any leading NAs in new_cases_smoothed_per_million
if (ref[1, is.na(new_cases_smoothed_per_million)]) ref <- ref[ 
  which.max(!is.na(new_cases_smoothed_per_million)):.N
]

ref[, zz := ZigZag(new_cases_smoothed_per_million, 15) ]
ref[, point_annotation := NA_character_ ]
ref[, range_annotation := NA_character_ ]

# assert: is.na(zz) is only at end of series
if (ref[, any(is.na(zz))]) {
  lastcertain <- ref[,which.max(is.na(zz))]-1
  ref[
    (lastcertain+1):.N,
    c("zz","range_annotation") := .(
      ref[lastcertain, zz],
      "zz_NA"
    )
  ]
}

source(funspth)

#ref[find_uptick(new_cases_smoothed_per_million, len = 5), annotation := "uptick" ]
ref[find_peaks(zz, m = 14, minVal = 1), point_annotation := "peak" ]
first_peak_date <- ref[point_annotation == "peak"][1, date]
ref[date > first_peak_date, range_annotation := ifelse(
  find_upswing(new_cases_smoothed_per_million) & is.na(range_annotation),
  "upswing", range_annotation
)]
ref[date > first_peak_date, point_annotation := ifelse(
  find_upswing(new_cases_smoothed_per_million, 5, 5) & (is.na(point_annotation)),
  "uptick", point_annotation
)]


# ref[find_valleys(zz, m = 10, inclTail = FALSE), annotation := "valley"]

newwave_threshold <- 1/3
#' censor any peak annotations that are below new wave criteria
#' for most recent wave
#' b/c subsequent wave / resurgence peaks could be lower / higher
ref[point_annotation == "peak", point_annotation := if (.N != 1) {
  ind <- 1; keep <- rep(TRUE, .N)
  while(ind < .N) {
    reflvl <- new_cases_smoothed_per_million[ind]*newwave_threshold
    slc <- new_cases_smoothed_per_million[(ind+1):.N] > reflvl
    if (any(slc)) {
      newind <- ind + which.max(slc)
      if (ind + 1 != newind) keep[(ind+1):(newind-1)] <- FALSE
      ind <- newind
    } else {
      keep[(ind+1):.N] <- FALSE
      ind <- .N
    }
  }
  newanno <- point_annotation
  newanno[!keep] <- NA_character_
  newanno
} else "peak" ]

# TODO: not quite there
wave_end_thresholds <- ref[
  point_annotation == "peak",
  .(
    waveoff = new_cases_smoothed_per_million / 10,
    newwave = new_cases_smoothed_per_million / 3,
    date
  )
]

# TODO: consider keeping annotation prior to first peak
ref[
  range_annotation == "upswing" & date < wave_end_thresholds[1, date],
  range_annotation := NA_character_
]
ref[
  point_annotation == "uptick" & date < wave_end_thresholds[1, date],
  point_annotation := NA_character_
]

wave_end_thresholds[,{
  ref[
    (date > wavedate) & (new_cases_smoothed_per_million < waveoff) & is.na(range_annotation),
    range_annotation := "below"
  ]
  # TODO: how does this work if there is no first below?
  endwavedate <- ref[range_annotation == "below"][1, date]
  if (!is.na(endwavedate)) {
    ref[
      (date > endwavedate) & (new_cases_smoothed_per_million > newwave),
      range_annotation := "above"
    ]
    newwavedate <- ref[(date > endwavedate) & range_annotation == "above"][1, date]
    if (!is.na(newwavedate)) ref[
       between(date, endwavedate, newwavedate, incbounds = F) & is.na(range_annotation),
       range_annotation := "post"
    ]
  }
}, by=.(wavedate = date)]

ref[range_annotation == "above" & point_annotation == "uptick", point_annotation := NA_character_ ]

ref$range_annotation <- factor(ref$range_annotation, levels = c("below", "post", "upswing", "above"), ordered = TRUE)
ref$point_annotation <- factor(ref$point_annotation, levels = c("peak", "uptick"), ordered = TRUE)

#' TODO: from USA example:
#'  - don't set / undo valley label if not in below territory

#' @examples 
#' require(ggplot2)
#' ggplot(ref) + 
#'   aes(date) +
#'   geom_line(aes(y=new_cases_smoothed_per_million, color = "observed")) +
#'   geom_line(aes(y=zz, color = "zigzag")) +
#'   geom_point(aes(y=new_cases_smoothed_per_million, color = annotation), data = function(dt) dt[!is.na(annotation)]) +
#'   theme_minimal()

saveRDS(ref, tail(.args, 1))