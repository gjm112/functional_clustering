function cluster_figures(cluster_L2, p_l2, cluster_H1, p_h1, numclusters, splines, save_directory)

% create spline centers for plotting 
for i = 1:numclusters
    center_l2(i) = NonUniformBSplineCenter(splines(cluster_L2 == i), p_l2(cluster_L2 == i,i));
end

for i = 1:numclusters
    center_h1(i) = NonUniformBSplineCenter(splines(cluster_H1 == i), p_h1(cluster_H1 == i,i));
end


    %based on winter colormap
    mycolormap = @(x) [0, x, 1-x/2 x/2]; % R G B Transparency all in [0,1]

    % plot the clusters and centers
    l2savefolder = save_directory + "/L2 " + num2str(numclusters) + " clusters";
    status = mkdir(l2savefolder);

    for currentcluster = 1:numclusters
        figure;
        hold on;
        pltsplines = splines(cluster_L2 == currentcluster);
        plt_p = p_l2(cluster_L2 == currentcluster, currentcluster);
        for i = 1:sum(cluster_L2 == currentcluster)
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
    h1savefolder = save_directory + "/H1 " + num2str(numclusters) + " clusters";
    status = mkdir(h1savefolder);
    mycolormap = @(x) [0, x, 1-x/2 x/2]; % R G B Transparency all in [0,1]

    for currentcluster = 1:numclusters
        figure;
        hold on;
        pltsplines = splines(cluster_H1 == currentcluster);
        plt_p = p_h1(cluster_H1 == currentcluster,currentcluster);
        for i = 1:sum(cluster_H1 == currentcluster)
            points = fnplt(pltsplines(i));
            %adjusts transparancy based on probability in cluster
            plot(points(1,:), points(2,:), 'Color', mycolormap(plt_p(i))); 
        end
        fnplt(center_h1(currentcluster),'k');
        plottitle = "$H^1$ Cluster " + num2str(currentcluster);
        hold off
        title(plottitle,'Interpreter','latex');
        saveas(gcf,h1savefolder+"/cluster_" + num2str(currentcluster),"jpeg");
    end
end