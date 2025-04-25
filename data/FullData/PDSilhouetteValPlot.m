clc
clear

savedirectory = "PD Cluster Info";
clusterstoplot = 2:10; 

mean_s_l2 = zeros(length(clusterstoplot),1);
mean_s_h1 = zeros(length(clusterstoplot),1);

mean_sprob_l2 = zeros(length(clusterstoplot),1);
mean_sprob_h1 = zeros(length(clusterstoplot),1);

for i  = 1:length(clusterstoplot)
    numclusters = clusterstoplot(i);
    filename = savedirectory + "/ClusterInfo" +num2str(numclusters) + ".csv";

    if ~ isfile(filename)
        error("Need to compute silhouette values ahead of time.")
    end
    T = readtable(filename,"VariableNamingRule","preserve");

    s_l2 = T.("L2 silhouette");
    s_h1 = T.("H1 silhouette");

    mean_s_l2(i) = mean(s_l2);
    mean_s_h1(i) = mean(s_h1);
end

figure;
xlabel("Number of Clusters");
ylabel("Average Silhouette Value");
hold on
plot(clusterstoplot, mean_s_l2, '.-', "MarkerSize", 10);
plot(clusterstoplot, mean_s_h1, '.-', "MarkerSize", 10);
hold off
legend(["$L_2$ correlation" ,"$H_1$ correlation"],"Interpreter","latex");
