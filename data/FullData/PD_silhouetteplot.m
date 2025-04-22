clc
clear

clusterstoplot = 2:10;

plotfolder = "PD Silhouette Plots";

cor_l2 = readmatrix("correlation_L2.csv");
cor_h1 = readmatrix("correlation_H1.csv");
load("UniformSplines.mat");
game_ids = readtable("gamenames.csv");
filedirectory = "PD Cluster Info";

status = mkdir(plotfolder + "/H1");
status = mkdir(plotfolder + "/L2");
status = mkdir(plotfolder + "/probabilisticL2");
status = mkdir(plotfolder + "/probabilisticH1");


for numclusters = clusterstoplot
    filename = filedirectory + "/ClusterInfo" +num2str(numclusters) + ".csv";

    if ~ isfile(filename)
        [c_l2,p_l2,c_h1,p_h1] = PDCluster_and_save(cor_l2, cor_h1, numclusters, ...
            splines, game_ids, filedirectory);
    else
        [c_l2,p_l2,c_h1,p_h1] = PDClusterDataFromSave(numclusters, filedirectory);
    end

    figure;
    [s_l2, plot_l2] = silhouette(cor_l2,c_l2,"Euclidean");
    title("$L_2$ for " + num2str(numclusters) + " Clusters", "Interpreter","latex");
    saveas(gcf,plotfolder+ "/L2/" + num2str(numclusters) + "clusters","jpeg");

    figure;
    [s_h1,plot_h1] = silhouette(cor_h1,c_h1,"Euclidean");
    title("$H_1$ for " + num2str(numclusters) + " Clusters", "Interpreter","latex");
    saveas(gcf,plotfolder+ "/H1/" + num2str(numclusters) + "clusters","jpeg");

    figure;
    Silh(p_l2);
    title("$L_2$ Probablistic Silhouette Plot for " + num2str(numclusters) + " Clusters", "Interpreter","latex");

    saveas(gcf,plotfolder+ "/probabilisticL2/" + num2str(numclusters) + "clusters","jpeg");

    figure;
    Silh(p_h1);
    title("$H_1$ Probablistic Silhouette Plot for " + num2str(numclusters) + " Clusters", "Interpreter","latex");

    saveas(gcf,plotfolder+ "/probabilisticH1/" + num2str(numclusters) + "clusters","jpeg");

    % save silhouette data to file
    T = readtable(filename,"VariableNamingRule","preserve");
    T.("L2 silhouette") = s_l2;
    T.("H1 silhouette") = s_h1;
    writetable(T,filename);
end