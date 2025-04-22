function[disjN]=dis(N)
%disjunctive coding of a matrix
%%%%%%%%%INPUT
%N matrix                  
%%%%%%%%%OUTPUT
%disjN disjunctive coded of a matrix
% N=[1,3,2 ;2,1,1;1,2,2;....]
%disjN=[1,0,0,0,0,1,0,1;0,1,1,0,0,1,0;1,0,0,1,0,0,1;....]
%trasform 0 1 type coding in 1 2
 [nrig,ncol]=size(N);
%p=size(N,2);
for i =1:nrig
    for j=1:ncol
        if N(i,j)==0
            N(i,j)=2;
        end
    end
end
m=max(N);
disjN=zeros(nrig,sum(m));
for j=1:ncol
   disj=zeros(nrig,m(j));
    for i=1:nrig
     disj(i,N(i,j))=1;
    end
    disjN=[disjN,disj];
end
cont=0;
j=1;
nn=size(disjN,2);
while( j<(nn+1))
    if isin(1,disjN(:,j))==0
        disjN(:,j)=[];
        nn=nn-1;
        cont=cont+1;
    else j=j+1;
    end
end
   
%disjN=disjN(:,(2:s));