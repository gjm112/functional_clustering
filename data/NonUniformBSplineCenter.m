function [center] = NonUniformBSplineCenter(Splines)
% Computes the approximate center of a set of BSplines

numsplines = length(Splines);
order = Splines(1).order; %assumed the same for all splines


% spline space to place all splines on
knots = linspace(0,3600,200);
augknots = augknt(knots,order);
values = chbpnt(augknots,order);

%start up
tempspline = spapi(augknots,values,fnval(Splines(1),values));
a = tempspline.coefs;
for i = 2:numsplines
    tempspline = spapi(augknots,values,fnval(Splines(i),values));
    a = a + tempspline.coefs;
end
a = a/numsplines;

c_coef = a;

center = spmak(augknots,c_coef);
end