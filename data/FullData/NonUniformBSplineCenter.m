function [center] = NonUniformBSplineCenter(Splines, w)
% w  - optional weights for computing the center

arguments
    Splines
    w (:,1) double = ones(length(Splines),1);
end


% Computes the approximate center of a set of BSplines

numsplines = length(Splines);
order = Splines(1).order; %assumed the same for all splines


% spline space to place all splines on
knots = linspace(0,3600,200);
augknots = augknt(knots,order);
values = chbpnt(augknots,order);

%start up
tempspline = spapi(augknots,values,fnval(Splines(1),values));
a = w(1)*tempspline.coefs;
for i = 2:numsplines
    tempspline = spapi(augknots,values,fnval(Splines(i),values));
    a = a + w(i)*tempspline.coefs;
end
a = a/sum(w);

c_coef = a;

center = spmak(augknots,c_coef);
end