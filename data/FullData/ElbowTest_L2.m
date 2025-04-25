clc
clear

clusterstoplot = 1:10;

filedirectory = "PD Cluster Info";
load("UniformSplines.mat");

distances = zeros(length(clusterstoplot),1);

for i = 1:length(clusterstoplot)
    numclusters = clusterstoplot(i);

    distances(i) = sum(disfromcenter_L2(numclusters,filedirectory,splines));
end

figure; 
xlabel("Number of Clusters"); 
ylabel("Total Distance from Centers");

plot(clusterstoplot,distances,'.-',"MarkerSize",16);