clear 
clc

relative_difference_to_plot = 1/(3.6); 

cor_l2 = readmatrix("correlation_L2.csv");
cor_h1 = readmatrix("correlation_H1.csv");
load("UniformSplines.mat");

tri_l2 = triu(cor_l2);
tri_h1 = triu(cor_h1);

rel_diff = (tri_h1-tri_l2)./tri_l2;

[row,col] = find(rel_diff >= relative_difference_to_plot);

% plot splines that have h1 norm relatively larger than l2
for i = 1:length(row)
    figure; 

    hold on
    fnplt(splines(row(i)));
    fnplt(splines(col(i)));
    hold off

    title(["Spline " + num2str(row(i)) + " and Spline " + num2str(col(i)), "have" + ...
        " L2 " + num2str(cor_l2(row(i),col(i))) + " and H1 " + num2str(cor_h1(row(i),col(i)))]);
    legend(["Spline " + num2str(row(i)),"Spline " + num2str(col(i))]);
end