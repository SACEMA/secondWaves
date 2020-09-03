find_peaks <- function (x, m = 7, inclMax = T, inclTail = T, minVal = 10, browse = F){
  # Starting point: https://stats.stackexchange.com/questions/22974/how-to-find-local-peaks-valleys-in-a-series-of-data
  shape <- diff(sign(diff(x, na.pad = FALSE)))
  pks <- sapply(which(shape < 0), FUN = function(i){
    z <- i - m + 1
    z <- ifelse(z > 0, z, 1)
    w <- i + m + 1
    w <- ifelse(w < length(x), w, length(x))
    if(browse) browser()
    v <- x[c(z : i, (i + 2) : w)]
    v <- v[!is.na(v)]
    if(all(v < x[i + 1]) & abs(x[i + 1]) >= minVal) return(i + 1) else return(numeric(0))
  })
  pks <- unlist(pks)
  if(inclTail & all(tail(diff(x, na.pad = FALSE), m) > 0)) pks <- c(pks, length(x))
  if(inclMax) pks <- sort(unique(pks, which.max(x)))
  pks
}
find_valleys <- function(x, m = 7, inclMin = T, inclTail = T){
  find_peaks(-x, m, inclMin, inclTail, minVal = 0.001)
}

find_uptick <- function(dd, len = 7, usePositivity = F, prospective = F, down = FALSE){
  # Based on: https://masterr.org/r/how-to-find-consecutive-repeats-in-r/
  lookFor <- ifelse(down, -1, 1)
  if(usePositivity){
    rr <- rle(sign(diff(dd$positive_rate)))
  }else{
    rr <- rle(sign(diff(dd$new_cases_smoothed_per_million)))
  }
  if(any(rr$values == lookFor & rr$lengths >= len)){
    use_runs <- which(rr$values == lookFor & rr$lengths >= len)
    ends <- cumsum(rr$lengths)[use_runs]
    starts <- cumsum(rr$lengths)[use_runs-1] + 1
    st_dates <- dd$date[starts]
    if(prospective){
      return(st_dates[st_dates > dd$date[which.max(dd$new_cases_smoothed_per_million)]])
    }else{
      return(st_dates)  
    }
  }else{
    return(NA)
  }
}