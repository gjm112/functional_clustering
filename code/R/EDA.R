library(tidyverse)
#number of clusters 
k <- 5
dat <- read.csv(paste0("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/data/FullData/No Overtime Cluster Info/ClusterInfo",k,".csv"))
dat <- dat %>% mutate(Decade = case_when(Year <= 2009 ~ "1999-2009",
                                  Year <= 2019 ~ "2010-2019",
                                  Year <= 2024 ~ "2020-2024")) 


#Fill in zeroes
library(tidyverse)
dat %>% group_by(L_2.Cluster, Year) %>% summarize(n = n())
years <- data.frame(Year = 1999:2023, L_2.Cluster = rep(1:k,each = 25))
all <- years %>% left_join(dat %>% group_by(L_2.Cluster, Year, Decade) %>% summarize(n = n()), by = c("Year","L_2.Cluster")) 
all$n[is.na(all$n)] <- 0

all  %>% ggplot(aes(y = n, x = Year, col = Decade)) + geom_point() + geom_path() +  facet_wrap(~L_2.Cluster, scales = "free_y") + geom_smooth()


library(tidyverse)
dat %>% group_by(L_2.Cluster, Decade) %>% summarize(n = n())
years <- data.frame(Decade = c("1999-2009","2010-2019","2020-2024"), L_2.Cluster = rep(1:k,each = 3))
all <- years %>% left_join(dat %>% group_by(Year, L_2.Cluster, Decade) %>% summarize(n = n()), by = c("Decade","L_2.Cluster")) 
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
test[is.na(test)] <- 0
chisq.test(test[,-c(1:2)])

all %>% filter(L_2.Cluster == 5) %>% arrange(n)

all  %>% ggplot(aes(y = n, x = Year)) + geom_point() + geom_path() +  facet_wrap(~L_2.Cluster, scales = "free_y") + geom_smooth()


temp <- dat %>% group_by(L_2.Cluster, Year) %>% summarize(n = n()) %>% pivot_wider(names_from = L_2.Cluster, values_from = n)
temp <- temp %>% select(-Year) 
temp <- as.matrix(temp)
temp[is.na(temp)] <- 0

test <- chisq.test(temp)
test


#By week                                                                                                                                         
dat <- read.csv("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/data/FullData/No Overtime Cluster Info/ClusterInfo5.csv")
dat <- dat %>% mutate(Decade = case_when(Year <= 2009 ~ "1999-2009",
                                         Year <= 2019 ~ "2010-2019",
                                         Year <= 2024 ~ "2020-2024")) 


#dat %>% filter(Game.Number <= 17) %>%  group_by(Game.Number, L_2.Cluster, Decade) %>% summarize(n = n()) %>% group_by(Decade, Game.Number) %>%  mutate(prop = n/sum(n)) %>% ggplot(aes(x = Game.Number, y = prop, col = Decade)) + geom_point()  + facet_wrap(~L_2.Cluster, scales = "free_y") + geom_smooth(se = FALSE, method = "lm", formula = y ~ x + I(x^2))
library(tidyverse)
dat <- dat %>% mutate(weekgroup = case_when(Game.Number <= 4 ~ "Weeks 1-4",
                                            Game.Number <=13 & Game.Number >=5 ~ "Weeks 5-13",
                                            Game.Number >= 14 ~ "Weeks 14-17"))

dat <- dat %>% filter(Game.Number <= 17) %>% mutate(weekgroup = case_when(Game.Number <= 4 ~ "Weeks 1-4",
                                            Game.Number <=14 & Game.Number >=5 ~ "Weeks 5-14",
                                            Game.Number >= 15 & Game.Number <= 17 ~ "Weeks 15-17")) %>%  group_by(weekgroup, L_2.Cluster) %>% summarize(n = n())
#ggplot(aes(x = Game.Number, y = L_2.Cluster), data = sub) +geom_bar()
ggplot(aes(x = factor(weekgroup), y = n, fill = as.factor(L_2.Cluster)), data = sub) + geom_bar(position="fill", stat="identity")

chisq.test(table(dat$weekgroup, dat$L_2.Cluster))
prop.table(table(dat$weekgroup, dat$L_2.Cluster),1)

#Posthoc
chisq.test(table(dat$weekgroup, dat$L_2.Cluster)[,c(1,2)])
chisq.test(table(dat$weekgroup, dat$L_2.Cluster)[,c(1,3)])
chisq.test(table(dat$weekgroup, dat$L_2.Cluster)[,c(1,4)])
chisq.test(table(dat$weekgroup, dat$L_2.Cluster)[,c(1,5)])
chisq.test(table(dat$weekgroup, dat$L_2.Cluster)[,c(2,3)])
chisq.test(table(dat$weekgroup, dat$L_2.Cluster)[,c(2,4)])
chisq.test(table(dat$weekgroup, dat$L_2.Cluster)[,c(2,5)])
chisq.test(table(dat$weekgroup, dat$L_2.Cluster)[,c(3,4)])
chisq.test(table(dat$weekgroup, dat$L_2.Cluster)[,c(3,5)])
chisq.test(table(dat$weekgroup, dat$L_2.Cluster)[,c(4,5)])

prop.table(table(dat$weekgroup, dat$L_2.Cluster)[,c(2,5)],2)




clust1 <- dat %>% filter(L_2.Cluster == 1 & Game.Number <= 17) %>% group_by(Game.Number) %>% summarize(n = n())


