library(DirichletReg)
inputData <- ArcticLake  # plug-in your data here.
set.seed(100)
inputData
train <- sample (1:nrow (inputData), round (0.7*nrow (inputData)))  # 70% training sample
inputData_train <- inputData [train, ] # training Data
inputData_test <- inputData [-train, ] # test Data
inputData$Y <- DR_data (inputData[,1:3])  # prepare the Y's
inputData_train$Y <- DR_data (inputData_train[,1:3])
inputData_test$Y <- DR_data (inputData_test[,1:3])

res1 <- DirichReg(Y ~ depth + I(depth^2), inputData_train)  # modify the predictors and input data here



probclust <- read.csv("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/data/FullData/PD Cluster Info/ClusterInfo5.csv")
probclust$Y <- DR_data(probclust %>% select(L_2.Cluster.Probability_1:L_2.Cluster.Probability_5))  # prepare the Y's
mod1 <- DirichReg(Y ~ as.factor(Year) + as.factor(Game.Number), probclust)
mod1 <- DirichReg(Y ~  as.factor(Game.Number), probclust %>% filter(Game.Number <= 18))
summary(mod1)
