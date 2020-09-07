
suppressPackageStartupMessages({
  require(data.table)
  require(ggplot2)
})

.debug <- "FRA"
.args <- if (interactive()) sprintf(c(
  "results/%s/result.rds", "fig/%s.png"
), .debug) else commandArgs(trailingOnly = TRUE)
#' @example 
#' .args <- gsub("ESP", "USA", .args)

rawpth <- .args[1]
targetfig <- tail(.args, 1)

ref <- readRDS(rawpth)

# TODO: consider if worth adding:
#  - from peaks, draw post-wave threshold until reached / new peak
#  - once post wave threshold reached, draw new wave threshold until reached

# TODO: area plot version for shaded regions

p <- ggplot(ref) + 
  aes(date, new_cases_smoothed_per_million) +
  geom_bar(
    aes(fill = range_annotation, color = NULL),
    #data = function(dt) dt[!is.na(range_annotation)],
    alpha = 0.5, width = 1, stat = "identity"
  ) +
  #  geom_line(aes(y=zz, color = "zigzag")) +
  geom_line(color = "black") +
  geom_point(
    aes(shape = point_annotation)#,
    #data = function(dt) dt[point_annotation %in% c("peak", "uptick")]
  ) +
  scale_x_date(
    "Date",
    date_breaks = "months",
    #date_minor_breaks = "2 weeks",
    date_labels = "%b"
  ) +
  scale_y_continuous("reported 7-day mean case incidence per 1M") +
  scale_shape_manual(
    "Point Indicators",
    breaks = levels(ref$point_annotation),
    values = c(peak=17, uptick=23),
    drop = FALSE
  ) +
  scale_fill_manual(
    "Range Indicators",
    breaks = levels(ref$range_annotation),
    labels = c(
      above = "above 33%",
      below = "below 15%",
      post = "between 15% & 33%, not upswing",
      upswing = "upswing"
    ),
    values = c(
      above = "firebrick",
      upswing = "orange",
      below = "dodgerblue",
      post = "yellow"
    ),
    drop = F
  ) +
  theme_minimal() +
  theme(
    legend.position = c(0, 1),
    legend.justification = c(0, 1)
  )

ggsave(targetfig, p, height = 3.5, width = 7, units = "in")