
suppressPackageStartupMessages({
  require(data.table)
  require(TTR)
})

.args <- if (interactive()) c(
  "data/owid.rds", "featureFunctions.R", "ESP", "results/ESP/result.rds"
) else commandArgs(trailingOnly = TRUE)

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
][7:.N]

ref[, zz := ZigZag(new_cases_smoothed_per_million) ]

ref[, annotation := NA_character_ ]

source(funspth)

ref[find_uptick(new_cases_smoothed_per_million, len = 5), annotation := "uptick" ]
ref[find_peaks(zz, m = 10), annotation := "peak" ]
ref[find_valleys(zz, m = 10), annotation := "valley"]

ref[annotation == "peak"]

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
  ref[
    (date > wavedate) & (new_cases_smoothed_per_million > newwave) & (is.na(annotation) | (annotation != "peak")),
    annotation := "above"
  ]
}, by=.(wavedate = date)]

#' @examples 
#' require(ggplot2)
#' ggplot(ref) + 
#'   aes(date) +
#'   geom_line(aes(y=new_cases_smoothed_per_million, color = "observed")) +
#'   geom_line(aes(y=zz, color = "zigzag")) +
#'   geom_point(aes(y=new_cases_smoothed_per_million, color = annotation), data = function(dt) dt[!is.na(annotation)]) +
#'   theme_minimal()

saveRDS(res, tail(.args, 1))