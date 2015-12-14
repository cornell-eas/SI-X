%% Clear workspace
clear
close all
%%
load ../data/Schwartz-Caprio-withSI.mat
lf_means=nanmean(lilac.leaf_index.data,2);
bl_means=nanmean(lilac.leaf_index.data,2);

%%
figure(1)
clf
m_proj('mercator','longitudes',[-128 -55],'latitudes',[29 50])
stnq=find(~isnan(lf_means));

lf_maxsize=15;
lf_minsize=5;
lf_maxdate=130;
lf_mindate=15;

lf_ndates=lf_maxdate-lf_mindate;
lf_colorscale=round(lf_ndates*((lf_means-lf_mindate)./(lf_maxdate-lf_mindate)));
lf_colorscale(lf_colorscale<1)=1;
lf_colorscale(lf_colorscale>lf_ndates)=lf_ndates;
cmap=flipud(jet(lf_ndates));
%
load axis_settings
ax(1)=subplot(211);
    hold on
    set(gca,axset{:})
    for i =1:length(stnq)
        mark={'color','k','marker','o','markerfacecolor',cmap(lf_colorscale(stnq(i)),:)};
        m_plot(lilac.metadata.lon(stnq(i)),lilac.metadata.lat(stnq(i)),mark{:});

    end
    m_coast('color','k','linewidth',1.5)
    m_grid('linestyle','none','xtick',[],'ytick',[])

    caxis([lf_mindate lf_maxdate])
    colormap(cmap);
    c1=colorbar;
    cticks=lf_mindate:15:lf_maxdate;
    set(c1,'ytick',cticks)
    ylabel(c1,'DOY')
    title('a) Leaf Index Means',ttlset{:},'position',[-.86 1.035])

bl_maxsize=15;
bl_minsize=5;
bl_maxdate=lf_maxdate+15;
bl_mindate=lf_mindate+15;

bl_ndates=bl_maxdate-bl_mindate;
bl_colorscale=round(bl_ndates*((bl_means-bl_mindate)./(bl_maxdate-bl_mindate)));
bl_colorscale(bl_colorscale<1)=1;
bl_colorscale(bl_colorscale>bl_ndates)=bl_ndates;
cmap=flipud(jet(bl_ndates));

ax(1)=subplot(212);
    hold on
    set(gca,axset{:})
    for i =1:length(stnq)
        mark={'color','k','marker','o','markerfacecolor',cmap(bl_colorscale(stnq(i)),:)};
        m_plot(lilac.metadata.lon(stnq(i)),lilac.metadata.lat(stnq(i)),mark{:});

    end
    m_coast('color','k','linewidth',1.5)
    m_grid('linestyle','none','xtick',[],'ytick',[])

    caxis([bl_mindate bl_maxdate])
    colormap(cmap);
    c2=colorbar;
    cticks=bl_mindate:15:bl_maxdate;
    set(c2,'ytick',cticks)   
    ylabel(c2,'DOY')
    title('b) Bloom Index Means',ttlset{:},'position',[-.86 1.035])
    
% Output figure settings:
h=4.6; w=6; res=300; filename='../figs/si_means';printertype='-painters';
set(gcf,'paperposition',[1 1 w h])
PrevFig(1)
print('-depsc2',['-r' num2str(res)],'-cmyk','-loose',[filename '.eps'],printertype)
saveas(gcf,[filename '.fig'],'fig');

%%
figure(2)
clf

lf_trends=nan(size(lf_means));
bl_trends=nan(size(bl_means));
i1=(1:size(lilac.leaf_index.data,2))';
for i =1:length(stnq);
    if ~isnan(lf_means(stnq(i)));
        
        
        x1=lilac.leaf_index.data(stnq(i),:)';
        x2=lilac.bloom_index.data(stnq(i),:)';
        
        q1=find(~isnan(x1));
        q2=find(~isnan(x2));
        
        
        b1=regress(x1(q1),[ones(size(x1(q1))) i1(q1)]);
        b2=regress(x2(q2),[ones(size(x2(q2))) i1(q2)]);
        
        lf_trends(stnq(i))=b1(2)*10;%Days per decade
        bl_trends(stnq(i))=b2(2)*10;%Days per decade
    end
end
lf_trend_maxsize=15;
lf_trend_minsize=5;
lf_trend_maxdate=4;
lf_trend_mindate=-4;

lf_trend_ndates=lf_trend_maxdate-lf_trend_mindate;
lf_trend_colorscale=round(lf_trend_ndates*((lf_trends-lf_trend_mindate)./(lf_trend_maxdate-lf_trend_mindate)));
lf_trend_colorscale(lf_trend_colorscale<1)=1;
lf_trend_colorscale(lf_trend_colorscale>lf_trend_ndates)=lf_trend_ndates;
cmap=flipud(jet(lf_trend_ndates));
%
load axis_settings
ax(1)=subplot(211);
    hold on
    set(gca,axset{:})
    for i =1:length(stnq)
        mark={'color','k','marker','o','markerfacecolor',cmap(lf_trend_colorscale(stnq(i)),:)};
        m_plot(lilac.metadata.lon(stnq(i)),lilac.metadata.lat(stnq(i)),mark{:});

    end
    m_coast('color','k','linewidth',1.5)
    m_grid('linestyle','none','xtick',[],'ytick',[])

    caxis([lf_trend_mindate lf_trend_maxdate])
    colormap(cmap);
    c21=colorbar;
    cticks=lf_trend_mindate:2:lf_trend_maxdate;
    set(c21,'ytick',cticks)
    ylabel(c21,'Days per Decade')
    title('a) Leaf Index Trends',ttlset{:},'position',[-.86 1.035])
%%
bl_trend_maxsize=15;
bl_trend_minsize=5;
bl_trend_maxdate=lf_trend_maxdate;
bl_trend_mindate=lf_trend_mindate;

bl_trend_ndates=bl_trend_maxdate-bl_trend_mindate;
bl_trend_colorscale=round(bl_trend_ndates*((bl_trends-bl_trend_mindate)./(bl_trend_maxdate-bl_trend_mindate)));
bl_trend_colorscale(bl_trend_colorscale<1)=1;
bl_trend_colorscale(bl_trend_colorscale>bl_trend_ndates)=bl_trend_ndates;
cmap=flipud(jet(bl_trend_ndates));

ax(1)=subplot(212);
    hold on
    set(gca,axset{:})
    for i =1:length(stnq)
        mark={'color','k','marker','o','markerfacecolor',cmap(bl_trend_colorscale(stnq(i)),:)};
        m_plot(lilac.metadata.lon(stnq(i)),lilac.metadata.lat(stnq(i)),mark{:});

    end
    m_coast('color','k','linewidth',1.5)
    m_grid('linestyle','none','xtick',[],'ytick',[])

    caxis([bl_trend_mindate bl_trend_maxdate])
    colormap(cmap);
    c22=colorbar;
    cticks=bl_trend_mindate:2:bl_trend_maxdate;
    set(c22,'ytick',cticks)   
    ylabel(c22,'Days per Decade')
    title('b) Bloom Index Trends',ttlset{:},'position',[-.86 1.035])
    
% Output figure settings:
h=4.6; w=6; res=300; filename='../figs/si_trends';printertype='-painters';
set(gcf,'paperposition',[1 1 w h])
PrevFig(2)
print('-depsc2',['-r' num2str(res)],'-cmyk','-loose',[filename '.eps'],printertype)
saveas(gcf,[filename '.fig'],'fig');
    
