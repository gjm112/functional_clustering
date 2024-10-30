function [center] = UniformBSplineCenter(Splines)
% Computes the center of a set of BSplines assuming they all belong
% to the same spline space (same knots)

% Compute the orthogonality matrix for the B Slines
%\int_D B_i B_j dx. Naively done

numsplines = length(Splines);
order = Splines(1).order; %assumed the same for all splines


coef = zeros(1,length(Splines(1).coefs));
knots = Splines(1).knots; % Assumed same for all splines
% B = zeros(length(coef),length(coef));
% 
% for i = 1:length(coef)
%     coef(:) = 0;
%     coef(i) = 1;
%     Bi = spmak(knots,coef);
%     %only nonzero on the interval t_i to t_{i+order}
% 
%     minindex = max(1,i-order-1);
%     maxindex = min(length(coef),i+order-1);
%     for j = minindex:maxindex
%         % slow way to compute this, but good enough for now
%         coef(:) = 0;
%         coef(j) = 1;
%         Bj = spmak(knots,coef);
%         Bij = fncmb(Bi,'*',Bj);
%         B(i,j)= diff(fnval(fnint(Bij),[knots(i),knots(i+order)]));
%     end
% end
% 
% B = sparse(B); % may not be needed depends on size.

% now solve the system numsplines*Bc = \sum_i^{numsplines} a_i
a = zeros(1,length(Splines(1).coefs));
for i = 1:numsplines
    a = a + Splines(i).coefs;
end
a = a/numsplines;

c_coef = a;

center = spmak(knots,c_coef);
end