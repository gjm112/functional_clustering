function [c_l2,p_l2,c_h1,p_h1] = PDClusterDataFromSave(numclusters,savedirectory)

filename = savedirectory + "/ClusterInfo" +num2str(numclusters) + ".csv";
if ~ isfile(filename)
    error("Need to compute cluster information ahead of time")
end

T = readtable(filename,"VariableNamingRule","preserve");

c_l2 = T.("L_2 Cluster");
p_l2 = T{:,6:6+numclusters-1};
c_h1 = T.("H_1 Cluster");
p_h1 = T{:,7+numclusters:7+2*numclusters-1};
end