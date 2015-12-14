clear
close all
%% Edit this parameters to get different Temp curves and GDH values:
MN=20; % Tmin value (Deg F)
MX=60; % Tmax value (Deg F)
DOY=75; % Day of year (75=March 17th)
lat=45; %Latitude
%%

DAYLEN=calc_daylen(240,lat);

BASET=31;
T=nan(24,1);

[GHD,D_temp]=growdh(MX,MN,DAYLEN(DOY),BASET,T);

h=1:24;
plot(h,D_temp,'k','linewidth',2)
q=find(D_temp>BASET);
hold on
ah=area(h(q),D_temp(q),BASET,'facecolor','r','edgecolor','none');
plot(h,D_temp,'k','linewidth',2)
plot(h(q),ones(size(q))*BASET,'k--','linewidth',2)

ylabel('Temp (^oC)')
xlabel('Time (Hours since sunrise)')

load axis_settings
set(gca,axset{:})

%fig4doc('h3','../figs/gdh_demo')
h=3; w=3.5; res=300; filename='../figs/gdh_demo';printertype='-painters';
set(gcf,'paperposition',[1 1 w h])
PrevFig(1)
print('-depsc2',['-r' num2str(res)],'-cmyk','-loose',[filename '.eps'],printertype)
saveas(gcf,[filename '.fig'],'fig');

