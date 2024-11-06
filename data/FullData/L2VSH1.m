clear 
clc
 % note that the H1 seminorm is weighted much less than the L2 part, 
 % so a relative difference of 1/3.6 means they are about equal in weight. 

savefigures = true;
relative_difference_to_plot = 2/5;

cor_l2 = readmatrix("correlation_L2.csv");
cor_h1 = readmatrix("correlation_H1.csv");
load("UniformSplines.mat");

tri_l2 = triu(cor_l2);
tri_h1 = triu(cor_h1);

rel_diff = (tri_h1-tri_l2)./tri_l2;

[row,col] = find(rel_diff >= relative_difference_to_plot);

status = mkdir("Figures/Temp")

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
    if savefigures
       saveas(gcf,"Figures/Temp/" + ...
           "H1vsL2_" + num2str(i),"jpeg");
    end
end