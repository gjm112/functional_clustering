load("UniformSplines.mat");

xpoints = linspace(0,3600,150);

%save thing's in Greg Format ...
gamenames = readcell("gamenames.csv","Delimiter",",");
%in this format in case I change back to fnplt to get points,
%in which case length(points) is unknown apriori

%get total length of data to plot
totallength = 0;
for i = 1:length(splines)
    points = fnval(splines(i),xpoints); %note that fnplt yields duplicate values
    totallength = length(points) + totallength;
end

% preallocate storage for Greg format

splinepoints = zeros(totallength, 2);
gamenames_duplicated = cell(totallength,1);
index = 1;
for i = 1:length(splines)
    ypoints = fnval(splines(i),xpoints);
    points = [xpoints; ypoints];
    splinepoints(index: index + length(points)-1,:) = points';
    gamenames_duplicated(index: index+length(points)-1) = gamenames(i);
    index = index + length(points);
end

spline_data = cell2table(gamenames_duplicated);
spline_data.Properties.VariableNames = "Game ID";
spline_data.("Time") = splinepoints(:,1); 
spline_data.("Spline Win Percent") = splinepoints(:,2);

writetable(spline_data,"SplinePointEval.csv");
