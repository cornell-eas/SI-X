if ~exist('setup_mode','var')
    clear
    close all
    load si_paths
end

%ghcnd_metadata_dir='../data/';
source_file='ghcnd-stations.txt';


% IV. FORMAT OF "ghcnd-stations.txt"
% 
% ------------------------------
% Variable   Columns   Type
% ------------------------------
% ID            1-11   Character
% LATITUDE     13-20   Real
% LONGITUDE    22-30   Real
% ELEVATION    32-37   Real
% STATE        39-40   Character
% NAME         42-71   Character
% GSNFLAG      73-75   Character
% HCNFLAG      77-79   Character
% WMOID        81-85   Character
% ------------------------------
%( see readme.txt file)

nrows=85986;
IDq=1:11;
LATq=13:20;
LONq=22:30;
ELEVq=32:37;
STATEq=39:40;
NAMEq=42:71;
GSNFLAGq=73:75;
HCNFLAGq=77:79;
WMOIDq=81:85;

fid=fopen([ghcnd_metadata_dir source_file]);
k=1;
%ACW00011604  17.1167  -61.7833 TMAX 1949 1949
while k<=nrows
    aline=fgetl(fid);
    if ~ischar(aline)
        break
    end
    bline=char(aline);
    AllTXT{k,1}=bline;
    ID(k,:)=bline(IDq);
    LATITUDE(k,1)=str2num(bline(LATq));
    LONGITUDE(k,1)=str2num(bline(LONq));
    ELEVATION(k,1)=str2num(bline(ELEVq));
    STATE{k,1}=deblank(bline(STATEq));
    NAME{k,1}=deblank(bline(NAMEq));
    GSNFLAG{k,1}=deblank(bline(GSNFLAGq));
    HCNFLAG{k,1}=deblank(bline(HCNFLAGq));
    WMOID{k,1}=deblank(bline(WMOIDq));
    
    k=k+1;
    
end
fclose(fid);

ELEVATION(ELEVATION<-999)=nan;

ghcnd_metadata.source_file=source_file;
ghcnd_metadata.creation_date=date; 
ghcnd_metadata.creation_script=mfilename('fullpath');  
ghcnd_metadata.created_by=getenv('USER');     
ghcnd_metadata.ID=ID;
ghcnd_metadata.lon=LONGITUDE;
ghcnd_metadata.lat=LATITUDE;
ghcnd_metadata.elevation=ELEVATION;
ghcnd_metadata.state=STATE;
ghcnd_metadata.name=NAME;
ghcnd_metadata.gsnflag=GSNFLAG;
ghcnd_metadata.hcnflag=HCNFLAG;
ghcnd_metadata.wmoid=WMOID;

%
%save ../data/ghcnd_metadata ghcnd_metadata
save([ghcnd_metadata_dir ghcnd_metadata_filename],'ghcnd_metadata')
