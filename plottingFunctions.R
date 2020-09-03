det_plot <- function(dat, lineDec = TRUE, lineInc = TRUE){
  maxval <- max(dat$new_cases_smoothed_per_million, na.rm = TRUE)
  (ggplot(dat) 
    + aes(x = date, y = new_cases_smoothed_per_million) 
    + geom_line() 
    + {if(lineDec) geom_hline(yintercept = maxval*0.1, linetype=3)}
    + {if(lineInc) geom_hline(yintercept = maxval*1/3, linetype=1)}
    + facet_wrap(~location, scales = 'free') 
    + xlab('Date') 
    + ylab('New detections / million pop')
  )
}

pos_plot <- function(dat, useLog = TRUE){
  (ggplot(dat) 
   + aes(x = date, y = positive_rate) 
   + geom_line() 
   + facet_wrap(~location, scales = 'fixed') 
   + xlab('Date') 
   + ylab('Test positivity') 
   + {if(useLog) scale_y_log10()}
  )
}

test_plot <- function(dat, useLog = FALSE){
  (ggplot(dat) 
   + aes(x = date, y = new_tests_smoothed_per_thousand) 
   + geom_line() 
   + facet_wrap(~location, scales = 'fixed') 
   + xlab('Date') 
   + ylab('New tests / thousand pop') 
   + {if(useLog) scale_y_log10()}
  )
}

str_plot <- function(dat, col = 'purple'){
  (ggplot(dat) 
   + geom_line(aes(x = date, y = stringency_index), color = col) 
   + facet_wrap(~location, scales = 'fixed') 
   + xlab('Date') 
   + ylab('Stringency') 
   + ylim(0,100)
  )
}

three_plot <- function(loc, strCol = 'black', plotPeaks = F, plotVals = F, dd = dat){
  tmp <- dd %>% filter(location == loc)
  if(plotPeaks){
    pks <- find_peaks(tmp$new_cases_smoothed_per_million)
    pdat <- data.frame(dt=tmp$date[pks], nn=tmp$new_cases_smoothed_per_million[pks])
  }
  if(plotVals){
    vls <- find_valleys(tmp$new_cases_smoothed_per_million)
    vdat <- data.frame(dt=tmp$date[vls], nn=tmp$new_cases_smoothed_per_million[vls])
  }
  det <- (det_plot(tmp) 
          + {if(plotPeaks) geom_point(data = pdat, aes(x=dt,y=nn))} 
          + {if(plotVals) geom_point(data = vdat, aes(x=dt,y=nn))}
  )
  pos <- pos_plot(tmp)
  str <- str_plot(tmp, col = strCol)
  cowplot::plot_grid(det, pos, str, nrow = 3)
}

uptick_plot <- function(dat, th = 5){
  det_plot(dat) + geom_vline(xintercept = find_uptick(dat, 5)) + geom_vline(xintercept = find_uptick(dat, 5, usePositivity = T), color = 'red', linetype = 3)
}
downtick_plot <- function(dat, th = 5){
  det_plot(dat) + geom_vline(xintercept = find_uptick(dat, 5, down = T)) + geom_vline(xintercept = find_uptick(dat, 5, usePositivity = T, down = T), color = 'red', linetype = 3)
}
