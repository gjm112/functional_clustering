clc
clear

filedirectory = "PD Cluster Info";
clusterstotest = 2:10;

cor_l2 = readmatrix("correlation_L2.csv");
%cor_h1 = readmatrix("correlation_H1.csv");


myfun =  @(X,k) evalfun_l2(X,k,filedirectory);

evaluation = evalclusters(cor_l2,myfun,'CalinskiHarabasz','klist',clusterstotest);
plot(evaluation);

function c_l2 = evalfun_l2(X,numclusters,filedirectory)

    filename = filedirectory + "/ClusterInfo" +num2str(numclusters) + ".csv";

    if ~ isfile(filename)
        c_l2 = PDclust(X,numclusters);
    else
        [c_l2,~,~,~] = PDClusterDataFromSave(numclusters, filedirectory);
    end
end

function c_h1 = evalfun_h1(X,numclusters,filedirectory)

    filename = filedirectory + "/ClusterInfo" +num2str(numclusters) + ".csv";

    if ~ isfile(filename)
        c_h1 = PDclust(X,numclusters);
    else
        [~,~,c_h1,~] = PDClusterDataFromSave(numclusters, filedirectory);
    end
end