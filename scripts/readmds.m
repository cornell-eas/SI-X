clear
close 

fid=fopen('../data/mds_verification_data/Select6_maxmin.dat');
k=1;
stnq=(1:7);
yrq=(8:11);

for i =1:20
    i1(i,1:2)=[(12)+(i-1)*3 (14)+(i-1)*3];
    i2(i,1:2)=[(2)+(i-1)*3 (4)+(i-1)*3];
    if i<=6
        i3(i,1:2)=[(2)+(i-1)*3 (4)+(i-1)*3];
    end

end

%i2(end,2)=i2(end,2)-1;

%%
isstart=1;
lcount=1;
daycount=1;
oneyear=nan(1,366);
stnum=nan;
ncases=0;
varswitch=1;
allyrs=1850:2010;

while 1
    
    aline=fgetl(fid);
    if ~ischar(aline),
        break
    end
    X{k}=aline;
    
    if lcount==1        
        stnid=str2num(aline(stnq));
        yr=str2num(aline(yrq));
        allyrq=find(allyrs==yr);
        
        for j = 1:length(i1)
            oneyear(daycount)=str2num(aline(i1(j,1):i1(j,2)));
            daycount=daycount+1;
        end
    end
    if lcount >1 & lcount <19
        for j = 1:length(i2)
            oneyear(daycount)=str2num(aline(i2(j,1):i2(j,2)));
            daycount=daycount+1;
        end
    end
    if lcount==19
        for j = 1:length(i3)
            oneyear(daycount)=str2num(aline(i3(j,1):i3(j,2)));
            daycount=daycount+1;
        end
    end        
        
    lcount=lcount+1;
    
    if lcount>19
        lcount=1;
        daycount=1;        
        ncases=ncases+1;
        tempall(ncases,:)=oneyear;
        yearlist(ncases)=yr;
        stnlist(ncases)=stnid;
            
        oneyear=nan(1,366);
        varswitch=~varswitch;
    end
    
    k=k+1;
end   
fclose(fid);
%%

unique_stnids=unique(stnlist);
stnlats=[39.73 40.08 43.70 37.49  34.98 35.41];
stnlons=[-90.20 -88.24 -92.56 -94.31 -80.52 -86.81];


for i =1:length(unique_stnids);
    
    stnq=find(unique_stnids(i)==stnlist);
    
    stntmax=tempall(stnq(1:2:end),:);
    stntmin=tempall(stnq(2:2:end),:);
    stnyrs=yearlist(stnq(1:2:end));
    [a,ai,bi]=intersect(allyrs,stnyrs);
    stn.ID=num2str(unique_stnids(i));
    stn.lat=stnlats(i);
    stn.lon=stnlons(i);
    stn.time=allyrs;
    stn.TMIN.data=nan(length(allyrs),366);
    stn.TMAX.data=nan(length(allyrs),366);
    
    stn.TMIN.data(ai,:)=stntmin(bi,:);
    stn.TMAX.data(ai,:)=stntmax(bi,:);
    
    eval(['USC00' num2str(unique_stnids(i)) '=stn;'])
end

save ../data/mds_verification_data/ml_structs_from_mds_verifcation6 USC*
