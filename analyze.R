
suppressPackageStartupMessages({
  require(data.table)
  require(TTR)
})

.args <- if (interactive()) c(
  "data/owid.rds", "featureFunctions.R", "ESP", "results/ESP/result.rds"
) else commandArgs(trailingOnly = TRUE)
#' @example 
#' .args <- gsub("ESP", "USA", .args)

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
ref[, annotation := NA_character_ ]

# assert: is.na(zz) is only at end of series
if (ref[, any(is.na(zz))]) {
  lastcertain <- ref[,which.max(is.na(zz))]-1
  ref[
    (lastcertain+1):.N,
    c("zz","annotation") := .(
      ref[lastcertain, zz],
      "zz_NA"
    )
  ]
}

source(funspth)

ref[find_uptick(new_cases_smoothed_per_million, len = 5), annotation := "uptick" ]
ref[find_peaks(zz, m = 14), annotation := "peak" ]
# ref[find_valleys(zz, m = 10, inclTail = FALSE), annotation := "valley"]

newwave_threshold <- 1/3
#' censor any peak annotations that are below new wave criteria
#' for most recent wave
#' b/c subsequent wave / resurgence peaks could be lower / higher
ref[annotation == "peak", annotation := if (.N != 1) {
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
  print(keep)
  newanno <- annotation
  newanno[!keep] <- NA_character_
  newanno
} else "peak" ]

# TODO: not quite there
wave_end_thresholds <- ref[
  annotation == "peak",
  .(
    waveoff = new_cases_smoothed_per_million / 10,
    newwave = new_cases_smoothed_per_million / 3,
    date
  )
]

ref[
  annotation == "uptick" & date < wave_end_thresholds[1, date],
  annotation := NA_character_
]

wave_end_thresholds[,{
  ref[
    (date > wavedate) & (new_cases_smoothed_per_million < waveoff) & is.na(annotation),
    annotation := "below"
  ]
  endwavedate <- ref[annotation == "below"][1, date]
  ref[
    (date > endwavedate) & (new_cases_smoothed_per_million > newwave) & (is.na(annotation) | (annotation != "peak")),
    annotation := "above"
  ]
}, by=.(wavedate = date)]

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