#By team
dat$Home.Team[dat$Home.Team == "STL"] <- "LA"
dat$Home.Team[dat$Home.Team == "OAK"] <- "LV"
dat$Home.Team[dat$Home.Team == "SD"] <- "LAC"
dat$Away.Team[dat$Away.Team == "STL"] <- "LA"
dat$Away.Team[dat$Away.Team == "OAK"] <- "LV"
dat$Away.Team[dat$Away.Team == "SD"] <- "LAC"


levs <- dat  %>% group_by(Home.Team, L_2.Cluster) %>% summarize(n = n()) %>% mutate(prop = n/sum(n)) %>% filter(L_2.Cluster == 3) %>% arrange(-prop) %>% pull(Home.Team)
sub <- dat %>% group_by(Home.Team, L_2.Cluster) %>% summarize(n = n())
ggplot(aes(x = factor(Home.Team, levels = levs), y = n, fill = factor(L_2.Cluster, levels = c(1,2,4,5,3))), data = sub) + geom_bar(position="fill", stat="identity")
sub %>% filter(L_2.Cluster == 3) %>% arrange(-n)

levs <- dat  %>% group_by(Away.Team, L_2.Cluster) %>% summarize(n = n()) %>% mutate(prop = n/sum(n)) %>% filter(L_2.Cluster == 3) %>% arrange(-prop) %>% pull(Away.Team)
sub <- dat %>% group_by(Away.Team, L_2.Cluster) %>% summarize(n = n())
ggplot(aes(x = factor(Away.Team, levels = levs), y = n, fill = factor(L_2.Cluster, levels = c(1,2,4,5,3))), data = sub) + geom_bar(position="fill", stat="identity")
sub %>% filter(L_2.Cluster == 3) %>% arrange(-n)


#levs <- dat  %>% group_by(Home.Team,Away.Team, L_2.Cluster) %>% summarize(n = n()) %>% mutate(prop = n/sum(n)) %>% filter(L_2.Cluster == 3) %>% arrange(-prop) %>% pull(Home.Team)
sub <- dat %>% group_by(Home.Team,Away.Team,Year,Game.Number, L_2.Cluster) %>% summarize(n = n())
sub %>% filter(L_2.Cluster == 3) %>% arrange(-n) %>% View()
sub %>% filter(L_2.Cluster == 3) %>% arrange(-n)


#Model prob clust 1 vs other
dat <- read.csv("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/data/FullData/No Overtime Cluster Info/ClusterInfo5.csv")
dat <- dat %>% filter(Game.Number <= 17) 
dat <- as.data.frame(dat)
a <- glm((L_2.Cluster == 5) ~ Game.Number , data = dat, family = "binomial")
summary(a)

sub <- dat %>% filter(Game.Number <=17)
chisq.test(table(sub$Game.Number,sub$L_2.Cluster))
prop.table(table(sub$Game.Number,sub$L_2.Cluster),1)


sub <- sub %>% group_by(Game.Number, L_2.Cluster) %>% summarize(n = n())
ggplot(aes(x = Game.Number, y = L_2.Cluster), data = sub) +geom_bar()
ggplot(aes(x = factor(Game.Number), y = n, fill = as.factor(L_2.Cluster)), data = sub) + geom_bar(position="fill", stat="identity")

dat <- dat %>% mutate(weekgroup = case_when(Game.Number <= 4 ~ "Weeks 1-4",
                                     Game.Number <=13 & Game.Number >=5 ~ "Weeks 4-13",
                                     Game.Number >= 14 ~ "Weeks 14-17"))
sub <- dat %>% mutate(weekgroup = case_when(Game.Number <= 4 ~ "Weeks 1-4",
                                            Game.Number <=13 & Game.Number >=5 ~ "Weeks 4-13",
                                            Game.Number >= 14 ~ "Weeks 14-17")) %>%  group_by(weekgroup, L_2.Cluster) %>% summarize(n = n())
#ggplot(aes(x = Game.Number, y = L_2.Cluster), data = sub) +geom_bar()
ggplot(aes(x = factor(weekgroup), y = n, fill = as.factor(L_2.Cluster)), data = sub) + geom_bar(position="fill", stat="identity")

prop.table(table(dat$weekgroup, dat$L_2.Cluster),1)
chisq.test(table(dat$weekgroup, dat$L_2.Cluster))

b <- lm(prop ~ Game.Number, data = dat)
summary(b)


#Postgame vs regular season





c(0.465, 0.39, 0.676, 0.0223,  0.0418)
p.adjust(c(0.465, 0.39, 0.676, 0.0223,  0.0418), method ="BH")


p.adjust(c( 0.329 , 0.281, 0.714 , 0.0389,  0.0181), method ="BH")
  
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





#Post game vs regular season
library(tidyverse)
#number of clusters 
k <- 5
dat <- read.csv(paste0("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/data/FullData/No Overtime Cluster Info/ClusterInfo",k,".csv"))
dat <- dat %>% mutate(Decade = case_when(Year <= 2009 ~ "1999-2009",
                                         Year <= 2019 ~ "2010-2019",
                                         Year <= 2024 ~ "2020-2024")) 
dat <- dat %>% mutate(regseason = ifelse((Year <= 2020 &
                                       Game.Number <= 17) | (Year >= 2021 & Game.Number <= 18), 1, 0))
table(dat$Game.Number)
table(dat$Year, dat$Game.Number)
prop.table(table(dat$regseason, dat$L_2.Cluster),1)
fisher.test(table(dat$L_2.Cluster,dat$regseason))

sub <- dat %>% group_by(regseason,L_2.Cluster) %>% summarize(n = n())
ggplot(aes(x = factor(regseason), y = n, fill = as.factor(L_2.Cluster)), data = sub) + geom_bar(position="fill", stat="identity")

