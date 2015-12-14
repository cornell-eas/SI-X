if ~exist('setup_mode','var')
    clear
    close all
    load si_paths
end

% Structure should have the following fields, combined for BOTH western US
% and Eastern US sites.
%lilac
% metadata
%     source_file
%     creation_date
%     creation_script
%     created_by
%     ID
%     station_name
%     state
%     lat
%     lon
%     elev
%     time
% leaf
%     rows
%     columns
%     data
%     plant
% bloom
%     rows
%     columns
%     data
%     plant

[eUS_lilac_data,eUS_header]=xlsread(easternUS_lilac_file);
[wUS_lilac_data,wUS_header]=xlsread(westernUS_lilac_file);


%% Combine IDs from E. US and W. US sites:
wUS_IDname='stationid';
wUS_IDq=find(strcmp(wUS_header,wUS_IDname));

eUS_IDname='statnum';
eUS_IDq=find(strcmp(eUS_header,eUS_IDname));
AllIDs=[wUS_lilac_data(:,wUS_IDq); eUS_lilac_data(:,eUS_IDq)];
%% Save latitude as single column vector
wUS_LatName='latitude';
wUS_Latq=find(strcmp(wUS_header,wUS_LatName));

eUS_LatName='lat';
eUS_Latq=find(strcmp(eUS_header,eUS_LatName));

AllLats=[wUS_lilac_data(:,wUS_Latq); eUS_lilac_data(:,eUS_Latq)];
%% Save longitude as single column vector
wUS_LonName='longitude';
wUS_Lonq=find(strcmp(wUS_header,wUS_LonName));

eUS_LonName='long';
eUS_Lonq=find(strcmp(eUS_header,eUS_LonName));

AllLons=[wUS_lilac_data(:,wUS_Lonq); eUS_lilac_data(:,eUS_Lonq)];
%% Save Elevation as single column vector
wUS_ElevName='elev(m)';
wUS_Elevq=find(strcmp(wUS_header,wUS_ElevName));

eUS_ElevName='long';
eUS_Elevq=find(strcmp(eUS_header,eUS_ElevName));

AllElevs=[wUS_lilac_data(:,wUS_Elevq); eUS_lilac_data(:,eUS_Elevq)];
%% Set up vector of plant types (1-Syringa Chinensis Clone; 2-Syringa Vulgaris).
% NOTE: All W-US species are S. Vulgaris, according to file name.

eUS_PlantID='plantype';
eUS_Plantq=find(strcmp(eUS_header,eUS_PlantID));

AllPlantIDs=[repmat(2,size(wUS_lilac_data,1),1); eUS_lilac_data(:,eUS_Plantq)];
%% Save All Time (years with obs) as single column vector
wUS_TimeName='year';
wUS_Timeq=find(strcmp(wUS_header,wUS_TimeName));

eUS_TimeName='year';
eUS_Timeq=find(strcmp(eUS_header,eUS_TimeName));

AllTimes=[wUS_lilac_data(:,wUS_Timeq); eUS_lilac_data(:,eUS_Timeq)];
years=(min(AllTimes):max(AllTimes));

%% First Leaf dates single column vector
wUS_LeafName='firstleaf';
wUS_Leafq=find(strcmp(wUS_header,wUS_LeafName));

eUS_LeafName='firstleaf';
eUS_Leafq=find(strcmp(eUS_header,eUS_LeafName));

AllLeafs=[wUS_lilac_data(:,wUS_Leafq); eUS_lilac_data(:,eUS_Leafq)];
%% First Bloom dates single column vector
wUS_BloomName='firstbloom';
wUS_Bloomq=find(strcmp(wUS_header,wUS_BloomName));

eUS_BloomName='firstbloom';
eUS_Bloomq=find(strcmp(eUS_header,eUS_BloomName));

AllBlooms=[wUS_lilac_data(:,wUS_Bloomq); eUS_lilac_data(:,eUS_Bloomq)];
%% Build Structure:
[UniqueIDs,idq]=unique(AllIDs);
nstns=length(UniqueIDs);
lilac.metadata.source_file={easternUS_lilac_file;westernUS_lilac_file};
lilac.metadata.creation_date=date; 
lilac.metadata.creation_script=mfilename('fullpath');  
lilac.metadata.created_by=getenv('USER');  
lilac.metadata.acknowledgement='USA-NPN and the National Coordinating Office';
lilac.metadata.ID=UniqueIDs;%fixed from AllIDs
lilac.metadata.station_name=cell(nstns,1);
lilac.metadata.state=cell(nstns,1);
lilac.metadata.lat=AllLats(idq);
lilac.metadata.lon=AllLons(idq);
lilac.metadata.elev=AllElevs(idq);
lilac.metadata.time=years;

%% now put leaf and bloom dates into struct:
nyrs=length(lilac.metadata.time);
nstns=length(lilac.metadata.ID);
leaf_mtx=nan(nstns,nyrs);
bloom_mtx=nan(nstns,nyrs);

plant_names={'Syringa chinensis clone';'Syringa vulgaris'};
% loop through sites
for i =1:nstns
    qb=find(UniqueIDs(i)==AllIDs);    
    year_vec=AllTimes(qb);
    plant_vec=AllPlantIDs(qb);
    leaf_vec=AllLeafs(qb);
    bloom_vec=AllBlooms(qb);
    
    [o,tqa,tqb]=intersect(lilac.metadata.time,year_vec);
    leaf_mtx(i,tqa)=leaf_vec(tqb);
    bloom_mtx(i,tqa)=bloom_vec(tqb);
    plant_type{i,1}=plant_names{unique(plant_vec)};
    
end

%%
leaf_mtx(leaf_mtx>=999)=nan;
bloom_mtx(bloom_mtx>=999)=nan;

%
lilac.leaf.rows='stations';
lilac.leaf.columns='years';
lilac.leaf.data=leaf_mtx;
lilac.leaf.plant=plant_type;

lilac.bloom.rows='stations';
lilac.bloom.columns='years';
lilac.bloom.data=bloom_mtx;
lilac.bloom.plant=plant_type;

save ../data/Schwartz-Caprio lilac



