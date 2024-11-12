library(tidyverse)
#number of clusters 
k <- 5
dat <- read.csv(paste0("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/data/FullData/No Overtime Cluster Info/ClusterInfo",k,".csv"))
dat <- dat %>% mutate(Decade = case_when(Year <= 2009 ~ "1999-2009",
                                  Year <= 2019 ~ "2010-2019",
                                  Year <= 2024 ~ "2020-2024")) 

#Fill in zeroes
library(tidyverse)
dat %>% group_by(H_1.Cluster, Year) %>% summarize(n = n())
years <- data.frame(Year = 1999:2023, H_1.Cluster = rep(1:k,each = 25))
all <- years %>% left_join(dat %>% group_by(H_1.Cluster, Year) %>% summarize(n = n()), by = c("Year","H_1.Cluster")) 
all$n[is.na(all$n)] <- 0

all  %>% ggplot(aes(y = n, x = Year)) + geom_point() + geom_path() +  facet_wrap(~H_1.Cluster, scales = "free_y") + geom_smooth()


library(tidyverse)
dat %>% group_by(L_2.Cluster, Decade) %>% summarize(n = n())
years <- data.frame(Decade = c("1999-2009","2010-2019","2020-2024"), L_2.Cluster = rep(1:k,each = 3))
all <- years %>% left_join(dat %>% group_by(L_2.Cluster, Decade) %>% summarize(n = n()), by = c("Decade","L_2.Cluster")) 
all$n[is.na(all$n)] <- 0

#levs <- dat %>% pivot_longer(cols = c(Home.Team,Away.Team), values_to = "Team") %>% group_by(Team, L_2.Cluster) %>% summarize(n = n()) %>% mutate(prop = n/sum(n)) %>% filter(L_2.Cluster == 3) %>% arrange(-prop) %>% pull(Team)
ggplot(aes(x = factor(Year), y = n, fill = as.factor(L_2.Cluster)), data = all) + geom_bar(position="fill", stat="identity")
ggplot(aes(x = factor(Decade), y = n, fill = as.factor(L_2.Cluster)), data = all) + geom_bar(position="fill", stat="identity")

all %>% group_by(Year) %>% mutate(prop = n/sum(n)) %>% filter(L_2.Cluster == 5) %>% arrange(-prop)
all %>% group_by(Year) %>% mutate(prop = n/sum(n)) %>% filter(L_2.Cluster == 4) %>% arrange(-prop)
all %>% group_by(Year) %>% mutate(prop = n/sum(n)) %>% filter(L_2.Cluster == 3) %>% arrange(-prop)
all %>% group_by(Year) %>% mutate(prop = n/sum(n)) %>% filter(L_2.Cluster == 2) %>% arrange(-prop)
all %>% group_by(Year) %>% mutate(prop = n/sum(n)) %>% filter(L_2.Cluster == 1) %>% arrange(-prop)

test <- all %>% pivot_wider(names_from = "L_2.Cluster", values_from = n)
chisq.test(test[,-1])

all %>% filter(L_2.Cluster == 5) %>% arrange(n)

all  %>% ggplot(aes(y = n, x = Year)) + geom_point() + geom_path() +  facet_wrap(~L_2.Cluster, scales = "free_y") + geom_smooth()


temp <- dat %>% group_by(H_1.Cluster, Year) %>% summarize(n = n()) %>% pivot_wider(names_from = H_1.Cluster, values_from = n)
temp <- temp %>% select(-Year) 
temp <- as.matrix(temp)
temp[is.na(temp)] <- 0

test <- chisq.test(temp)



#By week                                                                                                                                         
dat <- read.csv("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/data/FullData/No Overtime Cluster Info/ClusterInfo5.csv")
dat %>% filter(Game.Number <= 18) %>%  group_by(Game.Number, H_1.Cluster) %>% summarize(n = n()) %>% mutate(prop = n/sum(n)) %>% ggplot(aes(x = Game.Number, y = prop)) + geom_point()  + facet_wrap(~H_1.Cluster, scales = "free_y") + geom_smooth()
clust1 <- dat %>% filter(H_1.Cluster == 1 & Game.Number <= 18) %>% group_by(Game.Number) %>% summarize(n = n())

#Model prob clust 1 vs other
a <- glm((H_1.Cluster == 1) ~ Game.Number, data = dat, family = "binomial")
summary(a)

#By team
dat <- read.csv("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/data/FullData/No Overtime Cluster Info/ClusterInfo5.csv")
dat$Home.Team[dat$Home.Team == "STL"] <- "LA"
dat$Home.Team[dat$Home.Team == "OAK"] <- "LV"
dat$Home.Team[dat$Home.Team == "SD"] <- "LAC"
dat$Away.Team[dat$Away.Team == "STL"] <- "LA"
dat$Away.Team[dat$Away.Team == "OAK"] <- "LV"
dat$Away.Team[dat$Away.Team == "SD"] <- "LAC"

