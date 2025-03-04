load("UniformSplines.mat");

%get max length of data to plot
    maxlength = 0; 
    for i = 1:length(splines)
        points = fnplt(splines(i));
        maxlength = max(length(points),maxlength);
    end

    % get NaN padded arrays for x and y data
    spline_x = NaN(length(splines),maxlength);
    spline_y = NaN(length(splines),maxlength);

    for i = 1:length(splines)
        points = fnplt(splines(i));
        spline_x(i,1:length(points)) = points(1,:);
        spline_y(i,1:length(points)) = points(2,:);
    end

    writematrix(spline_x, "splinepoints_x.csv")
    writematrix(spline_y, "splinepoints_y.csv")
