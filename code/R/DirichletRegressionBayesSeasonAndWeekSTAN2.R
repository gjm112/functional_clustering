library(tidyverse)
winprob <- read.csv("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/PD_clusters/GregFormatClusters3.csv")
winprob2 <- winprob %>% group_by(GameID) %>% filter(!duplicated(GameID)) %>% ungroup()
winprob2 <- winprob2 %>% mutate(year = substring(winprob2$GameID,1,4) %>% as.numeric(),
                                week = substring(winprob2$GameID,6,7) %>% as.numeric())
winprob2 %>% group_by(week,year) %>% summarize(n = n()) %>% filter(week %in% c(18)) %>% print(n = 25)
#Mostly only 17 weeks, sometimes 18.  
winprob2 <- winprob2 %>% mutate(week = substring(winprob2$GameID,6,7) %>% as.numeric()) %>% filter((year <=2020 & week <= 17) | (year >= 2021 & week <= 18)) 

y <- winprob2 %>% select(L_2.Cluster.Probability_1:L_2.Cluster.Probability_3) %>% as.matrix()
x <- substring(winprob2$GameID,1,4) %>% as.numeric() - 1998 #Season
x2 <- substring(winprob2$GameID,6,7) %>% as.numeric() #Week 
x3 <- case_when(x2 <= 4 ~ 1,
                x2 <= 9 ~ 2,
                x2 <= 13 ~ 3,
                x2 <= 18 ~ 4) #Byes start in week 5.  And end after week 15.  
#y <- y[1:1000,]
colnames(y) <- NULL
#x <- x[1:1000]
N <- nrow(y)
K <- ncol(y)
P <- length(unique(x))
P2 <- length(unique(x3))

library(rstan)
sched <- cbind(x3,x)

stan_dat <- list(
  N = nrow(y),
  K = ncol(y),
  T = max(x),
  W = max(x3),
  probs = y,
  sched = sched
)

fit <- stan(file = "/Users/gregorymatthews/Dropbox/functional_clusteringgit2/code/R/NFLmodel_week_and_season.stan", 
            data = stan_dat, 
            warmup = 500, 
            iter = 1000, 
            chains = 4, 
            cores = 4)

save(fit, file = "/Users/gregorymatthews/Dropbox/functional_clusteringgit2/data/fit20250425.RData")




plot(fit, pars = c("beta_year[13,2]"))
plot(fit, pars = c(paste0("beta_week[",1:4,",1]")), inc_warmup = FALSE)
plot(fit, pars = c(paste0("beta_week[",1:4,",1]")))
plot(fit, pars = c(paste0("beta_week[",1:4,",2]")))
plot(fit, pars = c(paste0("beta_week[",1:4,",3]")))
plot(fit, pars = c(paste0("beta_year[",1:25,",1]")))
plot(fit, pars = c(paste0("beta_year[",1:25,",2]")))
plot(fit, pars = c(paste0("beta_year[",1:25,",3]")))
traceplot(fit)


str(fit)

plot(1:1000,fit@sim$sample[[1]]["beta_0[1]"][[1]])
plot(1:1000,fit@sim$sample[[2]]["beta_0[1]"][[1]])
plot(1:1000,fit@sim$sample[[3]]["beta_0[1]"][[1]])
plot(1:1000,fit@sim$sample[[4]]["beta_0[1]"][[1]])



test <- extract(fit)

N = nrow(y)
K = ncol(y)
T = max(x)
W = max(x3)
probs = y
sched = sched

results <- data.frame()

for (w in 1:W){print(w)
  for (t in 1:T){
    for (k in 1:K){
      results <- rbind(results,
                       data.frame(w = w, 
                                  t = t, 
                                  k = k, 
                                  iter = 1:2000,
                                  beta_week = test$beta_week[,w,k],
                                  beta_year = test$beta_year[,t,k],
                                  alpha = exp(test$beta_0[,k] + test$beta_week[,w,k] + test$beta_year[,t,k])))
      
    }
  }
}

ggplot(aes(x = beta_year),data = results %>% filter(t != 1)) + geom_density() + facet_grid(k~factor(t))

mn <- results %>% 
  group_by(w, t, k) %>%
  summarize(mean = mean(alpha))

ggplot(aes(x = w, y = mean, color = factor(k)), data = mn %>% filter(t == 1)) + geom_point() + geom_line()

ppp <- results %>% 
  group_by(w, t, iter) %>%
  mutate(p = alpha / sum(alpha)) %>% 
  group_by(w, t, k) %>%
  summarize(mean = mean(p), 
            q3 = quantile(p,0.9), 
            q1 = quantile(p,0.1))

ggplot(aes(x = w, y = mean, color = factor(k)), data = ppp ) + 
  geom_point() + geom_line(aes(group = t)) + 
  geom_line(aes(x = w, y = q1, color = factor(k)), data = ppp , alpha = 0.5) + 
  geom_line(aes(x = w, y = q3, color = factor(k)), data = ppp , alpha = 0.5) + facet_wrap(~k)

ggplot(aes(x = t, y = mean, color = factor(k)), data = ppp ) + 
  geom_line(aes(group = w)) + 
  geom_line(aes(x = t, y = q1, color = factor(k)), data = ppp , alpha = 0.5) + 
  geom_line(aes(x = t, y = q3, color = factor(k)), data = ppp , alpha = 0.5) + facet_wrap(~k)



library(Ternary)
test <- results %>% 
  group_by(w, t, iter) %>%
  mutate(p = alpha / sum(alpha)) %>% 
  group_by(t,k,iter) %>%
  summarize(mean = mean(p)) %>% 
  pivot_wider(names_from = k, values_from = mean)
names(test) <- c("t","iter","c1","c2","c3")

library(Ternary)
TernaryPlot("C1","C2","C3")
TernaryPoints(test[(test$t + 1998) != 2022,3:5], cex = 0.1, col = "black")
TernaryPoints(test[(test$t + 1998) == 2022,3:5], cex = 0.1, col = "red")

# Plot the points
TernaryPoints(dat[, c("sio2", "fe2o3", "al2o3")],
              cex = pointSize, # Point size
              col = pointCol,  # Point colour
              pch = 16         # Plotting symbol (16 = filled circle)
)


library(ggtern)
ggtern(data = test, aes(c1, c2, c3)) +
  geom_point(
    alpha = 0.01,
    size = 0.25,
    color = "black"
  )  + 
  theme_bw()  + tern_limits(T= 0.4 , L=0.5 , R= 0.5 )

library(ggtern)
ggtern(data = test, aes(c1, c2, c3)) +
  geom_point(
    alpha = 0.05,
    size = 0.25,
    color = "black"
  ) + geom_point(data = test %>% filter(t == 24), aes(c1, c2, c3),
                 alpha = 0.05,
                 size = 0.25,
                 color = "red"
  ) + 
  theme_bw()  + tern_limits(T= 0.4 , L=0.5 , R= 0.5 )


nfl <- read.csv("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/data/nflscoring.csv", header =TRUE)
names(nfl) <- nfl[1,]
nfl <- nfl[-1,]
nfl$MoV <- as.numeric(nfl$MoV)
nfl$Year <- as.numeric(nfl$Year)
library(tidyverse)

ggplot(aes(x = Year, y = MoV), data = nfl %>% filter(Year >= 1998)) + geom_point() + geom_path()


