library(tidyverse)
dattemp <- list()
for (i in 1999:2023){print(i)
temp <- read.csv(paste0("./rawdata/play_by_play_",i,".csv"))
temp <- temp %>% select(game_id, home_wp,game_seconds_remaining)
temp$season <- i
dattemp[[i-1998]] <- temp
}

dat <- do.call(rbind,dattemp)
