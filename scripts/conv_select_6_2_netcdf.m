%Import data to matlab and convert to netcdf
clear
close all
load si_paths
datadir='../data4zack/';

%%
for i =1:length(select6_stn_ids);
    stnid=['USC00' num2str(select6_stn_ids(i))];
    eval([stnid '=read_ghcnd_dly_file(' char(39) ghcnd_data_dir stnid '.dly'  char(39) ',[ghcnd_metadata_dir ghcnd_metadata_filename]);']);
end

%%

clear ghcnd_stn
copy_fields={'source_file'
    'creation_date'
    'creation_script'
    'created_by'
    'ID'
    'state'
    'name'};

for i =1:length(select6_stn_ids);
    stnid=['USC00' num2str(select6_stn_ids(i))];
    
    ghcnd_stn.dims.years=eval(['length(' stnid '.time)']);
    ghcnd_stn.dims.days=366;
    ghcnd_stn.dims.stn=1;

    ghcnd_stn.years.data=eval([ stnid '.time']);
    ghcnd_stn.years.dim_names={'years'};
    ghcnd_stn.years.attributes.units='Years CE';

    ghcnd_stn.days.data=(1:366)';
    ghcnd_stn.days.dim_names={'days'};
    ghcnd_stn.days.attributes.units='Days from Jan 1';
    
    ghcnd_stn.lon.data=eval([ stnid '.lon']);
    ghcnd_stn.lon.dim_names={'stn'};
    ghcnd_stn.lon.attributes.units='degrees_west';
    
    
    ghcnd_stn.lat.data=eval([ stnid '.lat']);
    ghcnd_stn.lat.dim_names={'stn'};
    ghcnd_stn.lat.attributes.units='degrees_north';

    ghcnd_stn.elevation.data=eval([ stnid '.elevation']);
    ghcnd_stn.elevation.dim_names={'stn'};
    ghcnd_stn.elevation.attributes.units='meters';

    ghcnd_stn.tmax.data=eval([stnid '.TMAX.data']);
    ghcnd_stn.tmax.dim_names={'years','days'};
    ghcnd_stn.tmax.attributes.units=eval([stnid '.TMAX.units']);

    ghcnd_stn.tmin.data=eval([stnid '.TMIN.data']);
    ghcnd_stn.tmin.dim_names={'years','days'};
    ghcnd_stn.tmin.attributes.units=eval([stnid '.TMIN.units']);

    for j=1:length(copy_fields)
        eval(['ghcnd_stn.global_attributes.' copy_fields{j} '=char(' stnid '.' copy_fields{j} ');'])
    end
    ghcnd_stn.global_attributes.history='Created to test MDS code.';

    ncstruct2ncfile(ghcnd_stn, [datadir stnid '.nc'])
end



