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
model.str <- "model {
#Likelihood
  for (i in 1:N)
  {
    y[i,1:K] ~ ddirch(xb[i,1:K])
    
    for (k in 1:K){
    xb[i,k] <- exp(beta0[k] + beta1[x[i],k] + beta2[x2[i],k])
    }
    
  }

#Priors
for (k in 1:K){
beta0[k] ~ dnorm(0,10) 
beta1[1,k] <- 0
beta2[1,k] <- 0
}



for (p in 2:P){
  for (k in 1:K){
  beta1[p,k] ~ dnorm(gamma*beta1[p-1,k],10)
  }
}

for (p2 in 2:P2){
  for (k in 1:K){
  beta2[p2,k] ~ dnorm(gamma2*beta2[p2-1,k],10)
  }
}



gamma ~ dunif(-1,1)
gamma2 ~ dunif(-1,1)

} "

#logistic regression
model.str <- "model {
#Likelihood
  for (i in 1:N)
  {
    y[i,1:K] ~ ddirch(xb[i,1:K])
    
    for (k in 1:K){
    xb[i,k] <- exp(beta0[k])
    }
    
  }

#Priors
for (k in 1:K){
beta0[k] ~ dnorm(0,10) 
}



} "

setwd("/Users/gregorymatthews/Dropbox/")
write(model.str,"jags_model.bug")



#logistic regression
model.str <- "model {
#Likelihood
  for (i in 1:N)
  {
    y[i,1:K] ~ ddirch(xb[i,1:K])
    
    for (k in 1:K){
    xb[i,k] <- exp(beta0[k] + beta1[x[i],k] + beta2[x2[i],k])
    }
    
  }
  
  #Priors
for (k in 1:K){
beta0[k] ~ dnorm(0,.000001) 
}

for (p in 1:P){
  for (k in 1:K){
  beta1[p,k] ~ dnorm(0,sigma1)
  }
}

for (p2 in 1:P2){
  for (k in 1:K){
  beta2[p2,k] ~ dnorm(0,sigma2)
  }
}

sigma1 ~ dnorm(0, 0.001)T(0,1000)
sigma2 ~ dnorm(0, 0.001)T(0,1000)
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


