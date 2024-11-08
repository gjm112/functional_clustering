clear 
clc
 % note that the H1 seminorm is weighted much less than the L2 part, 
 % so a relative difference of 1/3.6 means they are about equal in weight. 

savefigures = true;
relative_difference_to_plot = 1/2;

cor_l2 = readmatrix("cor_L2_no_overtime.csv");
cor_h1 = readmatrix("cor_H1_no_overtime.csv");
load("Splines_no_overtime.mat");
games = readcell("gamenames_no_overtime.csv",'Delimiter',',');

tri_l2 = triu(cor_l2);
tri_h1 = triu(cor_h1);

rel_diff = (tri_h1-tri_l2)./tri_l2;

[row,col] = find(rel_diff >= relative_difference_to_plot);

status = mkdir("Figures/Temp");

% plot splines that have h1 norm relatively larger than l2
for i = 1:length(row)
    figure; 

    hold on
    fnplt(splines(row(i)));
    fnplt(splines(col(i)));
    hold off

    title([ games(row(i)) + " and " + games(col(i)), "have" + ...
        " L2 " + num2str(cor_l2(row(i),col(i))) + " and H1 " + num2str(cor_h1(row(i),col(i)))],'Interpreter','none');
    legend(["Spline " + num2str(row(i)),"Spline " + num2str(col(i))],'Interpreter','none');
    if savefigures
       saveas(gcf,"Figures/Temp/" + ...
           "H1vsL2_" + num2str(i),"jpeg");
    end
end