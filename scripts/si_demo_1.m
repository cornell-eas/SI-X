% Example illustrating how each of the predictors comprising the 
% leaf index and bloom index are generated using the functions
% in ../si_funcs/.

%% Clear workspace and load appropriate data (select6.mat, in this case):
clear
close all
load ../data/select6.mat
load si_paths
%% Select a station and year
stn_nums=[114442]; % Station #
yrq=47; % index of year (47 = 1896 AD)

% Create vectors of Tmin/Tmax
for i =1:length(stn_nums);
    stn_id=num2str(stn_nums(i));
    eval(['tmin1year(:,:,i)=convert_temp(USC00' stn_id '.TMIN.data(yrq,:),' char(39) 'C' char(39) ',' char(39) 'F' char(39) ');']);
    eval(['tmax1year(:,:,i)=convert_temp(USC00' stn_id '.TMAX.data(yrq,:),' char(39) 'C' char(39) ',' char(39) 'F' char(39) ');']);
    eval(['lat(i)=USC00' stn_id '.lat;']);
    
    if i ==1
        eval(['stn_time=USC00' stn_id '.time;']);
    end
    
end

% Calculate SI
[LFMTX_1year,BLMTX_1year]=calc_si(tmin1year,tmax1year,lat);

%% Now show each of the individual predictor variables
DAYLEN=eval(['calc_daylen(240,USC00' num2str(stn_nums)  '.lat)']);
BASET=31;
T=nan(24,1);
AGDH=zeros(8,1);
ENUM=1;
SYNTOT=0;
SYNTOT_bl=0;
SYNFLAG=0;
SYNFLAG_bl=0;

for i=2:240;
    MN=tmin1year(i);
    MX=tmax1year(i);        

    [GDH,D_temp]=growdh(MX,MN,DAYLEN(i),BASET,T);
    GDH_ts(i)=GDH;
    if i>8
        LAG=(GDH_ts(i-7:i));
        [DDE2, DD57, SYNFLAG]=synval(LAG,GDH,ENUM);               
        DDE2_ts(i)=DDE2;
        DD56_ts(i)=DD57;
        AGDH(i)=AGDH(i-1)+GDH;
        
        [DDE2, DD57, SYNFLAG_bl]=synval(LAG,GDH,3);               
    end

    SYNTOT(i)=SYNTOT(i-1)+SYNFLAG;
    SYNTOT_bl(i)=SYNTOT_bl(i-1)+SYNFLAG_bl;
        
end

%%
figure(1)
clf

Tmax=tmax1year;
Tmin=tmin1year;
daymax=240;
GDH=GDH_ts;
SYNOP=SYNTOT;
DDE2=DDE2_ts;
DD57=DD56_ts;
mnLFraw=LFMTX_1year(1);
mnBLraw=BLMTX_1year(1);

ax(1)=subplot(511);
    p1=plot([Tmax(1:daymax)' Tmin(1:daymax)']);
    set(gca,'ylim',[-22 90])
    ylabel 'Temp (^oF)'
    lg=legend('T_{max}','T_{min}','location','northwest');
    legend boxon
    set(lg,'pos',[    0.15    0.9    0.1351    0.0562])
    

% subplot(512)
%     p2=plot(1:daymax,1:daymax);
%     ylabel 'DOY'
%     xlabel 'Time (DOY)'
    
ax(2)=subplot(512);
    p2=plot(1:daymax,GDH);
    ylabel 'GDH'    
    

ax(3)=subplot(513);
    p3=stairs(1:daymax,SYNOP);
    ylabel 'SYNOP'    
        
ax(4)=subplot(514);
    p4=plot(1:daymax,DDE2,1:daymax,ones(1,daymax)*637,'--');    
    ylabel 'DDE2'        
    
ax(5)=subplot(515);
    p5=plot(1:daymax,DD57);
    ylabel 'DD57'
    xlabel 'Time (DOY)'
    

load custom_linecolors
load axis_settings
for i =1:5
    set(eval(['p' num2str(i)]),'color','k','linewidth',2);
    set(gcf,'currentax',ax(i))
    hold on
    ylims=get(gca,'ylim');
    
    text(mnLFraw,ylims(2)+ylims(2)*.1,'Leaf Index');
    
    axpos=get(gca,'pos');
    
    set(gca,axset{:},'box','on','pos',[axpos(1)-.005 axpos(2:end)],'xlim',[0 115]);    
    plot([mnLFraw mnLFraw],ylims,'linestyle','--','color',darkgreen_rgb,'linewidth',2)
    if i ==4
        text(daymax+1,637,{'Event';'Threshold'},axset{1:4})
    end
end


set(p1(1),'color',darkred_rgb);
set(p1(2),'color','b');


h=7.2; w=6.5; res=300; filename='../figs/predictor_fig_lf';printertype='-painters';
set(gcf,'paperposition',[1 1 w h])
PrevFig(1)
print('-depsc2',['-r' num2str(res)],'-cmyk','-loose',[filename '.eps'],printertype)
saveas(gcf,[filename '.fig'],'fig');


%%
figure(2)
clf
Tmax=tmax1year;
Tmin=tmin1year;
GDH=GDH_ts;
SYNOP=SYNTOT_bl;
DDE2=DDE2_ts;
DD57=DD56_ts;
mnLFraw=LFMTX_1year(1);



ax(1)=subplot(311);
    p1=plot([Tmax(1:daymax)' Tmin(1:daymax)']);
    set(gca,'ylim',[-10 110])
    ylabel 'Temp (^oF)'
    lg=legend('T_{max}','T_{min}','location','northwest');
    legend boxon
    set(lg,'pos',[    0.15    0.9    0.1351    0.0562])
    

% subplot(512)
%     p2=plot(1:daymax,1:daymax);
%     ylabel 'DOY'
%     xlabel 'Time (DOY)'
    
ax(2)=subplot(312);
    p2=plot(1:daymax,GDH);
    ylabel 'GDH'    
    

ax(3)=subplot(313);
    p3=stairs(1:daymax,AGDH./100);
    ylabel 'AGDH \cdot 10^{-2}'    
    set(gca,'ylim',[0 600]);
    
load custom_linecolors
load axis_settings
for i =1:3
    set(eval(['p' num2str(i)]),'color','k','linewidth',2);
    set(gcf,'currentax',ax(i))
    hold on
    ylims=get(gca,'ylim');
    
    text(mnLFraw,ylims(2)+ylims(2)*.1,'Leaf Index');
    text(mnBLraw,ylims(2)+ylims(2)*.1,'Bloom Index');
    
    axpos=get(gca,'pos');
    
    set(gca,axset{:},'box','on','pos',[axpos(1)-.005 axpos(2:end)],'xlim',[60 140]);    
    plot([mnBLraw mnBLraw],ylims,'linestyle','--','color','m','linewidth',2)
    plot([mnLFraw mnLFraw],ylims,'linestyle','--','color',darkgreen_rgb,'linewidth',2)
    if i ==4
        text(daymax+1,2001,{'Event';'Threshold'},axset{1:4})
    end
end


set(p1(1),'color',darkred_rgb);
set(p1(2),'color','b');

% Output figure settings:
h=7.2*(3/5); w=6.5; res=300; filename='../figs/predictor_fig_bl';printertype='-painters';
set(gcf,'paperposition',[1 1 w h])
PrevFig(2)
print('-depsc2',['-r' num2str(res)],'-cmyk','-loose',[filename '.eps'],printertype)
saveas(gcf,[filename '.fig'],'fig');

