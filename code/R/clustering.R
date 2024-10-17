#Raw data from here: https://github.com/nflverse/nflverse-data/releases/tag/pbp

cor_dtw <- read.csv("./data/correlation_l2.csv", header = FALSE)
d <- as.dist(cor_dtw)

gamenames <- read.csv("./gamenames.csv", header = FALSE)
attr(d,"Labels") <- gamenames$V1

test <- hclust(d)
png("./l2_dendrogram.png", h = 50, w = 200, res = 300, units = "in")
plot(test)
dev.off()


library(tidyverse)
winprob <- read.csv("./data/NFL2023season_win_prob.csv")

winprob %>% filter(game_id == "2023_01_ARI_WAS") %>% ggplot(aes(x = 3600 - game_seconds_remaining, y = home_wp)) + geom_path()
winprob %>% filter(game_id == "2023_20_GB_SF") %>% ggplot(aes(x = 3600 - game_seconds_remaining, y = home_wp)) + geom_path()

winprob %>% filter(game_id == "2023_10_TEN_TB") %>% ggplot(aes(x = 3600 - game_seconds_remaining, y = home_wp)) + geom_path()
winprob %>% filter(game_id == "2023_17_PIT_SEA") %>% ggplot(aes(x = 3600 - game_seconds_remaining, y = 1-home_wp)) + geom_path()



############################
cor_l2 <- read.csv("./data/correlation_L2.csv.csv", header = FALSE)
d <- as.dist(cor_dtw)

gamenames <- read.csv("./gamenames.csv", header = FALSE)
attr(d,"Labels") <- gamenames$V1

test <- hclust(d)
png("./dtw_dendrogram_l2.png", h = 5, w = 20, res = 300, units = "in")
plot(test)
dev.off()



winprob %>% filter(game_id == "2023_06_CAR_MIA") %>% ggplot(aes(x = 3600 - game_seconds_remaining, y = home_wp)) + geom_path()
winprob %>% filter(game_id == "2023_13_SF_PHI") %>% ggplot(aes(x = 3600 - game_seconds_remaining, y = 1-home_wp)) + geom_path()

winprob %>% filter(game_id == "2023_04_WAS_PHI") %>% ggplot(aes(x = 3600 - game_seconds_remaining, y = home_wp)) + geom_path()
winprob %>% filter(game_id == "2023_09_TB_HOU") %>% ggplot(aes(x = 3600 - game_seconds_remaining, y = home_wp)) + geom_path()




#https://www.sciencedirect.com/science/article/pii/S1877050917314989/pdf?md5=db6380ab1059e5d367cc5ea8c58a7a4d&pid=1-s2.0-S1877050917314989-main.pdf
#https://arxiv.org/html/2406.16171v1
#https://www.tandfonline.com/doi/full/10.1080/00036846.2022.2115451
