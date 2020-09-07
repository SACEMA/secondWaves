suppressPackageStartupMessages({
  require(data.table)
  require(TTR)
  require(jsonlite)
})

#' for interactive use; n.b. that saving new `.debug` in the script resets
#' the file modification time and thus associated `make` behavior
.debug <- "CUB"
.args <- if (interactive()) sprintf(c(
  "data/owid.rds", "featureFunctions.R", "thresholds.json", "%s", "results/%s/result.rds"
), .debug) else commandArgs(trailingOnly = TRUE)

rawpth <- .args[1]
funspth <- .args[2]
threshpth <- .args[3]
targetiso <- .args[4]

#' creates endwave_threshold, newwave_threshold
attach(read_json(threshpth))

ref <- readRDS(rawpth)[
  iso_code == targetiso,
  .(
    inc_cases = new_cases_smoothed_per_million,
    inc_deaths = new_deaths_smoothed_per_million,
    cum_cases = total_cases_per_million, 
    cum_deaths = total_deaths_per_million,
    inc_tests = new_tests_smoothed_per_thousand,
    cum_tests = total_tests_per_thousand, # n.b. no smoothed available in raw data
    positive_rate
  ),
  keyby = .(iso_code, location, date)
]

#' censor any leading NAs in new_cases_smoothed_per_million
if (ref[1, is.na(inc_cases)]) ref <- ref[ 
  which.max(!is.na(inc_cases)):.N
]

#' diagnostics
#' assert: no missing days

if (ref[, !all(diff(date)==1)]) warning("missing dates")
if (ref[, any(inc_cases < 0)]) warning("negative case incidence")

min.end.wave <- 0.5

ref[, endwave := {
  initial <- Reduce(max, inc_cases, accumulate = TRUE)*endwave_threshold
  #' whenever `endwave` criteria is below .5, set it to 0
  initial[initial < min.end.wave] <- 0
  tfrle <- rle(inc_cases < initial)
  if (any(tfrle$values)) {
    ind <- 1
    while (ind <= sum(tfrle$values)) {
      restart_ind <- cumsum(tfrle$lengths)[tfrle$values[-1]][ind] + 2
      if (restart_ind <= .N) {
        slc <- restart_ind:.N
        initial[slc] <- Reduce(max, inc_cases[slc], accumulate = TRUE)*endwave_threshold
        initial[initial < min.end.wave] <- 0
        tfrle <- rle(inc_cases < initial)
      }
      ind <- ind + 1
    }
  }
  initial
}]

ref[, newwave := {
  initial <- Reduce(max, inc_cases, accumulate = TRUE)*newwave_threshold
  endedwave <- Reduce(any, (inc_cases < endwave), accumulate = TRUE)
  tfrle <- rle((inc_cases > initial) & endedwave)
  if (any(tfrle$values)) {
    ind <- 1
    while (ind <= sum(tfrle$values)) {
      restart_ind <- cumsum(tfrle$lengths)[tfrle$values[-1]][ind] + 2
      if (restart_ind <= .N) {
        slc <- restart_ind:.N
        initial[slc] <- Reduce(max, inc_cases[slc], accumulate = TRUE)*newwave_threshold
        endedwave[slc] <- Reduce(any, inc_cases[slc] < endwave[slc], accumulate = TRUE)
        tfrle <- rle((inc_cases > initial) & (endedwave))
      }
      ind <- ind + 1
    }
  }
  initial
}]

#' @examples 
#' p <- ggplot(ref) + aes(date) +
#'  geom_line(aes(y=endwave, color="endwave", linetype="threshold"), alpha = 0.5) +
#'  geom_line(aes(y=newwave, color="newwave", linetype="threshold"), alpha = 0.5) +
#'  geom_line(aes(y=inc_cases, color="observed", linetype="observed")) +
#'  coord_cartesian(expand = FALSE, clip = "off") +
#'  scale_x_date(
#'    NULL, date_breaks = "months", date_labels = "%b"
#'  ) +
#'  scale_y_continuous("Incidence") +
#'  scale_color_manual(
#'    NULL,
#'    labels = c(observed="Reported", endwave="End Wave Threshold", newwave="New Wave Threshold"),
#'    values = c(observed="black", endwave="dodgerblue", newwave="firebrick"),
#'    guide = guide_legend(override.aes = list(linetype = c("dashed", "dashed", "solid")))
#'  ) +
#'  scale_linetype_manual(
#'    NULL,
#'    values = c(threshold="dashed", observed="solid"),
#'    guide = "none"
#'  ) +
#'  theme_minimal() +
#'  theme(
#'    legend.position = c(0, 1), legend.justification = c(0, 1)
#'  ); p

#' inc_cases <- ref$inc_cases; endwave <- ref$endwave; newwave <- ref$newwave
 
