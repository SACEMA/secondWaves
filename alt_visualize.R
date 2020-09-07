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

p <- ggplot(ref) + aes(date) +
 geom_bar(
   aes(y=inc_cases, fill=range_annotation),
   data = function(dt) dt[!is.na(range_annotation)],
   width = 1, stat = "identity", alpha = 0.2
 ) +
 geom_line(aes(y=endwave, color="endwave", linetype="threshold"), alpha = 0.5) +
 geom_line(aes(y=newwave, color="newwave", linetype="threshold"), alpha = 0.5) +
 geom_line(aes(y=inc_cases, color="observed", linetype="observed")) +
 geom_point(
   aes(y=inc_cases, shape=point_annotation, size=(point_annotation == "peak")),
   data = function(dt) dt[!is.na(point_annotation)]
 ) +
 coord_cartesian(expand = FALSE, clip = "off") +
 scale_x_date(
   NULL, date_breaks = "months", date_labels = "%b"
 ) +
 scale_y_continuous("Incidence") +
 scale_color_manual(
   NULL, drop = F,
   labels = c(observed="Reported", endwave="End Wave Threshold", newwave="New Wave Threshold"),
   values = c(observed="black", endwave="dodgerblue", newwave="firebrick"),
   guide = guide_legend(override.aes = list(linetype = c("dashed", "dashed", "solid")))
 ) +
 scale_linetype_manual(
   NULL, drop = F,
   values = c(threshold="dashed", observed="solid"),
   guide = "none"
 ) +
 scale_fill_manual(
   NULL, drop = F,
   labels = c(endwave = "Post Wave", newwave = "New Wave", upswing = "Upswing", resurge = "Resurgence"),
   values = c(endwave = "dodgerblue", newwave = "firebrick", upswing = "yellow", resurge = "darkorange")
 ) +
 scale_shape_manual(
   NULL, drop = F,
   values = c(peak=17, uptick=24),
   guide = guide_legend(override.aes=list(size=c(3,1)))
 ) +
 scale_size_manual(NULL, values=c(`TRUE`=3,`FALSE`=1), guide = "none") +
 theme_minimal() +
 theme(
   legend.position = c(0, 1), legend.justification = c(0, 1),
   legend.spacing.y = unit(-0.25, "line")
 )

ggsave(targetfig, p, height = 3.5, width = 7, units = "in")