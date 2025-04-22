
winprob <- read.csv("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/PD_clusters/GregFormatClusters5.csv")

library(tidyverse)
png("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/PD_clusters/Cluster1.png", res = 300, units = "in", h = 5, w = 10)
ggplot(aes(x = Time, y = SplineWinPercent, group = GameID, alpha =  L_2.Cluster.Probability_1), data = winprob ) + geom_line() + scale_alpha("Prob", range = c(0, .1))  + theme_bw() + ggtitle("Cluster 1") + coord_cartesian(ylim = c(0, 1))
dev.off()
png("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/PD_clusters/Cluster2.png", res = 300, units = "in", h = 5, w = 10)
ggplot(aes(x = Time, y = SplineWinPercent, group = GameID, alpha =  L_2.Cluster.Probability_2), data = winprob ) + geom_line() + scale_alpha("Prob", range = c(0, .1))  + theme_bw() + ggtitle("Cluster 2") + coord_cartesian(ylim = c(0, 1))
dev.off()
png("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/PD_clusters/Cluster3.png", res = 300, units = "in", h = 5, w = 10)
ggplot(aes(x = Time, y = SplineWinPercent, group = GameID, alpha =  L_2.Cluster.Probability_3), data = winprob ) + geom_line() + scale_alpha("Prob", range = c(0, .1))  + theme_bw() + ggtitle("Cluster 3") + coord_cartesian(ylim = c(0, 1))
dev.off()
png("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/PD_clusters/Cluster4.png", res = 300, units = "in", h = 5, w = 10)
ggplot(aes(x = Time, y = SplineWinPercent, group = GameID, alpha =  L_2.Cluster.Probability_4), data = winprob ) + geom_line() + scale_alpha("Prob", range = c(0, .1))  + theme_bw() + ggtitle("Cluster 4") + coord_cartesian(ylim = c(0, 1))
dev.off()
png("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/PD_clusters/Cluster5.png", res = 300, units = "in", h = 5, w = 10)
ggplot(aes(x = Time, y = SplineWinPercent, group = GameID, alpha =  L_2.Cluster.Probability_5), data = winprob ) + geom_line() + scale_alpha("Prob", range = c(0, .1))  + theme_bw() + ggtitle("Cluster 5") + coord_cartesian(ylim = c(0, 1))
dev.off()

probclust[1:10,] %>% View()




library(DirichletReg)
probclust <- read.csv("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/data/FullData/PD Cluster Info/ClusterInfo5.csv")
probclust$Y <- DR_data(probclust %>% select(L_2.Cluster.Probability_1:L_2.Cluster.Probability_5))  # prepare the Y's

probclust <- probclust %>% mutate(Season.Part = case_when(
  Game.Number <= 4 ~ 1,
  Game.Number <= 13 ~ 2,
  Game.Number <= 20 ~ 3
),
Decade = case_when(
  Year <= 2009 ~ "00",
  Year <= 2019 ~ "10",
  Year <= 2029 ~ "20"
))

mod1 <- DirichReg(Y ~ as.factor(Year) + as.factor(Game.Number), probclust)

mod1 <- DirichReg(Y ~  as.factor(Game.Number), probclust %>% filter(Game.Number <= 18))
newdat <- data.frame(Game.Number = as.factor(1:18))
preds <- data.frame(predict(mod1, newdata = newdat), week = 1:18)
predslong <- preds %>% pivot_longer(cols = c(X1,X2,X3,X4,X5))

ggplot(aes(x = week, y = value, color = name), data = predslong) + geom_line()



mod1 <- DirichReg(Y ~  Game.Number, probclust %>% filter(Game.Number <= 18))




mod1 <- DirichReg(Y ~  as.factor(Season.Part) + as.factor(Year), probclust %>% filter(Game.Number <= 18))
mod1 <- DirichReg(Y ~  as.factor(Season.Part) + as.factor(Decade), probclust %>% filter(Game.Number <= 18))
mod1 <- DirichReg(Y ~  as.factor(Season.Part) , probclust %>% filter(Game.Number <= 18))
mod0 <- DirichReg(Y ~  1 , probclust %>% filter(Game.Number <= 18))
summary(mod1)

logLik(mod1) - logLik(mod0) 
logLik(mod1)


#With only 3 clusters? 
winprob <- read.csv("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/PD_clusters/GregFormatClusters3.csv")

