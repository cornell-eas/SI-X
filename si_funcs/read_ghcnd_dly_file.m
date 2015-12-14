function station=read_ghcnd_dly_file(filename,metadata_filename,varargin)
%station=read_ghcnd_dly_file(filename,metadata_filename)
%
%
% This function will read in ghcnd .dly files and create appropriate
% variables from columns, then store them in a structure returned as
% "station." The input "metadata_filename" is needed and may be produced by
% first running "mk_ghcnd_metadata.m"
 
% ------------------------------
% Variable   Columns   Type
% ------------------------------
% ID            1-11   Character
% YEAR         12-15   Integer
% MONTH        16-17   Integer
% ELEMENT      18-21   Character
% VALUE1       22-26   Integer
% MFLAG1       27-27   Character
% QFLAG1       28-28   Character
% SFLAG1       29-29   Character
% VALUE2       30-34   Integer
% MFLAG2       35-35   Character
% QFLAG2       36-36   Character
% SFLAG2       37-37   Character
%   .           .          .
%   .           .          .
%   .           .          .
% VALUE31    262-266   Integer
% MFLAG31    267-267   Character
% QFLAG31    268-268   Character
% SFLAG31    269-269   Character
% ------------------------------

dataq=[(22:8:262)' (23:8:263)' (24:8:264)' (25:8:265)' (26:8:266)'];

if isempty(varargin)
    disp('No variables to import specified (using defaults).')    
    varnames={'TMIN','TMAX'};
else
    varnames=varargin;
end

disp('Importing:')
allyrs=(1850:2050)';%could be changed, just sets up vector.
for i =1:length(varnames)
    disp(varnames{i})
    eval([varnames{i} '=nan(length(allyrs),366);']);
end

%           J  F  M  A  M  J  J  A  S  O  N  D
ndays_in_mo=[31 28 31 30 31 30 31 31 30 31 30 31];

ndays_in_mo_leap=...
            [31 29 31 30 31 30 31 31 30 31 30 31];

load(metadata_filename)

station.source_file=filename;
station.creation_date=date; 
station.creation_script=mfilename('fullpath');  
station.created_by=getenv('USER');    

a=fopen(filename);
k=1;

while 1
    aline=fgetl(a);
    if ~ischar(aline), 
        break, 
    end
    bline=char(aline);
    ID=bline(1:11);
    
    if k==1
        % get stn meta
        stnq=find(strcmpi(ID,cellstr(ghcnd_metadata.ID)));
        station.ID=ghcnd_metadata.ID(stnq,:);
        station.lon=ghcnd_metadata.lon(stnq);        
        station.lat=ghcnd_metadata.lat(stnq);
        station.elevation=ghcnd_metadata.elevation(stnq);
        station.time=allyrs;
        station.state=ghcnd_metadata.state(stnq);
        station.name=ghcnd_metadata.name(stnq);
    end
    
    
    year=str2num(bline(12:15));
    yearq=find(year==allyrs);
    month=str2num(bline(16:17));
    
    if month==1
        daystart=1;
        daystop=31;
        ndays=31;
    else
        if leapyear(year)
            daystart=sum(ndays_in_mo_leap(1:month-1))+1;
            daystop=daystart+ndays_in_mo_leap(month)-1;
            ndays=ndays_in_mo_leap(month);
        else
            daystart=sum(ndays_in_mo(1:month-1))+1;
            daystop=daystart+ndays_in_mo(month)-1;
            ndays=ndays_in_mo(month);
        end
    end
    
    
    %%% START HERE
    % need a loop to
     element=bline(18:21);
     vari=strcmp(element,varnames);
     vartemp=nan(1,ndays);
     if any(vari)
         for j=1:ndays
             varday=str2num(bline(dataq(j,:)));
             if ~isempty(varday)
                 vartemp(j)=varday;
             end
         end
        eval([varnames{vari} '(yearq,daystart:daystop)=vartemp;'])         
     end
    
    k=k+1;
end
fclose(a);

for i =1:length(varnames)
    unitname='';
    eval([varnames{i} '(' varnames{i} '==-9999)=nan;'])
    if strcmp(varnames{i},'TMAX') | strcmp(varnames{i},'TMIN')
        eval([varnames{i} '=' varnames{i} './10;' ])
        unitname='degC';
    end
    
    if strcmp(varnames{i},'PRCP')
      eval([varnames{i} '=' varnames{i} './10;' ])
      unitname='mm';
    end
          
    eval(['station.' varnames{i} '.units=unitname;'])
    
    eval(['station.' varnames{i} '.data=' varnames{i} ';'])
end
 
