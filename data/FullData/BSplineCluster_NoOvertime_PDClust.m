clc
clear

numclusters = 5;
make_figures = false; 

cor_l2 = readmatrix("cor_L2_no_overtime.csv");
cor_h1 = readmatrix("cor_H1_no_overtime.csv");
load("Splines_no_overtime.mat");

% generate the actual clusters here 
[C_l2,~,p_l2] =  PDclust(cor_l2,numclusters);

[C_h1,~,p_h1] =  PDclust(cor_h1,numclusters);

% create the center b-splines for the given clusters

for i = 1:numclusters
    center_l2(i) = NonUniformBSplineCenter(splines(C_l2 == i));
end

for i = 1:numclusters
    center_h1(i) = NonUniformBSplineCenter(splines(C_h1 == i));
end

if make_figures
    % plot the clusters and centers
    clusterstoplot = 1:numclusters;
    l2savefolder = "PD Figures No OverTime/L2 " + num2str(numclusters) + " clusters";
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
    clusterstoplot = 1:numclusters;
    h1savefolder = "PD Figures No Overtime/H1 " + num2str(numclusters) + " clusters";
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
end

% save the cluster information to file

game_ids = readtable("gamenames_no_overtime.csv");
game_ids.Properties.VariableNames = ["Year", "Game Number", "Home Team", "Away Team"];

% add the cluster info
game_ids.("L_2 Cluster") = C_l2;
game_ids.("L_2 Cluster Probability") = p_l2;
game_ids.("H_1 Cluster") = C_h1;
game_ids.("H_1 Cluster Probability") = p_h1;


clusterfolder = "PD No Overtime Cluster Info/";
status = mkdir(clusterfolder);

writetable(game_ids,clusterfolder + "ClusterInfo" + num2str(numclusters) + ".csv");
% Save centers
save(clusterfolder+"ClusterCenters_"+ num2str(numclusters) +".mat","center_l2","center_h1");