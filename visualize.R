
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
  aes(date) +
  geom_line(aes(y=new_cases_smoothed_per_million, color = "observed")) +
  geom_line(aes(y=zz, color = "zigzag")) +
  geom_point(aes(y=new_cases_smoothed_per_million, color = annotation), data = function(dt) dt[!is.na(annotation)]) +
  theme_minimal()

ggsave(targetfig, p)