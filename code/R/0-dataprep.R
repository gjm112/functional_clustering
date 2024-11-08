library(tidyverse)
dattemp <- list()
for (i in 1999:2023){print(i)
temp <- read.csv(paste0("/Users/gregorymatthews/Dropbox/function_clusgteringgit/rawdata/play_by_play_",i,".csv"))
temp <- temp %>% select(game_id, home_wp,game_seconds_remaining, qtr)
temp$season <- i
dattemp[[i-1998]] <- temp
}

dat <- do.call(rbind,dattemp)
write.csv(dat,file = "./data/nfl-pbp-data-1999-2023.csv")

dat %>% group_by(game_id) %>% summarize(ot = max(qtr)) %>% group_by(ot) %>% summarize(n = n())

#Check for time remaining errors 
dat$cap <- (5 - dat$qtr)*900
dat$floor <- (4 - dat$qtr)*900
dat %>% filter(game_id == "2010_04_SF_ATL")
dat[(dat$game_seconds_remaining > dat$cap | dat$game_seconds_remaining < dat$floor) & dat$qtr <= 4,]  %>% View()
