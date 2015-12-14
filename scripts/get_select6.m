if ~exist('setup_mode','var')
    clear
    close all
    load si_paths
end

for i=1:length(select6_stn_ids)
    wget_expr=[wget_cmmnd ' --passive-ftp ' ' -O ' ghcnd_data_dir 'USC00' num2str(select6_stn_ids(i))  '.dly ftp://ftp.ncdc.noaa.gov/pub/data/ghcn/daily/hcn/USC00' num2str(select6_stn_ids(i))  '.dly'];
    eval(['!echo ' wget_expr])
    eval(['!' wget_expr])

end


