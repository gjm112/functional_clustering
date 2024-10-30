clc
clear

cor_l2 = readmatrix("correlation_L2.csv");
cor_h1 = readmatrix("correlation_H1.csv");
load("UniformSplines.mat");

% hclust
Z_l2 = linkage(cor_l2,"complete");
Z_h1 = linkage(cor_h1,"complete");

figure;
dendrogram(Z_l2);
%for the full number of leaves
%dendrogram(Z_l2,length(splines));

figure; 
dendrogram(Z_h1); 
%for the full number of leaves
% dendrogram(Z_h1,length(splines));


% generate the actual clusters here 
C_l2 =  cluster(Z_l2,'MaxClust',20);
numclusters_l2 = length(unique(C_l2));

C_h1 =  cluster(Z_h1,'MaxClust',20);
numclusters_h1 = length(unique(C_h1));

% create the center b-splines for the given clusters

for i = 1:numclusters_l2
    center_l2(i) = NonUniformBSplineCenter(splines(C_l2 == i));
end

for i = 1:numclusters_h1
    center_h1(i) = NonUniformBSplineCenter(splines(C_h1 == i));
end

% plot the clusters and centers 
clusterstoplot = 1:numclusters_l2;

for currentcluster = clusterstoplot
    figure;
    hold on;
    pltsplines = splines(C_l2 == currentcluster);
    for i = 1:sum(C_l2 == currentcluster)
        fnplt(pltsplines(i),'k--',0.1);
    end
    fnplt(center_l2(currentcluster));
    hold off
end


% save the cluster information to file

game_ids = readtable("gamenames.csv");
game_ids.Properties.VariableNames = ["Year", "Game Number", "Home Team", "Away Team"];

% add the cluster info
game_ids.("L_2 Cluster") = C_l2;
game_ids.("H_1 Cluster") = C_h1;

writetable(game_ids,"ClusterInfo.csv");
% Save centers
save("ClusterCenters.mat","center_l2","center_h1");