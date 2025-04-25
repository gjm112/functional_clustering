function[]=Silh(p)
%%%%Silhouette for probabilistic clustering methods
%%%%%INPUT
%p probability matrix
%%%%%OUTPUT
% Silhouettes
[n,nc]=size(p);
[~,la]=max(p,[],2);
ds=disS(p)';
m=[la,ds];
m=sortrows(sortrows(m,2),1);
ss=m(:,2);
ll=(sum(dis(la)));
pl=cumsum(ll);
pl=[0,pl(1:nc-1)];
ll=(round(ll/2));
tcks=ll+pl;
barsh=barh(ss,1.0);
 axesh = get(barsh(1), 'Parent');
    set(axesh, 'Xlim',[0 1.1], 'Ylim',[1 (n-1)],'YTick',tcks,  'YTickLabel',1:nc);%
    if n > 50
        shading flat
    end
    xline(mean(ds),'k--','Linewidth',2);
    xlabel('Silhouette Value');
    ylabel('Cluster');
