function[ds]=disS(p)
%%%Compute density based Silhouette information (DBS)
%%%%%%INPUT
%p probability matrix
%%%%%%OUTPUT
%ds distances for silhouette
[n,nc]=size(p);
[m,pm]=max(p,[],2);
pt=zeros(n,(nc-1));
for i=1:n
    c=0;
    for j=1:nc
        if j~=pm(i)
            c=c+1;
            pt(i,c)=p(i,j);
        end
    end
end
de=max(pt,[],2);
for i=1:n
    nu(i)=log(m(i)/de(i));
end
de2=max(nu);
ds=nu/de2;
