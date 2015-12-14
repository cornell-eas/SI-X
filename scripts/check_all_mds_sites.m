clear
close all
load si_paths
load([ghcnd_metadata_dir ghcnd_metadata_filename])
addpath ../si_funcs/

[SI_xdata,header]=xlsread([mds_verification_data_dir 'SI-x_opt_716_1900_2012_final_test.xls']);

[stnlist,ulistq]=unique(SI_xdata(:,1));

verification_results.lat=SI_xdata(ulistq,6);
verification_results.lon=SI_xdata(ulistq,7);
verification_results.lf_me=nan*ulistq;
verification_results.bl_me=nan*ulistq;

%%
for i =1:length(stnlist)
    try
    stnid0=num2str(stnlist(i));
    if length(stnid0)==5
        stnid=['USC000' stnid0];
    elseif length(stnid0)==6
        stnid=['USC00' stnid0];
    else
        error(['station id length=' length(stnid0)])
    end
        
    eval([stnid '=read_ghcnd_dly_file_no_load(' char(39) ghcnd_data_dir stnid '.dly'  char(39) ',ghcnd_metadata);']);
    eval(['tmin=convert_temp(' stnid '.TMIN.data,' char(39) 'C' char(39) ',' char(39) 'F' char(39) ');']);
    eval(['tmax=convert_temp(' stnid '.TMAX.data,' char(39) 'C' char(39) ',' char(39) 'F' char(39) ');']);
    eval(['lat(i)=' stnid '.lat;']);

    
    eval(['stn_time=' stnid '.time;']);
    
    
    % Now alculate SI:
    [LFMTX,BLMTX,LSTFRZAllSites,LFpredAllSites,BLpredAllSites]=calc_si(tmin,tmax,lat);
    
    %Get MDS data
    siteq=find(SI_xdata(:,1)==stnlist(i));
    SI_x_time=SI_xdata(siteq,2);
    SI_x_lf=SI_xdata(siteq,3);
    SI_x_bl=SI_xdata(siteq,4);

    SI_x_lf(SI_x_lf>=999)=nan;
    SI_x_bl(SI_x_bl>=999)=nan;


    % Make plot.
%     figure(1)
%     clf
%     hold on
%         plot(stn_time,LFMTX(:,1),'g');
%         plot(stn_time,BLMTX(:,1),'r');        
%         plot(SI_x_time,SI_x_lf,'k');
%         plot(SI_x_time,SI_x_bl,'k');
        
    [o,ai,bi]=intersect(SI_x_time,stn_time);    
    lfdiff=abs(SI_x_lf(ai)-LFMTX(bi,1));
    nnotnans=sum(~isnan(lfdiff));
    lf_me(i)=nansum(lfdiff)/nnotnans;
    
    bldiff=abs(SI_x_bl(ai)-BLMTX(bi,1));
    nnotnans=sum(~isnan(lfdiff));
    bl_me(i)=nansum(bldiff)/nnotnans;
    disp(['done with ' stnid ' (i=' num2str(i) ')']);
    
    catch
        disp(['Problems with ' stnid ' (i=' num2str(i) ')']);
    end
end

verification_results.lf_me=lf_me;
verification_results.bl_me=bl_me;

save ../data/mds716sites verification_results

% Calculate SI:
%[LFMTX,BLMTX,LSTFRZAllSites,LFpredAllSites,BLpredAllSites]=calc_si(tmin,tmax,lat);