library(tidyverse)
png("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/PD_clusters/Cluster1of3.png", res = 300, units = "in", h = 5, w = 10)
ggplot(aes(x = Time, y = SplineWinPercent, group = GameID, alpha =  L_2.Cluster.Probability_1), data = winprob ) + geom_line() + scale_alpha("Prob", range = c(0, .1))  + theme_bw() + ggtitle("Cluster 1") + coord_cartesian(ylim = c(0, 1))
dev.off()
png("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/PD_clusters/Cluster2of3.png", res = 300, units = "in", h = 5, w = 10)
ggplot(aes(x = Time, y = SplineWinPercent, group = GameID, alpha =  L_2.Cluster.Probability_2), data = winprob ) + geom_line() + scale_alpha("Prob", range = c(0, .1))  + theme_bw() + ggtitle("Cluster 2") + coord_cartesian(ylim = c(0, 1))
dev.off()
png("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/PD_clusters/Cluster3of3.png", res = 300, units = "in", h = 5, w = 10)
ggplot(aes(x = Time, y = SplineWinPercent, group = GameID, alpha =  L_2.Cluster.Probability_3), data = winprob ) + geom_line() + scale_alpha("Prob", range = c(0, .1))  + theme_bw() + ggtitle("Cluster 3") + coord_cartesian(ylim = c(0, 1))
dev.off()


library(DirichletReg)
probclust <- winprob %>% filter(!duplicated(GameID))
probclust <- probclust %>% mutate(Year = substring(GameID, 1, 4),
                     Game.Number = as.numeric(substring(GameID, 6,7)))
probclust$Y <- DR_data(probclust %>% select(L_2.Cluster.Probability_1:L_2.Cluster.Probability_3))  # prepare the Y's

probclust <- probclust %>% mutate(Season.Part = case_when(
  Game.Number <= 4 ~ 1,
  Game.Number <= 8 ~ 2,
  Game.Number <= 12 ~ 3,
  Game.Number <= 20 ~ 4
),
Decade = case_when(
  Year <= 2009 ~ "00",
  Year <= 2019 ~ "10",
  Year <= 2029 ~ "20"
))

mod1 <- DirichReg(Y ~ as.factor(Year) + as.factor(Game.Number), probclust)

mod1 <- DirichReg(Y ~  as.factor(Game.Number), probclust %>% filter(Game.Number <= 18))
newdat <- data.frame(Game.Number = as.factor(1:18))
preds <- data.frame(predict(mod1, newdata = newdat), week = 1:18)
predslong <- preds %>% pivot_longer(cols = c(X1,X2,X3))
ggplot(aes(x = week, y = value, color = name), data = predslong) + geom_line()


mod1 <- DirichReg(Y ~  as.factor(Season.Part), probclust %>% filter(Game.Number <= 18))
newdat <- data.frame(Season.Part = as.factor(1:4))
preds <- data.frame(predict(mod1, newdata = newdat), Season.Part = 1:4)
predslong <- preds %>% pivot_longer(cols = c(X1,X2,X3))
ggplot(aes(x = Season.Part, y = value, color = name), data = predslong) + geom_line()

 
mod1 <- DirichReg(Y ~  as.factor(Season.Part) + as.factor(Decade), probclust %>% filter(Game.Number <= 18))
newdat <- expand.grid(Season.Part = as.factor(1:4), Decade = as.factor(c("00","10","20")))
preds <- data.frame(predict(mod1, newdata = newdat))
preds <- cbind(preds,newdat)
predslong <- preds %>% pivot_longer(cols = c(X1,X2,X3))
ggplot(aes(x = as.numeric(Season.Part), y = value, color = name), data = predslong) + geom_line() + facet_wrap(1~Decade)


mod1 <- DirichReg(Y ~  as.factor(Decade) + as.factor(Decade), probclust %>% filter(Game.Number <= 18))
newdat <- expand.grid(Decade = as.factor(c("00","10","20")))
preds <- data.frame(predict(mod1, newdata = newdat), Decade = c("00","10","20"))
predslong <- preds %>% pivot_longer(cols = c(X1,X2,X3))
ggplot(aes(x = as.numeric(Decade), y = value, color = name), data = predslong) + geom_line() 





mod1 <- DirichReg(Y ~  Game.Number, probclust %>% filter(Game.Number <= 18))




mod1 <- DirichReg(Y ~  as.factor(Season.Part) + as.factor(Year), probclust %>% filter(Game.Number <= 18))
mod1 <- DirichReg(Y ~  as.factor(Season.Part) + as.factor(Decade), probclust %>% filter(Game.Number <= 18))
mod1 <- DirichReg(Y ~  as.factor(Season.Part) , probclust %>% filter(Game.Number <= 18))
mod0 <- DirichReg(Y ~  1 , probclust %>% filter(Game.Number <= 18))
summary(mod1)

logLik(mod1) - logLik(mod0) 
logLik(mod1)