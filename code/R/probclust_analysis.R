library(tidyverse)
winprob <- read.csv("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/data/FullData/ProcessedData.csv")
probclust <- read.csv("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/data/FullData/PD Cluster Info/ClusterInfo5.csv")

probclust$Game.Number <- as.character(probclust$Game.Number)
probclust$Game.Number[nchar(probclust$Game.Number) == 1] <- paste0("0",probclust$Game.Number[nchar(probclust$Game.Number) == 1])
probclust <- probclust %>% mutate(game_id = paste(Year,Game.Number,Home.Team,Away.Team,sep = "_"))

winprob2 <- winprob %>% left_join(probclust, by = "game_id")

#ggplot(aes(x = 3600 - game_seconds_remaining, y = home_wp, group = game_id, alpha = L_2.Cluster.Probability_1/10), data = winprob2)  + geom_line()
#ggplot(aes(x = 3600 - game_seconds_remaining, y = home_wp, group = game_id, alpha = L_2.Cluster.Probability_2/2), data = winprob2 )  + geom_line()
winprob2 <- winprob2 %>% group_by(game_id) %>% filter(!duplicated(game_seconds_remaining))


p1 <- ggplot(
  aes(
    x = game_seconds_remaining,
    y = home_wp,
    group = game_id,
    alpha = L_2.Cluster.Probability_1
  ),
  data = winprob2,
  
)  + geom_line() + 
  theme_bw() + 
  scale_alpha("Prob", range = c(0, .02)) +
  ggtitle("Cluster 1")

p2 <- ggplot(
  aes(
    x = game_seconds_remaining,
    y = home_wp,
    group = game_id,
    alpha = L_2.Cluster.Probability_2
  ),
  data = winprob2,
  
)  + geom_line() + 
  theme_bw() + 
  scale_alpha("Prob", range = c(0, .02)) +
  ggtitle("Cluster 2")

p3 <- ggplot(
  aes(
    x = game_seconds_remaining,
    y = home_wp,
    group = game_id,
    alpha = L_2.Cluster.Probability_3
  ),
  data = winprob2,
  
)  + geom_line() + 
  theme_bw() + 
  scale_alpha("Prob", range = c(0, .02)) +
  ggtitle("Cluster 3")


p4 <- ggplot(
  aes(
    x = game_seconds_remaining,
    y = home_wp,
    group = game_id,
    alpha = L_2.Cluster.Probability_4
  ),
  data = winprob2,
  
)  + geom_line() + 
  theme_bw() + 
  scale_alpha("Prob", range = c(0, .02)) +
  ggtitle("Cluster 4")

p5 <- ggplot(
  aes(
    x = game_seconds_remaining,
    y = home_wp,
    group = game_id,
    alpha = L_2.Cluster.Probability_5
  ),
  data = winprob2,
  
)  + geom_line() + 
  theme_bw() + 
  scale_alpha("Prob", range = c(0, .02)) +
  ggtitle("Cluster 5")

library(gridExtra)
png("/Users/gregorymatthews/Dropbox/cluster_prob_plot.png",h = 15, w = 10, units = "in", res = 300)
grid.arrange(p1, p2, p3, p4, p5, ncol=2)
dev.off()

