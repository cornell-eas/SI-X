% Example illustrating how ML_SI can be used to relate station-based values
% of the Leaf and Bloom indices to observational phenology. In this case,
% the phenology dataset overlaps with the data used to develop the model,
% so this the good correlation shown in the main figure is in some sense
% built in. The motivation for providing this example, however, is to
% illustrate three things:
% (1) How to query the GHCND metadata to find meteorological stations that
%     are in close physical proximity to the observational data;
%
% (2) How to import a large number of GHCN station data and check their
%     temporal overlap with the phenological observations;
% 
% (3) How to attach a list of station ids to the lilac dataset for later
%     use (see si_demo_4).
clear
close all

%% Settings:
plotonly=false; % Skips calculation of SI, looks for existing data
checklocation=false; % Makes a map to show search results (nearest stations)
istart=1234; % iteration on which to start loop

%% Searh parameters:
lon_thresh=1; %maximum allowable distance in longitude
lat_thresh=1; %maximum allowable distance in latitude
elev_thresh=100; %maximum allowble difference in elevation

%% Default spatial domain is North America (for checklocation):
addpath ~/Matlab/m_map/m-map/
if checklocation
    m_proj('mercator','longitudes',[-125 -55],'latitudes',[25 55])
end

%%

if ~plotonly
    load si_paths
    addpath ../si_funcs/
    addpath ~/Matlab/ClimX/
    
    load ../data/Schwartz-Caprio.mat

    % load metadata
    ghcnd_metadatafile=[ghcnd_metadata_dir ghcnd_metadata_filename];
    load(ghcnd_metadatafile)

    %
    lat_lilac=lilac.metadata.lat;
    lon_lilac=lilac.metadata.lon;
    elev_lilac=lilac.metadata.elev;

    lat_stns=ghcnd_metadata.lat;
    lon_stns=ghcnd_metadata.lon;
    elev_stns=ghcnd_metadata.elevation;
    allq=(1:length(lon_stns));
    stnq=[];
    
    k=1;
    lilac.metadata.sites_with_station=false(length(lon_lilac),1);
    lilac.metadata.nearest_stns=cell(length(lon_lilac),1);
    lilac.metadata.distance_to_stn=nan(length(lon_lilac),1);

    lilac.leaf_index=lilac.leaf;
    lilac.leaf_index.data=nan*lilac.leaf_index.data;

    lilac.bloom_index=lilac.bloom;
    lilac.bloom_index.data=nan*lilac.bloom_index.data;

    %%
    nlilac=length(elev_lilac);
    if istart>1
        warning('Starting loop with i>1. Some sites will be omitted.');
        pause(4)
    end
    for i =istart:nlilac
       lon_dist=abs(lon_stns-lon_lilac(i) );  
       qelev=[];
       qlon=[];
       qlat=[];
       stn_found=false;
       lilacq=find(~isnan(lilac.leaf.data(i,:)));
       all_lilac_yrs=lilac.metadata.time(lilacq);
       if(~isempty(all_lilac_yrs))
           if any(lon_dist<lon_thresh);
               qlon=find(lon_dist<lon_thresh);
               for ii=1:length(qlon);
                   lat_dist=abs(lat_stns(qlon)-lat_lilac(i));
                   if any(lat_dist<lat_thresh);
                       qlat=find(lat_dist<lat_thresh);
                       for jj=1:length(qlat)
                           elev_diff=abs(elev_stns(qlon(qlat))-elev_lilac(i));
                           if any(elev_diff<elev_thresh)
                               qelev=find(elev_diff<elev_thresh);
                           end
                       end
                   end
               end
           end   
           if ~isempty(qelev)
               if checklocation %make sure sites
                   figure(1)
                   clf
                   hold on
                   m_plot(lilac.metadata.lon(i),lilac.metadata.lat(i),'ro','markersize',10);
                   m_plot(ghcnd_metadata.lon(qlon(qlat(qelev))),ghcnd_metadata.lat(qlon(qlat(qelev))),'ko')
                   m_coast('color','k')
                   m_grid('xtick',[],'ytick',[],'linestyle','none')
                   pause(.1)

               end       
               %%                     
               qstnsubset=allq(qlon(qlat(qelev)));      
               nstns=length(qstnsubset);
               stn_dists=nan(nstns,1);
               for ii=1:nstns;
                   lonpair=[lon_lilac(i) lon_stns(qstnsubset(ii))];
                   latpair=[lat_lilac(i) lat_stns(qstnsubset(ii))];
                   stn_dists(ii)=m_lldist(lonpair,latpair);
               end
               [stn_dists,sortdistq]=sort(stn_dists);
               qstnsubset=qstnsubset(sortdistq);

               stnids=ghcnd_metadata.ID(qstnsubset,:);
               nvrlp=zeros(nstns,1);
               stnall=cell(0);
               for ii=1:nstns;
                   try 
                       stnall{ii}=read_ghcnd_dly_file_no_load([ghcnd_data_dir stnids(ii,:) '.dly'],ghcnd_metadatafile);
                       stnq=find(sum(~isnan(stnall{ii}.TMIN.data),2)>350);
                       goodyrs=stnall{ii}.time(stnq);
                       [o,aq,bq]=intersect(all_lilac_yrs,goodyrs);
                       nvrlp(ii)=length(aq);
                   catch
                       disp(['error in import of  ' [ghcnd_data_dir stnids(ii,:) '.dly']])
                   end
               end
               if ~all(nvrlp==0)
                   [val,pos]=max(nvrlp);
                   if val>3
                       try
                           stndata=stnall{pos};
                           clear stnall

                           stnq=find(sum(~isnan(stndata.TMIN.data),2)>350);
                           goodyrs=stndata.time(stnq);
                           [o,aq,bq]=intersect(all_lilac_yrs,goodyrs);

                           tmin=convert_temp(stndata.TMIN.data(stnq(bq),:),'C','F');
                           tmax=convert_temp(stndata.TMAX.data(stnq(bq),:),'C','F');

                           [LFMTX,BLMTX,LSTFRZAllSites,LFpredAllSites,BLpredAllSites]=calc_si(tmin,tmax,stndata.lat);

                           lilac.metadata.sites_with_station(i)=true;
                           lilac.metadata.nearest_stns{i}=stnids(pos,:);%CHECK: for some reason, this appears to occasionally produce 2 values...
                           if length(lilac.metadata.nearest_stns(i))>1
                               error('length(lilac.metadata.nearest_stns(i))>1')
                           end
                           lilac.metadata.distance_to_stn(i)=stn_dists(pos);
                           lilac.leaf_index.data(i,lilacq(aq))=LFMTX(:,1);
                           lilac.bloom_index.data(i,lilacq(aq))=BLMTX(:,1);

                           save ../data/Schwartz-Caprio-withSI.mat lilac i
                       catch 
                           disp('error in SI calculation')
                       end
                   else
                       disp('Insuficient data!!!') 
                   end
               else
                   disp('NO OVERLAP!!!')
               end
           end
           clear *_diff 
       end
    end
    save ../data/Schwartz-Caprio-withSI.mat lilac i 
end

mk_data_vs_index_fig

