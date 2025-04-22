function [c_l2,p_l2,c_h1,p_h1] = PDCluster_and_save(cor_l2,cor_h1,numclusters, splines, game_ids,savedirectory)

% generate the actual clusters here 
[c_l2,~,p_l2] =  PDclust(cor_l2, numclusters);

[c_h1,~,p_h1] =  PDclust(cor_h1, numclusters);

% modify game_id names here 
game_ids.Properties.VariableNames = ["Year", "Game Number", "Home Team", "Away Team"];

% add the cluster info
game_ids.("L_2 Cluster") = c_l2;
game_ids.("L_2 Cluster Probability") = p_l2;
game_ids.("H_1 Cluster") = c_h1;
game_ids.("H_1 Cluster Probability") = p_h1;

status = mkdir(savedirectory);

writetable(game_ids, savedirectory + "/ClusterInfo" + num2str(numclusters) + ".csv");

% create centers 
for i = 1:numclusters
    center_l2(i) = NonUniformBSplineCenter(splines(c_l2 == i), p_l2(c_l2 == i,i));
end

for i = 1:numclusters
    center_h1(i) = NonUniformBSplineCenter(splines(c_h1 == i), p_h1(c_h1 == i,i));
end

% Save centers
save(savedirectory+"/ClusterCenters_"+ num2str(numclusters) +".mat","center_l2","center_h1")
end