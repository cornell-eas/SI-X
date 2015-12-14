% Calculation of SI from a single station. 

%% Clear worspace and load "select 6"
clear
close all
load ../data/select6.mat
%%

stn_nums=[405187];
    
for i =1:length(stn_nums);
    stn_id=num2str(stn_nums(i));
    eval(['tmin(:,:,i)=convert_temp(USC00' stn_id '.TMIN.data,' char(39) 'C' char(39) ',' char(39) 'F' char(39) ');']);
    eval(['tmax(:,:,i)=convert_temp(USC00' stn_id '.TMAX.data,' char(39) 'C' char(39) ',' char(39) 'F' char(39) ');']);
    eval(['lat(i)=USC00' stn_id '.lat;']);
    eval(['stn_time=USC00' stn_id '.time;']);
    
    if i ==1
        eval(['stn_time=USC00' stn_id '.time;']);
    end
    
end


[LFMTX,BLMTX,LSTFRZAllSites,LFpredAllSites,BLpredAllSites]=calc_si(tmin,tmax,lat);


%%
figure(1)
clf
load axis_settings
load custom_linecolors
axpos=[0.1300    0.1100    0.7750    0.3299
       0.1300    0.525    0.7750    0.3299    ];
   
ax(1)=axes('pos',axpos(1,:));
    set(gca,axset{:},'colororder',[darkgreen_rgb; darkred_rgb;gold_rgb; orange_rgb; [0 0 0]])
    hold on
    p2=plot(stn_time,BLMTX(:,2:end),'linewidth',2);
%     p2(end+1)=plot(stn_time,BLMTX(:,1),'k','linewidth',2);
    ylabel 'Day of Year'
    title('b) First Bloom',ttlset{:},'position',[1885 136])
    
    
ax(2)=axes('pos',axpos(2,:));
    set(gca,axset{:},'colororder',[darkgreen_rgb; darkred_rgb;gold_rgb; orange_rgb; [0 0 0]])
%     set(gca,axset{:})
    hold on
    p=plot(stn_time,LFMTX(:,2:end),'linewidth',2);
%     p(end+1)=plot(stn_time,LFMTX(:,1),'k','linewidth',2);
    ylabel 'Day of Year'
    title('a) First Leaf',ttlset{:},'position',[1885 93])
    xlabel ('Year')
    lg=legend('Lilac','Arnold Red','Zabeli');
    
basetime=[0 75];
set(ax(1),'yaxislocation','left','ytick',[75:15:105],'ylim',basetime+60)
set(ax(2),'ytick',[30:15:75],'ylim',basetime+15,'xtickl','')
set(ax,'xlim',[1900 2013],axset{:},'box','on')
set(lg,'pos',[0.75    0.82    0.1966    0.15])

% Output figure settings:
h=4.6; w=6; res=300; filename='../figs/all_plant_fig';printertype='-painters';
set(gcf,'paperposition',[1 1 w h])
PrevFig(1)
print('-depsc2',['-r' num2str(res)],'-cmyk','-loose',[filename '.eps'],printertype)
saveas(gcf,[filename '.fig'],'fig');


%%
figure(2)
clf
DamageIndex=LFMTX(:,1) - LSTFRZAllSites;
DamageIndex=DamageIndex-nanmean(DamageIndex);
ax2pos=[0.1300    0.32    0.7750    0.6
       0.1300    0.1    0.7750    0.2];
   
ax2(1)=axes('pos',ax2pos(1,:));
    set(gca,'colororder',[darkgreen_rgb;  lightcyan_rgb; darkred_rgb; orange_rgb])
    hold on
    p=plot(stn_time,[LFMTX(:,1)  LSTFRZAllSites BLMTX(:,1) nan*DamageIndex ] );
    ylabel 'Day of Year'
    title('Spring Indices',ttlset{3:end})
    xlabel ('Year')
    lg2=legend('Leaf Index','Last Freeze','Bloom Index','Damage Index');
    
ax2(2)=axes('pos',ax2pos(2,:));   
    
    p2=plot(stn_time,DamageIndex,'color',orange_rgb);
    ylabel({'Anomalous';'Day'})
    xlabel ('Year')

basetime=[0 150];
set(ax2(1),'yaxislocation','left','ytick',[30:15:145],'ylim',basetime,'xtickl','')
set(ax2(2),'ylim',[-50 50])
set(ax2,'xlim',[1900 2013],axset{:},'box','on')
set(lg2,'pos',[0.75    0.82    0.1966    0.15])
set([p; p2],'linewidth',2)

% Output figure settings:
h=4.6; w=6; res=300; filename='../figs/all_index_fig';printertype='-painters';
set(gcf,'paperposition',[1 1 w h])
PrevFig(2)
print('-depsc2',['-r' num2str(res)],'-cmyk','-loose',[filename '.eps'],printertype)
saveas(gcf,[filename '.fig'],'fig');
