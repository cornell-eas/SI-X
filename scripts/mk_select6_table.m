clear
close all

load ../data/select6.mat
a=whos;

disp('\hline')
disp('\hline')
disp(['Station ID & Station Name & State & Lat & Lon & Elev \\'])
disp('\hline')
for i =1:6
disp([eval([eval(['a(i).name']) '.ID']) ' & ' ...
    eval([eval(['a(i).name']) '.name{:}']) ' & ' ...
    eval([eval(['a(i).name']) '.state{:}']) ' & ' ...
    num2str(eval([eval(['a(i).name']) '.lat'])) ' & ' ... 
    num2str(eval([eval(['a(i).name']) '.lon'])) ' & ' ... 
    num2str(eval([eval(['a(i).name']) '.elevation'])) ' \\ '])
end
disp('\hline')

% 
%  ID: 'USC00114442'
%                 lon: -90.2153
%                 lat: 39.7353
%           elevation: 185.9000
%                time: [201x1 double]
%               state: {'IL'}
%                name: {'JACKSONVILLE 2E'}