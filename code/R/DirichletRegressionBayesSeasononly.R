library(tidyverse)
winprob <- read.csv("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/PD_clusters/GregFormatClusters3.csv")
winprob2 <- winprob %>% group_by(GameID) %>% filter(!duplicated(GameID)) %>% ungroup()

y <- winprob2 %>% select(L_2.Cluster.Probability_1:L_2.Cluster.Probability_3) %>% as.matrix()
x <- substring(winprob2$GameID,1,4) %>% as.numeric() - 1998
x2 <- substring(winprob2$GameID,6,7) %>% as.numeric()
#y <- y[1:1000,]
colnames(y) <- NULL
#x <- x[1:1000]
N <- nrow(y)
K <- ncol(y)
P <- length(unique(x))

#logistic regression
model.str <- "model {
#Likelihood
  for (i in 1:N)
  {
    y[i,1:K] ~ ddirch(xb[i,1:K])
    
    for (k in 1:K){
    xb[i,k] <- exp(beta0[k] + beta1[x[i],k])
    }
    
  }

#Priors
for (k in 1:K){
beta0[k] ~ dunif(0,10) 
beta1[1,k] ~ dnorm(0,10)
}

for (p in 2:P){
  for (k in 1:K){
  beta1[p,k] ~ dnorm(gamma*beta1[p-1,k],10)
  }
}

gamma ~ dunif(0,2)





} "

setwd("/Users/gregorymatthews/Dropbox/")
write(model.str,"jags_model.bug")

library(rjags)
jags <-
  jags.model(
    "jags_model.bug",
    data = list(
      'y' = y,
      'x' = x,
      'N' = N, 
      'K' = K,
      'P' = P
    ),
    n.chains = 1,
    n.adapt = 100
  )

#Burnin phase or discard phase
update(jags, 1000)

a <-jags.samples(jags,c('beta0','beta1','gamma'),1000)
a <-jags.samples(jags,c('alpha','beta',"ypred","mu"),100000,thin = 50)
str(a)
a$gamma

a$beta0

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
    alphadf <- rbind(alphadf, data.frame(i = 1:1000, year=p, clust=k, alpha = exp(a$beta0[k] + a$beta1[p,k,,1])))
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


