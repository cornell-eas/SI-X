clear
close all

load ../data/Schwartz-Caprio-withSI.mat lilac 
lilac.metadata.lat(lilac.metadata.lat>90)=nan;
Nstns=length(lilac.metadata.ID);
maxdist=10;

%%
load axis_settings
figure(1)
clf

axw=0.7;
ax(1)=axes('pos',[0.1300    0.5838    axw  0.3412]);
    hold on
    set(gca,axset{:},'box','on')
    cmap=[summer(Nstns); spring(Nstns)];
    colormap(cmap);
    [v,kq]=sort(lilac.metadata.lat(1:Nstns));
    
    for k =1:Nstns;
        if lilac.metadata.distance_to_stn(k)<maxdist
            plot(lilac.leaf.data(kq(k),:)',lilac.leaf_index.data(kq(k),:)','o','markerfacecolor',cmap(k,:),'color','k','markersize',4)
            lcorr(k)=nancorr(lilac.leaf.data(kq(k),:)',lilac.leaf_index.data(kq(k),:)');
        end
    end
    caxis(minmax(lilac.metadata.lat(kq)') + [0 nanmax(lilac.metadata.lat(kq)')-nanmin(lilac.metadata.lat(kq)')])
    c=colorbar;
    ylabel(c,'latitude');
    set(c,'ylim',minmax(lilac.metadata.lat(kq)'))
    cticks=get(c,'ytick');
    ctickls=get(c,'ytickl');
    ylabel(c,'Latitude');
    ylabel 'DOY (Index)'
    xlabel 'DOY (Observations)'
    set(gca,'ytick',30:30:120)
    axis([0 200 15 145])
    title('a) Leaf Dates','position',[-30 146],ttlset{:})

ax(2)=axes('pos',[0.1300    0.1100    axw    0.3412]);
    hold
    set(gca,axset{:},'box','on')
    for k =1:Nstns;
        if lilac.metadata.distance_to_stn(k)<maxdist
        plot(lilac.bloom.data(kq(k),:)',lilac.bloom_index.data(kq(k),:)','o','markerfacecolor',cmap(k+Nstns-1,:),'color','k','markersize',4)
        lcorr(k)=nancorr(lilac.bloom.data(kq(k),:)',lilac.bloom_index.data(kq(k),:)');
        end
    end
    cdiff=max(lilac.metadata.lat(kq)')-min(lilac.metadata.lat(kq)');
    caxis(minmax(lilac.metadata.lat(kq)') + [0 cdiff])
    c2=colorbar;
    ylabel(c2,'Latitude');
    set(c2,'ylim',(cdiff+minmax(lilac.metadata.lat(kq)')),'ytick',cticks+cdiff,'ytickl',ctickls)
    ylabel 'DOY (Index)'
    xlabel 'DOY (Observations)'
    set(gca,'ytick',30:30:180)
    axis([0 200 15 185])
    title('b) Bloom Dates','position',[-30 187],ttlset{:})
    
    
%% Output figure settings:
h=6; w=4; res=300; filename='../figs/data_vs_index_usa-npn';printertype='-painters';
set(gcf,'paperposition',[1 1 w h])
PrevFig(1)
print('-depsc',['-r' num2str(res)],'-cmyk','-loose',[filename '.eps'],printertype)
saveas(gcf,[filename '.fig'],'fig');

