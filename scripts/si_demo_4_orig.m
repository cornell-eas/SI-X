%% Clear workspace
clear
close all
%%

plotonly=0;

outfilename='../data/GHCND-SI.mat';
load ../data/Schwartz-Caprio-withSI.mat

%Set up list of station IDs to loop through.
stationID_list=lilac.metadata.nearest_stns;%(could be any other list)
stationID_list(cellfun('isempty',stationID_list))=[];%removes empties
stationID_list_descr={'List of nearest stations to lilac observations with';'sufficient temporal overlap (as determined by si_demo_3.m).'};

% Define common time domain:
tdomain=(1950:2005)';

%%
load si_paths
ghcnd_metadatafile=[ghcnd_metadata_dir ghcnd_metadata_filename];



nstns=length(stationID_list);
nyrs=length(tdomain);

if ~plotonly
    
    % Initialize structure
    sindices.metadata.source=stationID_list_descr;
    sindices.metadata.creation_date=date; 
    sindices.metadata.creation_script=mfilename('fullpath');  
    sindices.metadata.created_by=getenv('USER');     
    
    sindices.metadata.ID=stationID_list;
    sindices.metadata.station_name=cellstr(repmat('',nstns,1));
    sindices.metadata.state=cellstr(repmat('',nstns,1));
    
    sindices.metadata.lat=nan(nstns,1);
    sindices.metadata.lon=nan(nstns,1);
    sindices.metadata.elev=nan(nstns,1);
    
    sindices.leaf_index.rows='stations';
    sindices.leaf_index.columns='years';
    sindices.leaf_index.data=nan(nstns,nyrs);
    sindices.leaf_index.long_name={{'Leaf index calculated as average of 3 plant models:'};...
        {'(1) Common lilac (Syringa chinensis); ' ...
        '(2) Arnold Red (Lonicera tatarica)); ' ...
        '(3) Zabelli (Lonicera korolkowii)'}};


    sindices.bloom_index.rows='stations';
    sindices.bloom_index.columns='years';
    sindices.bloom_index.data=nan(nstns,nyrs);
    sindices.bloom_index.long_name={{'Bloom index calculated as average of 3 plant models:'};...
        {'(1) Common lilac (Syringa chinensis); ' ...
        '(2) Arnold Red (Lonicera tatarica)); ' ...
        '(3) Zabelli (Lonicera korolkowii)'}};


    for i =1:nstns
        
        path_and_file=[ghcnd_data_dir stationID_list{i} '.dly'];
        stn=read_ghcnd_dly_file(path_and_file,ghcnd_metadatafile);
        sindices.metadata.lon(i)=stn.lon;
        sindices.metadata.lat(i)=stn.lat;
        
        %%
        stn_timeq=find(sum(~isnan(stn.TMIN.data),2)>330);
        [o,aq,bq]=intersect(tdomain,stn.time(stn_timeq));
        
        tmin=convert_temp(stn.TMIN.data(stn_timeq(bq),:),'C','F');
        tmax=convert_temp(stn.TMAX.data(stn_timeq(bq),:),'C','F');
        lat=stn.lat;
        
        [LFMTX,BLMTX,LSTFRZAllSites,LFpredAllSites,BLpredAllSites]=calc_si(tmin,tmax,lat);
        
        sindices.leaf_index.data(i,aq)=LFMTX(:,1);
        sindices.bloom_index.data(i,aq)=BLMTX(:,1);
        
    end
    save(outfilename,'sindices')
else
    load(outfilename)    
end
%%

lf_means=nanmean(sindices.leaf_index.data,2);
bl_means=nanmean(sindices.leaf_index.data,2);



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
        m_plot(sindices.metadata.lon(stnq(i)),sindices.metadata.lat(stnq(i)),mark{:});

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
        m_plot(sindices.metadata.lon(stnq(i)),sindices.metadata.lat(stnq(i)),mark{:});

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
i1=(1:size(sindices.leaf_index.data,2))';
for i =1:length(stnq);
    if ~isnan(lf_means(stnq(i)));
        
        
        x1=sindices.leaf_index.data(stnq(i),:)';
        x2=sindices.bloom_index.data(stnq(i),:)';
        
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
        m_plot(sindices.metadata.lon(stnq(i)),sindices.metadata.lat(stnq(i)),mark{:});

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
        m_plot(sindices.metadata.lon(stnq(i)),sindices.metadata.lat(stnq(i)),mark{:});

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
    