ref[, range_annotation := {
  bcrit <- inc_cases < endwave
  acrit <- inc_cases > newwave
  
  below <- Reduce(any, bcrit, accumulate = TRUE)
  above <- Reduce(any, acrit & below, accumulate = TRUE)
  
  while (any(below & above)) {
    ind <- which(below & above)[1]
    slc <- ind:.N
    below[slc] <- Reduce(any, bcrit[slc], accumulate = TRUE)
    # above is now TRUE until we hit a below
    newover <- Reduce(all, !below[slc], accumulate = TRUE)
    above[slc] <- newover | Reduce(any, acrit[slc] & below[slc], accumulate = TRUE)
  }
  ifelse(
    below,
    "endwave", ifelse(above,
    "newwave",
    NA_character_
    )
  )
}]

#' @examples 
#' p + geom_bar(
#'   aes(y=inc_cases, fill=range_annotation),
#'   data = function(dt) dt[!is.na(range_annotation)],
#'   width = 1, stat = "identity", alpha = 0.1
#' ) +
#' scale_fill_manual(
#'   NULL,
#'   labels = c(endwave = "Post Wave", newwave = "New Wave"),
#'   values = c(endwave = "dodgerblue", newwave = "firebrick")
#' )

ref[, zz := ZigZag(inc_cases, 15) ]
ref[, point_annotation := NA_character_ ]

# assert: is.na(zz) is only at end of series
# if (ref[, any(is.na(zz))]) {
#   lastcertain <- ref[,which.max(is.na(zz))]-1
#   ref[
#     (lastcertain+1):.N,
#     c("zz","range_annotation") := .(
#       ref[lastcertain, zz],
#       "zz_NA"
#     )
#   ]
# }

source(funspth)

#ref[find_uptick(new_cases_smoothed_per_million, len = 5), annotation := "uptick" ]
ref[
  find_peaks(zz, m = 14, minVal = 10),
  point_annotation := ifelse(
    is.na(range_annotation) | (range_annotation != "endwave"),
    "peak", NA_character_
  )
]
first_peak_date <- ref[point_annotation == "peak"][1, date]

ref[date > first_peak_date, range_annotation := if (.N >= 8) {
    hits <- find_upswing(inc_cases, 8, 6) | find_upswing(positive_rate, 8, 6)
    hits[is.na(hits)] <- FALSE
    fifelse(
      (is.na(range_annotation) | (range_annotation != "newwave")) & hits,
      yes="upswing", no=range_annotation
    )
  } else range_annotation
]

ref[date > first_peak_date, point_annotation := if (.N >= 5) {
  hits <- find_upswing(inc_cases, 5, 5) | find_upswing(positive_rate, 5, 5)
  hits[is.na(hits)] <- FALSE
  fifelse(
    is.na(point_annotation) & hits,
    yes="uptick", no=point_annotation
  )
} else point_annotation ]

ref[, range_annotation := {
  # for each run of upswings, if it contains an uptick
  # convert run to a resurgence from first uptick
  up <- (!is.na(range_annotation) & (range_annotation %in% c("upswing", "resurge")))[-1]
  both <- up & (
    !is.na(point_annotation) & (point_annotation == "uptick")
  )[-1]
  resurge <- Reduce(
    function(was, state) state >= (2-was), up + both, init = FALSE, accumulate = TRUE
  )
  newanno <- range_annotation
  newanno[resurge] <- "resurge"
  newanno
}]

#' @examples
#' p + geom_bar(
#'   aes(y=inc_cases, fill=range_annotation),
#'   data = function(dt) dt[!is.na(range_annotation)],
#'   width = 1, stat = "identity", alpha = 0.2
#' ) +
#' geom_point(
#'   aes(y=inc_cases, shape=factor(point_annotation, levels = c("peak","uptick")), size=(point_annotation == "peak")),
#'   data = function(dt) dt[!is.na(point_annotation)]
#' ) +
#' scale_fill_manual(
#'   NULL,
#'   labels = c(endwave = "Post Wave", newwave = "New Wave", upswing = "Upswing", resurge = "Resurgence"),
#'   values = c(endwave = "dodgerblue", newwave = "firebrick", upswing = "yellow", resurge = "darkorange")
#' ) +
#' scale_shape_manual(
#'   NULL, drop = F,
#'   values = c(peak=17, uptick=24),
#'   guide = guide_legend(override.aes=list(size=c(3,1)))
#' ) +
#' scale_size_manual(NULL, values=c(`TRUE`=3,`FALSE`=1))

ref[, range_annotation := factor(range_annotation, levels = c("endwave","upswing","resurge","newwave"), ordered = TRUE)]
ref[, point_annotation := factor(point_annotation, levels = c("peak","uptick"), ordered = TRUE)]


saveRDS(ref, tail(.args, 1))