temp <- dat %>% pivot_longer(cols = c(Home.Team,Away.Team), values_to = "Team") %>% group_by(Team, L_2.Cluster) %>% summarize(n = n()) %>% pivot_wider(names_from = "L_2.Cluster", values_from = n)
chisq.test(temp[,-1])

greg <- dat %>% pivot_longer(cols = c(Home.Team,Away.Team), values_to = "Team") %>% group_by(Team, L_2.Cluster) %>% summarize(n = n())
ggplot(aes(x = Team, y = n, fill = as.factor(L_2.Cluster)), data = greg) + geom_bar(position="fill", stat="identity")

greg <- dat  %>% group_by(Home.Team, L_2.Cluster) %>% summarize(n = n())
ggplot(aes(x = Home.Team, y = n, fill = as.factor(L_2.Cluster)), data = greg) + geom_bar(position="fill", stat="identity")



dat %>% filter(Game.Number <= 18) %>%  group_by(Game.Number, H_1.Cluster) %>% summarize(n = n()) %>% mutate(prop = n/sum(n)) %>% ggplot(aes(x = Game.Number, y = prop)) + geom_point()  + facet_wrap(~H_1.Cluster, scales = "free_y") + geom_smooth()

greg <- dat  %>% group_by(Away.Team, L_2.Cluster) %>% summarize(n = n())
levs <- dat  %>% group_by(Away.Team, L_2.Cluster) %>% summarize(n = n()) %>% mutate(prop = n/sum(n)) %>% filter(L_2.Cluster == 5) %>% arrange(-prop) %>% pull(Away.Team)
ggplot(aes(x = factor(Away.Team, levels = levs), y = n, fill = as.factor(L_2.Cluster)), data = greg) + geom_bar(position="fill", stat="identity")

greg <- dat  %>% group_by(Home.Team, L_2.Cluster) %>% summarize(n = n())
levs <- dat  %>% group_by(Home.Team, L_2.Cluster) %>% summarize(n = n()) %>% mutate(prop = n/sum(n)) %>% filter(L_2.Cluster == 5) %>% arrange(-prop) %>% pull(Home.Team)
ggplot(aes(x = factor(Home.Team, levels = levs), y = n, fill = as.factor(L_2.Cluster)), data = greg) + geom_bar(position="fill", stat="identity")

greg <- dat %>% pivot_longer(cols = c(Home.Team,Away.Team), values_to = "Team") %>% group_by(Team, L_2.Cluster) %>% summarize(n = n())
levs <- dat %>% pivot_longer(cols = c(Home.Team,Away.Team), values_to = "Team") %>% group_by(Team, L_2.Cluster) %>% summarize(n = n()) %>% mutate(prop = n/sum(n)) %>% filter(L_2.Cluster == 5) %>% arrange(-prop) %>% pull(Team)
ggplot(aes(x = factor(Team, levels = levs), y = n, fill = as.factor(L_2.Cluster)), data = greg) + geom_bar(position="fill", stat="identity")
levs <- dat %>% pivot_longer(cols = c(Home.Team,Away.Team), values_to = "Team") %>% group_by(Team, L_2.Cluster) %>% summarize(n = n()) %>% mutate(prop = n/sum(n)) %>% filter(L_2.Cluster == 3) %>% arrange(-prop) %>% pull(Team)
ggplot(aes(x = factor(Team, levels = levs), y = n, fill = as.factor(L_2.Cluster)), data = greg) + geom_bar(position="fill", stat="identity")



test <- greg %>% pivot_wider(names_from = L_2.Cluster, values_from = n)
test <- test[-1] 
test[is.na(test)] <- 0
chisq.test(test)     

#Multinomial Modeling 
a <- glm(L_2.Cluster == 5 ~ as.factor(Home.Team) , data = dat, family = "binomial")
b <- glm(L_2.Cluster == 5 ~ 1 , data = dat, family = "binomial")
anova(a,b)

                                                                                                                      

                                                                                                                      

dat <- read.csv("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/data/FullData/No Overtime Cluster Info/ClusterInfo7.csv")
dat$Home.Team[dat$Home.Team == "STL"] <- "LA"
dat$Home.Team[dat$Home.Team == "OAK"] <- "LV"
dat$Home.Team[dat$Home.Team == "SD"] <- "LAC"
dat$Away.Team[dat$Away.Team == "STL"] <- "LA"
dat$Away.Team[dat$Away.Team == "OAK"] <- "LV"
dat$Away.Team[dat$Away.Team == "SD"] <- "LAC"
