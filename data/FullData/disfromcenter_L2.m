function [dis] = disfromcenter_L2(numclusters,filedirectory,splines)
clusterfilename = filedirectory + "/ClusterInfo" +num2str(numclusters) + ".csv";
centerfilename  = filedirectory + "/ClusterCenters_" +num2str(numclusters) + ".mat";

if ~ isfile(clusterfilename)
    error("Need to compute cluster information ahead of time")
end

load(centerfilename,"center_l2");
[c_l2,~,~,~] = PDClusterDataFromSave(numclusters,filedirectory);

dis = zeros(1,numclusters);

for cluster = 1:numclusters
    clustersplines = splines(c_l2 == cluster);
    for i = 1:length(clustersplines)
        fun = @(x) (fnval(clustersplines(i),x) - fnval(center_l2(cluster),x)).^2;
        dis(cluster) = dis(cluster) + sqrt(integral(fun,0,3600));
    end
end

end