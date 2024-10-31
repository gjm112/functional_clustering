clc
clear

cor_l2 = readmatrix("correlation_L2.csv");
cor_h1 = readmatrix("correlation_H1.csv");
load("UniformSplines.mat");

% hclust
Z_l2 = linkage(cor_l2,"complete");
Z_h1 = linkage(cor_h1,"complete");

figure;
[~, original_l2] = dendrogram(Z_l2);
%for the full number of leaves
%dendrogram(Z_l2,length(splines));

figure; 
[~, original_h1] = dendrogram(Z_h1); 
%for the full number of leaves
% dendrogram(Z_h1,length(splines));


% generate the actual clusters here 
C_l2 =  cluster(Z_l2,'MaxClust',10);
numclusters_l2 = length(unique(C_l2));

C_h1 =  cluster(Z_h1,'MaxClust',10);
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
l2savefolder = "Figures/L2 " + num2str(numclusters_l2) + " clusters";
status = mkdir(l2savefolder);

for currentcluster = clusterstoplot
    figure;
    hold on;
    pltsplines = splines(C_l2 == currentcluster);
    for i = 1:sum(C_l2 == currentcluster)
        fnplt(pltsplines(i),'k--',0.1);
    end
    fnplt(center_l2(currentcluster));
    plottitle = "$L^2$ Cluster " + num2str(currentcluster);
    hold off
    title(plottitle,'Interpreter','latex');
    saveas(gcf,l2savefolder+"/cluster_" + num2str(currentcluster),"jpeg");
end

% plot the clusters and centers 
clusterstoplot = 1:numclusters_h1;
h1savefolder = "Figures/H1 " + num2str(numclusters_l2) + " clusters";
status = mkdir(h1savefolder);

for currentcluster = clusterstoplot
    figure;
    hold on;
    pltsplines = splines(C_h1 == currentcluster);
    for i = 1:sum(C_h1 == currentcluster)
        fnplt(pltsplines(i),'k--',0.1);
    end
    fnplt(center_h1(currentcluster));
    plottitle = "$H^1$ Cluster " + num2str(currentcluster);  
    hold off
    title(plottitle,'Interpreter','latex');
    saveas(gcf,h1savefolder+"/cluster_" + num2str(currentcluster),"jpeg");
end

% save the cluster information to file

game_ids = readtable("gamenames.csv");
game_ids.Properties.VariableNames = ["Year", "Game Number", "Home Team", "Away Team"];

% add the cluster info
game_ids.("L_2 Cluster") = C_l2;
game_ids.("H_1 Cluster") = C_h1;

writetable(game_ids,"ClusterInfo_" + num2str(numclusters_l2) + ".csv");
% Save centers
save("ClusterCenters_"+ num2str(numclusters_l2) +".mat","center_l2","center_h1");