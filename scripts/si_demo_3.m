clear
close all
load si_paths
load ../data/Schwartz-Caprio.mat
load([ghcnd_metadata_dir ghcnd_metadata_filename])
addpath ../si_funcs/

%% Import 733 verification sights (high quality, HCN, no WNBAN):
% Then create structure
SI_xInFile=[mds_verification_data_dir 'SI-x_1981_2010_norms25_noWBAN.xls'];
[SI_xdata,header]=xlsread(SI_xInFile);
[stnlist,ulistq]=unique(SI_xdata(:,1)); %length here should be 733
for i=1:length(header);
    eval([header{i} '_raw=SI_xdata(:,i);'])
end

%Create ML structure
SI_xSchwartz.metadata.source_file=SI_xInFile;
SI_xSchwartz.metadata.creation_date=datestr(now);
SI_xSchwartz.metadata.creation_script=mfilename('fullpath'); 
SI_xSchwartz.metadata.created_by=getenv('USER');
SI_xSchwartz.metadata.acknowlegement='Data sent by Mark Schwartz to T. Ault (2.9.2014)';
SI_xSchwartz.metadata.history={'Ault removed the WBAN listings from the original Excel data \n in file "SI-x_1981_2010_norms25.xlsx'};
SI_xSchwartz.metadata.ID=stnlist;
SI_xSchwartz.metadata.lon=longitude_raw;
SI_xSchwartz.metadata.lat=latitude_raw;
SI_xSchwartz.metadata.elevation=elevation_raw;
%
distMtx=nan(length(lilac.metadata.ID),length(SI_xSchwartz.metadata.ID));

for i =1:length(lilac.metadata.ID)
    for j =1:length(SI_xSchwartz.metadata.ID)
        distMtx(i,j)=ll2dist([lilac.metadata.lon(i) SI_xSchwartz.metadata.lon(j)],...
            [lilac.metadata.lat(i) SI_xSchwartz.metadata.lat(j)]);
    end    
end


%% Need to add the following fields to metdata:
%  sites_with_station
%     nearest_stns
%     distance_to_stn

% And also to folowing fields:
% leaf_index
%     rows
%     columns
%     data

lilac.leaf_index=rmfield(lilac.leaf,'plant');
lilac.leaf_index.data=lilac.leaf_index.data*nan;%set values to nan
% bloom_index
%     rows
%     columns
%     data
lilac.bloom_index=rmfield(lilac.bloom,'plant');
lilac.bloom_index.data=lilac.bloom_index.data*nan;%set values to nan
%%
for i =1:length(lilac.metadata.ID);
    clear CurrentStation
    [mindist,jpos]=min(distMtx(i,:));
    stnid0=num2str(SI_xSchwartz.metadata.ID(jpos));
    if length(stnid0)==5
        stnid=['USC000' stnid0];
    elseif length(stnid0)==6
        stnid=['USC00' stnid0];
    else
        error(['station id length=' length(stnid0)])
    end
        
    % Read GHCND data
    eval(['CurrentStation=read_ghcnd_dly_file(' char(39) ghcnd_data_dir stnid '.dly'  char(39) ',[ghcnd_metadata_dir ghcnd_metadata_filename]);']);
    if all(all(isnan(CurrentStation.TMIN.data)))
        [mindists,jpostns]=find(distMtx(i,:)<100);
        k=2;
        while all(all(isnan(CurrentStation.TMIN.data)))
            jpos=jpostns(k);
            mindist=mindists(k);
            stnid0=num2str(SI_xSchwartz.metadata.ID(jpos));
            if length(stnid0)==5
                stnid=['USC000' stnid0];
            elseif length(stnid0)==6
                stnid=['USC00' stnid0];
            else
                error(['station id length=' length(stnid0)])
            end
            eval(['CurrentStation=read_ghcnd_dly_file_no_load(' char(39) ghcnd_data_dir stnid '.dly'  char(39) ',ghcnd_metadata);']);
            k=k+1;
        end
    end
        
    %Creat Tmin/Tmax arrays:
    tmin=convert_temp(CurrentStation.TMIN.data,'C','F');
    tmax=convert_temp(CurrentStation.TMAX.data,'C','F');

    
    %Get latitude & time (for later)
    templat=SI_xSchwartz.metadata.ID(jpos);
    stn_time=CurrentStation.time;
    
    %Trim out years not needed for comparison to lilac obs:
    [o,ai,bi]=intersect(stn_time,lilac.metadata.time);
    tmin=tmin(ai,:);
    tmax=tmax(ai,:);
    % Calculate SI
    [LFMTX,BLMTX,LSTFRZAllSites,LFpredAllSites,BLpredAllSites]=calc_si(tmin,tmax,templat);    
    
    %Add results to lilac.leaf_index and lilac.bloom_index
    lilac.leaf_index.data(i,:)=LFMTX(:,1);
    lilac.bloom_index.data(i,:)=BLMTX(:,1);
    
    % Need to add the following fields to metdata:
    %  sites_with_station
    %     nearest_stns
    %     distance_to_stn
    lilac.metadata.nearest_stns(i,1)=SI_xSchwartz.metadata.ID(jpos);
    lilac.metadata.distance_to_stn(i,1)=mindist;
    
end

save ../data/Schwartz-Caprio-withSI.mat lilac