library(tidyverse)
winprob <- read.csv("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/PD_clusters/GregFormatClusters3.csv")
winprob2 <- winprob %>% group_by(GameID) %>% filter(!duplicated(GameID)) %>% ungroup()
winprob2 <- winprob2 %>% mutate(week = substring(winprob2$GameID,6,7) %>% as.numeric(),
                                year = substring(winprob2$GameID,1,4) %>% as.numeric()) %>% filter(week <= 18)


winprob2 %>% filter(year == 2022) %>% arrange(-L_2.Cluster.Probability_2) %>% View()
winprob2 %>% filter(year == 2023) %>% arrange(-L_2.Cluster.Probability_2) %>% View()


y <- winprob2 %>% select(L_2.Cluster.Probability_1:L_2.Cluster.Probability_3) %>% as.matrix()
x <- substring(winprob2$GameID,1,4) %>% as.numeric() - 1998 #Season
x2 <- substring(winprob2$GameID,6,7) %>% as.numeric() #Week 
#y <- y[1:1000,]
colnames(y) <- NULL
#x <- x[1:1000]
N <- nrow(y)
K <- ncol(y)
P <- length(unique(x))
P2 <- length(unique(x2))


library(tidyverse)
dat <- data.frame(y = y, year = x, week = x2)
names(dat)[1:3] <- c("y1","y2","y3")

dat %>% mutate(year = year + 1998) %>% group_by(year, week) %>% summarize(y1 = mean(y1),
                                      y2 = mean(y2),
                                      y3 = mean(y3)) %>% arrange(y3) %>% View()



dat %>% mutate(year = year + 1998) %>% group_by(year) %>% 
  summarize(y1 = mean(y1),
            y2 = mean(y2),
            y3 = mean(y3)) %>% 
  ggplot(aes(x = year, y =  y3)) + 
  geom_line() + geom_smooth()


dat %>% mutate(year = year + 1998) %>% group_by(week) %>% 
  summarize(y1 = mean(y1),
            y2 = mean(y2),
            y3 = mean(y3)) %>% 
  ggplot(aes(x = week, y =  y3)) + 
  geom_line() + geom_smooth()


dat %>%
  mutate(year = year + 1998) %>%
  filter(year == 2022) %>% 
  summarize(mean(y1),
            mean(y2),
            mean(y3))
  
dat %>%
  mutate(year = year + 1998) %>%
  filter(year == 2023) %>% 
  summarize(mean(y1),
            mean(y2),
            mean(y3))




