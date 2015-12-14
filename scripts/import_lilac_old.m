if ~exist('setup_mode','var')
    clear
    close all
    load si_paths
end

fid=fopen(lilac_file);
s = textscan(fid, '%s', 'Delimiter', '\n', 'whitespace', '');
fclose(fid);    

%%
%     -> Lines 162:15233 are data 
%     -> lines 15250:16375 are metadata:
%        ID:   		 1:7      
%        Station Name:     10:45                 
%        State/Prov        47:48
%        Lat               54:59
%        Long              65:71
%        Elev              76:82
raw_pheno_meta=char(s{1}(15250:16375));
lilac.metadata.source_file=lilac_file;
lilac.metadata.creation_date=date; 
lilac.metadata.creation_script=mfilename('fullpath');  
lilac.metadata.created_by=getenv('USER');     
lilac.metadata.ID=str2num(raw_pheno_meta(:,1:7));
lilac.metadata.station_name=raw_pheno_meta(:,10:45);
lilac.metadata.state=raw_pheno_meta(:,47:48);
lilac.metadata.lat=str2num(raw_pheno_meta(:,54:59));
lilac.metadata.lon=str2num(raw_pheno_meta(:,65:71));
lilac.metadata.elev=str2num(raw_pheno_meta(:,76:82));

% Column 1: Station ID (Station location table follows data table)
% Column 2: Year 
% Column 3: Plant type.    1=Syringa chinensis clone   2=Syringa vulgaris
% Column 4: Date of First Leaf,  Day of year, missing = 999
% Column 5: Date of First Bloom, Day of year, missing = 999
raw_pheno_data=str2num(char(s{1}(162:15233)));

%lilac.time
lilac.metadata.time=min(raw_pheno_data(:,2)):max(raw_pheno_data(:,2));
%
nyrs=length(lilac.metadata.time);
nstns=length(lilac.metadata.ID);
leaf_mtx=nan(nstns,nyrs);
bloom_mtx=nan(nstns,nyrs);

plant_names={'Syringa chinensis clone';'Syringa vulgaris'};
% loop through sites
for i =1:nstns
    qb=find(lilac.metadata.ID(i)==raw_pheno_data(:,1));
    id_vec=raw_pheno_data(qb,1);
    year_vec=raw_pheno_data(qb,2);
    plant_vec=raw_pheno_data(qb,3);
    leaf_vec=raw_pheno_data(qb,4);
    bloom_vec=raw_pheno_data(qb,5);
    
    [o,tqa,tqb]=intersect(lilac.metadata.time,year_vec);
    leaf_mtx(i,tqa)=leaf_vec(tqb);
    bloom_mtx(i,tqa)=bloom_vec(tqb);
    plant_type{i,1}=plant_names{unique(plant_vec)};
    
end
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




