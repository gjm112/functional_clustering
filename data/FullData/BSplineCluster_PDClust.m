% clc
% clear
% 
numclusters = 10;
make_figures = true;
save_in_long_format = true; %save thing's in Greg's format as well.

cor_l2 = readmatrix("correlation_L2.csv");
cor_h1 = readmatrix("correlation_H1.csv");
load("UniformSplines.mat");


% generate the actual clusters here 
[C_l2,~,p_l2] =  PDclust(cor_l2,numclusters);

[C_h1,~,p_h1] =  PDclust(cor_h1,numclusters);

% create the center b-splines for the given clusters

for i = 1:numclusters
    center_l2(i) = NonUniformBSplineCenter(splines(C_l2 == i),p_l2(C_l2 == i,i));
end

for i = 1:numclusters
    center_h1(i) = NonUniformBSplineCenter(splines(C_h1 == i), p_h1(C_h1 == i,i));
end

if make_figures
    %continous colormap function 
    
    %based on winter colormap
    mycolormap = @(x) [0, x, 1-x/2 x/2]; % R G B Transparency all in [0,1]

    % plot the clusters and centers
    clusterstoplot = 1:numclusters;
    l2savefolder = "PD Figures/L2 " + num2str(numclusters) + " clusters";
    status = mkdir(l2savefolder);

    for currentcluster = clusterstoplot
        figure;
        hold on;
        pltsplines = splines(C_l2 == currentcluster);
        plt_p = p_l2(C_l2 == currentcluster,currentcluster);
        for i = 1:sum(C_l2 == currentcluster)
            points = fnplt(pltsplines(i));
            %adjusts transparancy based on probability in cluster
            plot(points(1,:), points(2,:), 'Color', mycolormap(plt_p(i))); 
        end
        fnplt(center_l2(currentcluster),'k');
        plottitle = "$L^2$ Cluster " + num2str(currentcluster);
        hold off
        title(plottitle,'Interpreter','latex');
        saveas(gcf,l2savefolder+"/cluster_" + num2str(currentcluster),"jpeg");
    end

    % plot the clusters and centers
    clusterstoplot = 1:numclusters;
    h1savefolder = "PD Figures/H1 " + num2str(numclusters) + " clusters";
    status = mkdir(h1savefolder);
    mycolormap = @(x) [0, x, 1-x/2 x/2]; % R G B Transparency all in [0,1]

    for currentcluster = clusterstoplot
        figure;
        hold on;
        pltsplines = splines(C_h1 == currentcluster);
        plt_p = p_h1(C_h1 == currentcluster,currentcluster);
        for i = 1:sum(C_h1 == currentcluster)
            points = fnplt(pltsplines(i));
            %adjusts transparancy based on probability in cluster
            plot(points(1,:), points(2,:), 'Color', mycolormap(plt_p(i))); 
        end
        fnplt(center_h1(currentcluster));
        plottitle = "$H^1$ Cluster " + num2str(currentcluster);
        hold off
        title(plottitle,'Interpreter','latex');
        saveas(gcf,h1savefolder+"/cluster_" + num2str(currentcluster),"jpeg");
    end
end

% save the cluster information to file

game_ids = readtable("gamenames.csv");
game_ids.Properties.VariableNames = ["Year", "Game Number", "Home Team", "Away Team"];

% add the cluster info
game_ids.("L_2 Cluster") = C_l2;
game_ids.("L_2 Cluster Probability") = p_l2;
game_ids.("H_1 Cluster") = C_h1;
game_ids.("H_1 Cluster Probability") = p_h1;


clusterfolder = "PD Cluster Info/";
status = mkdir(clusterfolder);

writetable(game_ids,clusterfolder + "ClusterInfo" + num2str(numclusters) + ".csv");

% Save centers
save(clusterfolder+"ClusterCenters_"+ num2str(numclusters) +".mat","center_l2","center_h1")

% also store things in the Greg format
if save_in_long_format
    if ~ isfile("SplinePointEval.csv")
        savespline_points;
    end
    
    spline_data = readtable("SplinePointEval.csv", "Delimiter",",");
    spline_data.GameID = categorical(spline_data.GameID);
    games = categories(spline_data.GameID);

    % preallocate entries

    spline_data.("L_2 Cluster") = NaN(height(spline_data),1);
    spline_data.("L_2 Cluster Probability") = NaN(height(spline_data),numclusters);
    spline_data.("H_1 Cluster") = NaN(height(spline_data),1);
    spline_data.("H_1 Cluster Probability") = NaN(height(spline_data),numclusters);

    % add duplicated cluster info to file

    for i = 1:length(games)
        indices = find(spline_data.GameID == games(i));
        spline_data{indices(1):indices(end), "L_2 Cluster"} = C_l2(i);
        spline_data{indices(1):indices(end), "L_2 Cluster Probability"} = repmat(p_l2(i,:),length(indices),1);
        spline_data{indices(1):indices(end), "H_1 Cluster"} = C_h1(i);
        spline_data{indices(1):indices(end), "H_1 Cluster Probability"} = repmat(p_h1(i,:),length(indices),1);
    end
    writetable(spline_data,clusterfolder + "GregFormatClusters" + num2str(numclusters) + ".csv");
end


