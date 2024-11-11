dat <- read.csv("/Users/gregorymatthews/Dropbox/functional_clusteringgit2/data/FullData/No Overtime Cluster Info/ClusterInfo10.csv")

#Fill in zeroes
library(tidyverse)
dat %>% group_by(L_2.Cluster, Year) %>% summarize(n = n()) %>% ggplot(aes(y = n, x = Year)) + geom_point() + geom_path() +  facet_wrap(~L_2.Cluster, scales = "free_y") + geom_smooth()

temp <- dat %>% group_by(H_1.Cluster, Year) %>% summarize(n = n()) %>% pivot_wider(names_from = H_1.Cluster, values_from = n)
temp <- temp %>% select(-Year) 
temp <- as.matrix(temp)
temp[is.na(temp)] <- 0

test <- chisq.test(temp)
                                                                                                                                         