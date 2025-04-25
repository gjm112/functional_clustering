function save_gregformat(c_l2,p_l2,c_h1,p_h1,numclusters,savedirectory)

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
    spline_data{indices(1):indices(end), "L_2 Cluster"} = c_l2(i);
    spline_data{indices(1):indices(end), "L_2 Cluster Probability"} = repmat(p_l2(i,:),length(indices),1);
    spline_data{indices(1):indices(end), "H_1 Cluster"} = c_h1(i);
    spline_data{indices(1):indices(end), "H_1 Cluster Probability"} = repmat(p_h1(i,:),length(indices),1);
end
writetable(spline_data,savedirectory + "/GregFormatClusters" + num2str(numclusters) + ".csv");
end