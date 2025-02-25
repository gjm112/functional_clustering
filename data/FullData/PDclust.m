 function [l,c,p,JDF,iter]=PDclust(data,k)
% Cluster the data whit pd-clustering Algoritmh
%
%
%%%%%%%INPUT%%%%%%%%%
%data=input data
%k=number of cluster
%
%
%%%%%%%OUTPUT%%%%%%%%
%cnew=cluster's center  
%l=class label
%p=nxk matrix
%probability to belong to each class 
%JDF  join distance function
%cont=number of iterations until convergence


%center intialization
cnew(1,:)=min(data);
cnew(2,:)=max(data);
for i=3:k
cnew(i,:)=rand(1,size(data,2));
end
n=size(data,1);
ver=100;
cont=0;


while(ver>0.001 && cont<1000)%( ver>eps )nobb<=obb
    cont=cont+1;
    c=cnew;
    %STEP 1
    %computation of distance matrix
    dis=zeros(n,k);
    for i=1:n
        for j=1:k
           dis(i,j)=norm(data(i,:)-c(j,:));
        end
    end
    %STEP 2
    %computation of centers and probabilities

    p=zeros(n,k);
    for i=1:k
        t2=repmat(dis(:,i),1,k);
        t=t2./dis;
        p(:,i)=sum(t,2);
    end
    p=1./p;
    u=p.^2./dis;
    m=u./repmat(sum(u,1),n,1);
    cnew=m'*data;
    
   
    %check if centers move
    for j=1:k
        ver1(j)=norm(cnew(j,:)-c(j,:)); %#ok<AGROW>
    end
    ver=sum(ver1);
    
end
if cont==1000
h = warndlg({'Convergence not reached'}); %#ok<NASGU>
end
%memebership definition according to the maximum probability
[~,l]=max(p,[],2);
% computation of JDF
JDF=sum(mean(dis.*p));
c=cnew;
iter=cont;
end
