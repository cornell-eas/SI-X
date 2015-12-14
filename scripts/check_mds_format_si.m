clear
close all
load si_paths
    
    %Create two arrays (tmin and tmax), with dimensions "time x days x
    %stations". These arrays are needed as input to leaf,
    %which is the main driver function of ml_si. 
    load ../data/mds_verification_data/ml_structs_from_mds_verifcation6.mat
    
    [SI_xdata,header]=xlsread([mds_verification_data_dir 'SI-x_select6_optimized_output.xls']);
    
    
    for i =1:length(select6_stn_ids);
        stn_id=num2str(select6_stn_ids(i));
        eval(['tmin(:,:,i)=USC00' stn_id '.TMIN.data;'])
        eval(['tmax(:,:,i)=USC00' stn_id '.TMAX.data;'])
        eval(['lat(i)=USC00' stn_id '.lat;']);
        tmax(tmax>900)=nan;
        tmin(tmin>900)=nan;
        
        if i ==1
            eval(['stn_time=USC00' stn_id '.time;']);
        end

    end

    % Now alculate SI:
    [LFMTX,BLMTX,LSTFRZAllSites,LFpredAllSites,BLpredAllSites]=calc_si(tmin,tmax,lat);

    % Make plot.
    % Pauses after each time series of the Bloom and Leaf indices are plotted
    % from each station. Black lines, which are the MDS verification data,
    % should cover the red and green lines after user presses any key.
    %%
    figure(1)
    clf
    nstns=length(select6_stn_ids);
    for i =1:nstns
        eval(['stn_time=USC00' num2str(select6_stn_ids(i)) '.time;']);
        
        siteq=find(SI_xdata(:,1)==select6_stn_ids(i));
        stn_num_str=num2str(select6_stn_ids(i));
        SI_x_time=SI_xdata(siteq,2);
        SI_x_lf=SI_xdata(siteq,3);
        SI_x_bl=SI_xdata(siteq,4);

        SI_x_lf(SI_x_lf>=999)=nan;
        SI_x_bl(SI_x_bl>=999)=nan;

        subplot(nstns,1,i);
            hold on
            plot(stn_time,LFMTX(:,1,i),'g');
            plot(stn_time,BLMTX(:,1,i),'r');
            pause
            plot(SI_x_time,SI_x_lf,'k');
            plot(SI_x_time,SI_x_bl,'k');

            [o,ai,bi]=intersect(SI_x_time,stn_time);    
        lfdiff=abs(SI_x_lf(ai)-LFMTX(bi,1,i));
        nnotnans=sum(~isnan(lfdiff));
        lf_me(i)=nansum(lfdiff)/nnotnans;
    
        bldiff=abs(SI_x_bl(ai)-BLMTX(bi,1,i));
        nnotnans=sum(~isnan(lfdiff));
        bl_me(i)=nansum(bldiff)/nnotnans;
    
    
    end
