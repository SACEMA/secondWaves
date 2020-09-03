library(dplyr)
library(ggplot2)
source('plottingFunctions.R')
source('featureFunctions.R')
dat <- read.csv('2020-08-30_owid-covid-data.csv', as.is = TRUE)
dat$date <- as.Date(dat$date)

tmp <- (dat 
        %>% filter(population > 1000000) 
        %>% filter(location != 'Hong Kong')
        %>% group_by(location) 
        %>% summarize(whichMax = which.max(new_cases_smoothed_per_million)
                      , maxDate = date[whichMax]
                      , maxCSpM = new_cases_smoothed_per_million[whichMax]
                      , pop = mean(population)
        )
        %>% filter(maxCSpM >= 10, !location %in% c('World', 'International'))
)

pdf('det_plots.pdf', onefile = T, width = 6, height = 5)
det_plot(dat %>% filter(location %in% tmp$location[1:20]), lineDec = F, lineInc = F)
det_plot(dat %>% filter(location %in% tmp$location[21:40]), lineDec = F, lineInc = F)
det_plot(dat %>% filter(location %in% tmp$location[41:60]), lineDec = F, lineInc = F)
det_plot(dat %>% filter(location %in% tmp$location[61:80]), lineDec = F, lineInc = F)
det_plot(dat %>% filter(location %in% tmp$location[81:100]), lineDec = F, lineInc = F)
det_plot(dat %>% filter(location %in% tmp$location[101:115]), lineDec = F, lineInc = F)
dev.off()

pdf('threeplots.pdf', onefile = T, width = 2, height = 6)
for(ll in tmp$location){
  print(three_plot(ll))
}
dev.off()

pdf('uptick_plots.pdf', onefile = T, width = 4, height = 4)
for(ll in tmp$location){
  dd <- dat %>% filter(location == ll)
  print(uptick_plot(dd))
}
dev.off()
