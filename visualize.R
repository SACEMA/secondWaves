
suppressPackageStartupMessages({
  require(data.table)
  require(ggplot2)
})

.args <- if (interactive()) c(
  "results/ESP/result.rds", "fig/ESP.png"
) else commandArgs(trailingOnly = TRUE)
#' @example 
#' .args <- gsub("ESP", "USA", .args)

rawpth <- .args[1]
targetfig <- tail(.args, 1)

ref <- readRDS(rawpth)

p <- ggplot(ref) + 
  aes(date, new_cases_smoothed_per_million) +
  geom_line(aes(color = "observed")) +
  geom_line(aes(y=zz, color = "zigzag")) +
  geom_point(
    aes(shape = annotation),
    data = function(dt) dt[!is.na(annotation)]
  ) +
  scale_x_date(
    "Date",
    date_breaks = "months",
    #date_minor_breaks = "2 weeks",
    date_labels = "%b"
  ) +
  scale_y_continuous("reported 7-day mean case incidence per 1M") +
  scale_shape_manual(NULL, values = c(peak=24, valley=25, uptick=23)) +
  scale_color_manual(
    NULL,
    labels = c(observed = "Reported", zigzag = "ZigZag Indicator"),
    values = c(observed = "black", zigzag = "firebrick")
  ) +
  theme_minimal() +
  theme(
    legend.position = c(0, 1),
    legend.justification = c(0, 1)
  )

ggsave(targetfig, p)