library(tidyverse)
winprob <- read.csv("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/PD_clusters/GregFormatClusters3.csv")
winprob2 <- winprob %>% group_by(GameID) %>% filter(!duplicated(GameID)) %>% ungroup()
winprob2 <- winprob2 %>% mutate(week = substring(winprob2$GameID,6,7) %>% as.numeric()) %>% filter(week <= 18)

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

#logistic regression
model.str <- "//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//

// The input data is a vector 'y' of length 'N'.
data {
  int<lower=0> N;
  vector[N] y;
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  real mu;
  real<lower=0> sigma;
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  y ~ normal(mu, sigma);
} "

setwd("/Users/gregorymatthews/Dropbox/")
write(model.str,"stan_model.stan")





library(rjags)
jags <-
  jags.model(
    "jags_model.bug",
    data = list(
      'y' = y,
      'x' = x,
      'x2' = x2,
      'N' = N, 
      'K' = K,
      'P' = P,
      'P2' = P2
    ),
    n.chains = 1,
    n.adapt = 100
  )

#Burnin phase or discard phase
update(jags, 1000)
a <-jags.samples(jags,c('beta0','beta1','beta2','sigma1','sigma2'),10000)
#a <-jags.samples(jags,c('alpha','beta',"ypred","mu"),100000,thin = 50)
a$beta0
a$beta1
a$beta2
a$sigma1
a$sigma2

plot(a$beta2[3,1,,1], type = "l")

acf(seq(a$beta2[1,1,,1]))

str(a)
hist(a$gamma[1,,1])
hist(a$gamma2[1,,1])

a$beta0

apply(a$beta1[,,,1], c(1,2), mean)
plot(apply(a$beta1[,,,1], c(1,2), mean)[,3], type = 'l')
abline(h = 0)
plot(apply(a$beta2[,,,1], c(1,2), mean)[,3], type = 'l')
abline(h = 0)






#year, cluster, draws
alpha <- array(NA, dim = c(25,3,1000))

for (p in 1:P){
  for (k in 1:K){
    alpha[p,k,] <- a$beta1[p,k,,1] 
  }
}

alphadf <- data.frame()
for (p in 1:P){
  for (k in 1:K){
    alphadf <- rbind(alphadf, data.frame(i = 1:1000, year=p, clust=k, alpha = exp(a$beta0[k] + a$beta1[p,k,,1] + a$beta2[p,k,,1]))
  }
}

sumalphadf <- alphadf %>% group_by(i,year) %>% summarize(sumalpha  = sum(alpha))
alphadf <- alphadf %>% left_join(sumalphadf, by = c("i","year")) %>% mutate(p = alpha/sumalpha)

ggplot(aes(x = factor(year), y = p , group = factor(year)), data = alphadf) + geom_boxplot()  + facet_grid(~clust) 




alpha1 <- exp(a$beta0[1,,1] + a$beta1[1,1,,1])
alpha2 <- exp(a$beta0[2,,1] + a$beta1[1,2,,1])
alpha3 <- exp(a$beta0[3,,1] + a$beta1[1,3,,1])

p1 <- alpha1 / (alpha1 + alpha2 + alpha3)
p2 <- alpha2 / (alpha1 + alpha2 + alpha3)
p3 <- alpha3 / (alpha1 + alpha2 + alpha3)



greg <- data.frame(i = rep(1:3, each  = 1000), p = c(p1,p2,p3))
ggplot(aes(x = i, y = p, color = factor(i)), data = greg) + geom_boxplot()



ggg <- data.frame(b = rep(1:K,each = P),year = rep(1:P,3),beta1 = c(a$beta1[,1,1,1],a$beta1[,2,1,1],a$beta1[,3,1,1]))

ggplot(aes(x = year, y = beta1, color = factor(b)), data = ggg) + geom_point() + geom_line() + geom_smooth(method = "lm")

library(rstan)
sched <- cbind(x2,x)

stan_dat <- list(
  N = nrow(y),
  K = ncol(y),
  T = max(x),
  W = max(x2),
  probs = y,
  sched = sched
)

fit <- stan(file = "/Users/gregorymatthews/Dropbox/functional_clusteringgit2/code/R/NFLmodel_week_and_season.stan", 
            data = stan_dat, 
            warmup = 500, 
            iter = 1000, 
            chains = 4, 
            cores = 4)

save(fit, file = "/Users/gregorymatthews/Dropbox/function_clusgteringgit/data/fit20250424.RData")


plot(fit, pars = c("beta_year[13,2]"))
plot(fit, pars = c(paste0("beta_week[",1:18,",1]")), inc_warmup = FALSE)
plot(fit, pars = c(paste0("beta_week[",1:18,",1]")))
plot(fit, pars = c(paste0("beta_week[",1:18,",2]")))
plot(fit, pars = c(paste0("beta_week[",1:18,",3]")))
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
W = max(x2)
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
        alpha = exp(test$beta_0[,k] + test$beta_week[,w,k] + test$beta_year[,t,k])))
        
    }
  }
}

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
  
ggplot(aes(x = w, y = mean, color = factor(k)), data = ppp %>% filter(t == 1)) + geom_point() + geom_line()
ggplot(aes(x = t, y = mean, color = factor(k)), data = ppp %>% filter(w == 1)) + 
   geom_line() + 
  geom_line(aes(x = t, y = q1, color = factor(k)), data = ppp %>% filter(w == 1), alpha = 0.5) + 
  geom_line(aes(x = t, y = q3, color = factor(k)), data = ppp %>% filter(w == 1), alpha = 0.5) + facet_wrap(~k)



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






install.packages("ggtern")