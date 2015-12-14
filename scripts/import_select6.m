%Import data to matlab sent from M. D. Schwartz to validate SI-x code.
%
% This script will read through a list of stations (select6_stn_ids, set in
% setup_ml_si), use wget to retreive them from the NOAA ftp site, and 
% save them to a matlab file (select6.mat). This file comes with the ml_si
% distribution, so you shouldn't need to run this script unless you want
% to.
%
%First get the data with shell script:
%! get_select6.sh
% Or, alternatively, the matlab script:
% get_select6.m
if ~exist('setup_mode','var')
    clear
    close all
    load si_paths
end

%%
for i =1:length(select6_stn_ids);
    stnid=['USC00' num2str(select6_stn_ids(i))];
    eval([stnid '=read_ghcnd_dly_file(' char(39) ghcnd_data_dir stnid '.dly'  char(39) ',[ghcnd_metadata_dir ghcnd_metadata_filename]);']);
end

%%
save([si_data_dir 'select6.mat'],'USC*')
