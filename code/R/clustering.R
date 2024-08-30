#Raw data from here: https://github.com/nflverse/nflverse-data/releases/tag/pbp

cor_dtw <- read.csv("./data/correlation_dtw.csv", header = FALSE)
d <- as.dist(cor_dtw)

gamenames <- read.csv("./gamenames.csv", header = FALSE)
attr(d,"Labels") <- gamenames$V1

test <- hclust(d)
png("./dtw_dendrogram.png", h = 5, w = 20, res = 300, units = "in")
plot(test)
dev.off()


############################
cor_l2 <- read.csv("./data/correlation_L2.csv.csv", header = FALSE)
d <- as.dist(cor_dtw)

gamenames <- read.csv("./gamenames.csv", header = FALSE)
attr(d,"Labels") <- gamenames$V1

test <- hclust(d)
png("./dtw_dendrogram_l2.png", h = 5, w = 20, res = 300, units = "in")
plot(test)
dev.off()

