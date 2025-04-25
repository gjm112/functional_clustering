clc
clear

numclusters = 1;
make_figures = true;
save_in_long_format = false; %save thing's in Greg's format as well.

cor_l2 = readmatrix("correlation_L2.csv");
cor_h1 = readmatrix("correlation_H1.csv");
load("UniformSplines.mat");
game_ids = readtable("gamenames.csv");

[c_l2,p_l2,c_h1,p_h1] = PDCluster_and_save(cor_l2, cor_h1, numclusters, ...
                                            splines, game_ids, "PD Cluster Info");

if make_figures
    cluster_figures(c_l2,p_l2,c_h1,p_h1,numclusters,splines,"PD Figures")
end

% also store things in the Greg format
if save_in_long_format
    save_gregformat(c_l2,p_l2,c_h1,p_h1,numclusters,"PD Cluster Info");
end