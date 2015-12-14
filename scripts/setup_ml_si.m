%Sets up ml_si working directory, directory names, and data dirs.
%Also checks code using the "Select 6" validation sites.
clear
close all

% Path and data directory settings
si_func_dir='../si_funcs/';%Location of SI functions
si_data_dir='../data/'; %Default data directory

ghcnd_metadata_dir='../data/'; %Directory where matlab file containing 
                               %GHNCD metadata is stored
ghcnd_data_dir='../data/ghcnd_all/';%Directory where GHCND data is stored
ghcnd_select6_dir='../data/'; % Directory with "Select 6" station data
ghcnd_metadata_filename='ghcnd_metadata.mat'; % Name of file with GHCN 
                                              % Metadata (allows for
                                              % multiple versions)

mds_verification_data_dir='../data/mds_verification_data/'; %Path to
                    %MDS output from Fortran calculations of SI for the
                    %"select 6" stations
m_plot_dir='/Users/tra38/Matlab/m_map/m-map/';%Path to m_map
wget_cmmnd='/usr/local/bin/wget';% Command to use for wget, if needed.
select6_stn_ids=[114442 118740 213290 234705 315771 405187]; %IDs for 
               %select 6 stations.

% Files sent by Alyssa Rosemartin, USA-NPN:
easternUS_lilac_file=[si_data_dir 'SC_SV_Lilac_1961_2008.xls']; %Location and file name 
westernUS_lilac_file=[si_data_dir 'Lilac_SV_westUSA_1956_2009.xls']; %Location and file name of western US lilac


% Some options for this script:
setup_mode=true; % Run scripts in "set up mode." Scripts can also run as 
                 % stand alone routines, so this parameter just tells them
                 % that they are being called by this "master" script.
                 
check_si=true; %check SI code. It is recommended that this be set to true. 
               %If it is, a plot of time series will be generated at the
               %end, similar to Figure 1 of the user's guide.

check_wget=false; %Tests wget command to make it works: will retrieve the 
                                     %"select6" stations if successful.
                                     
check_ghcnd_metadata=false;% Test to make sure ghcnd station metadata is where it is
                                     % expected to be.  
                                     
check_select6_import=false; %Tests whether importing data from the folder
                                     %"ghcnd_metadata_dir" is successful. 
                                     % Again using the select6 stations.
                                     
check_lilac_import=false; % makes sure lilac data is where it is expected to
                                     % be and can be imported.
                         

%% Now set up environment
addpath(si_func_dir)
addpath(m_plot_dir)

%%
display_message={'SUCCESS!!! ml_si should be ready to run. The following options were tested:'};
%% Call routine to test wget functionality
if check_wget
    get_select6
    display_message={display_message{:}, ['(x) Successfully tested wget to retrieve "select 6" stations.']};
end

%% Call routine to test ghcnd_metadata functionality
if check_ghcnd_metadata
    mk_ghcnd_metadata;
    display_message={display_message{:}, ['(x) Successfully created "' ghcnd_metadata_dir ghcnd_metadata_filename '" from ' ghcnd_metadata_dir 'ghcnd-inventory.txt']};
end

%% Call routine to test import functionality
if check_select6_import
    import_select6
    display_message={display_message{:}, ['(x) Successfully created ' [si_data_dir 'select6.mat'] ' from "select6_stn_ids"']};
end

%% Check if lilac data is importable:
if check_lilac_import
    import_lilac
    display_message={display_message{:}, ['(x) Successfully created ./data/Schwartz-Caprio lilac from ' easternUS_lilac_file ' and ' westernUS_lilac_file]};
end
%% Check that everything is working properly
if check_si
    
    %Create two arrays (tmin and tmax), with dimensions "time x days x
    %stations". These arrays are needed as input to leaf,
    %which is the main driver function of ml_si. 
    load([si_data_dir 'select6.mat'])
    [SI_xdata,header]=xlsread([mds_verification_data_dir 'SI-x_select6_optimized_output.xls']);
    display_message={display_message{:}, ['(x) Successfully checked to make sure MDS verification data is available.']};
    
    for i =1:length(select6_stn_ids);
        stn_id=num2str(select6_stn_ids(i));
        eval(['tmin(:,:,i)=convert_temp(USC00' stn_id '.TMIN.data,' char(39) 'C' char(39) ',' char(39) 'F' char(39) ');']);
        eval(['tmax(:,:,i)=convert_temp(USC00' stn_id '.TMAX.data,' char(39) 'C' char(39) ',' char(39) 'F' char(39) ');']);
        eval(['lat(i)=USC00' stn_id '.lat;']);

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
        siteq=find(SI_xdata(:,1)==select6_stn_ids(i));
        stn_num_str=num2str(select6_stn_ids(i));
        SI_x_time=SI_xdata(siteq,2);
        SI_x_lf=SI_xdata(siteq,3);
        SI_x_bl=SI_xdata(siteq,4);

        SI_x_lf(SI_x_lf>=999)=nan;
        SI_x_bl(SI_x_bl>=999)=nan;

        ax(i) =subplot(nstns+1,1,i+1);
            hold on
            plot(stn_time,LFMTX(:,1,i),'g','linewidth',3);
            plot(stn_time,BLMTX(:,1,i),'r','linewidth',3);            
            plot(SI_x_time,SI_x_lf,'color',[.1 .1 .1],'linewidth',1.3);
            plot(SI_x_time,SI_x_bl,'k-','linewidth',1.3);
            title(['USC00' num2str(select6_stn_ids(i))])
            
            if i==1
                lg=legend('Leaf Index (Matlab)','Bloom Index (Matlab)','Leaf Index (Fortran)','Bloom Index (Fortran)');
                set(lg,'pos',[0.33    0.8627    0.4    0.1118])
            end
            ylabel ('DOY')

    end
    %%
    xlabel ('Time (Year)')
    set(ax,'xlim',[1890 2015],'box','on','xtick',1800:20:2010,'ylim',[20 165]);
    set(ax(1:end-1),'xtickl','')
    %
    % export eps file:
    % Output figure settings:
    h=7.2; w=6.5; res=300; filename='../figs/select6';printertype='-painters';
    set(gcf,'paperposition',[1 1 w h])
    PrevFig(1)
    print('-depsc2',['-r' num2str(res)],'-cmyk','-loose',[filename '.eps'],printertype)
    saveas(gcf,[filename '.fig'],'fig');

end

%%

% and save, if successful:
save si_paths si_func_dir si_data_dir ...
    ghcnd_data_dir ghcnd_metadata_dir ghcnd_metadata_filename ...
    mds_verification_data_dir select6_stn_ids ...
    m_plot_dir easternUS_lilac_file westernUS_lilac_file ...
    wget_cmmnd display_message

%% Clear workspace and print setup message.
% clear 
load si_paths display_message si_data_dir
disp(char(display_message'))
disp(' ')
disp(char({'The following commands can be used to generate SI from';'GHCN station "USC00405187":'}))
disp([' load ' si_data_dir 'select6.mat'])
disp([' tmin=convert_temp(USC00405187.TMIN.data,' char(39) 'C' char(39) ',' char(39) 'F' char(39) ');']);
disp([' tmax=convert_temp(USC00405187.TMAX.data,' char(39) 'C' char(39) ',' char(39) 'F' char(39) ');']);
disp([' lat=USC00405187.lat;']);
disp(' [LF,BL,LSTFR,LFpred,BLpred]=calc_si(tmin,tmax,lat);')
