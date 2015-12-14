clear
close all
load ../data/mds716sites.mat
m_proj('mercator','longitudes',[-135 -55],'latitudes',[25 55])
load axis_settings
sclfac=8;
dscale=[0 2];
minsize=0;
dsize_lf=sclfac*(verification_results.lf_me-dscale(1))./dscale(2)+minsize;
dsize_bl=sclfac*(verification_results.bl_me-dscale(1))./dscale(2)+minsize;

figure(1);
clf
subplot(211);hold on
m_coast('color','k');
m_grid('linestyle','none');
title('Leaf Index',ttlset{3:end})

subplot(212);hold on
m_coast('color','k');
m_grid('linestyle','none');
title('Bloom Index',ttlset{3:end})

for i =1:length(dsize_lf)
    lati=verification_results.lat(i);
    loni=verification_results.lon(i);
    
    subplot(211)
        m_plot(loni,lati,'ko','markersize',dsize_lf(i))
    
    subplot(212)
        m_plot(loni,lati,'ko','markersize',dsize_bl(i))
end

%%
legaxpos=[0.85    0.25    0.08    0.5];
legax=axes('pos',legaxpos);
hold on
ndots=10;
legdots=dscale(2)*(1:ndots)./ndots;
dotsizes=sclfac*(legdots-dscale(1))./dscale(2)+minsize;


for i =1:ndots;
    plot(0,i,'ko','markersize',dotsizes(i));
    text(.8,i,num2str(trunc8(legdots(i),2)),ttlset{3:4})
    
end
ylabel('RMSE')
set(legax,'xlim',[-.8 2.2],'ylim',[0 ndots*1.1],'box','on','yaxisloc','right','xtick',[],'ytick',[])


% Output figure settings:
h=4.6; w=6; res=300; filename='../figs/mds_verification_716sites';printertype='-painters';
set(gcf,'paperposition',[1 1 w h])
PrevFig(1)
print('-depsc2',['-r' num2str(res)],'-cmyk','-loose',[filename '.eps'],printertype)
print('-djpeg',['-r' num2str(res)],'-cmyk','-loose',[filename '.jpg'],printertype)
saveas(gcf,[filename '.fig'],'fig');
