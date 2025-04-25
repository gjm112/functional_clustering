function [table_l2,table_h1,prob_l2,prob_h1] = PDAvgandMedianSilValues(numclusters,savedirectory)
    filename = savedirectory + "/ClusterInfo" +num2str(numclusters) + ".csv";

    if ~ isfile(filename)
        error("Need to compute cluster information ahead of time")
    end

    T = readtable(filename,"VariableNamingRule","preserve");
    s_l2 = T.("L2 silhouette");
    s_h1 = T.("H1 silhouette");

   [c_l2,p_l2,c_h1,p_h1] = PDClusterDataFromSave(numclusters,savedirectory);

    sprob_l2 = disS(p_l2);
    sprob_h1 = disS(p_h1);

    table_l2 = table('Size',[numclusters,3],'VariableTypes',["double","double","double"],'VariableNames',["Cluster", "Avg Silhouette", "Median Silhouette"]);
    table_h1 = table_l2; 
    prob_l2 = table_l2;
    prob_h1 = table_l2;

    for i = 1:numclusters
        table_l2{i,:} = [i, mean(s_l2(c_l2 == i)),median(s_l2(c_l2 == i))];
        table_h1{i,:} = [i, mean(s_h1(c_h1 == i)),median(s_h1(c_h1 == i))];
        prob_h1{i,:} = [i, mean(sprob_h1(c_h1 == i)),median(sprob_h1(c_h1 == i))];
        prob_l2{i,:} = [i, mean(sprob_l2(c_l2 == i)),median(sprob_l2(c_l2 == i))];
    end
end