function DAYLEN=calc_daylen(daystop,lat)
% DAYLEN=calc_daylen(daystop,latitude)
% Calculates day length for a given stoping date (e.g., 240)
% and latitude. Day lengths are only valid for the northern 
% hemisphere and are ordered as 1 = Jan 1, 2 = Jan 2, etc...

% Set target vector (DAYLEN) to zero
DAYLEN=zeros(daystop,1);

% Get solar declination values
soldec=calc_soldec;
CDAY=soldec(:,2);

if length(lat)>1
    error('length(lat)>1')
end

%     CALCULATE SOLAR VALUES
for I=1:daystop % CALCULATING DAYLENGTH for a given latitude
    if lat < 40;
        DLL=12.14+3.34*tan(lat*pi()/180)*cos(0.0172*CDAY(I)-1.95);
    else
        DLL=12.25+(1.6164+1.7643*(tan(lat*pi()/180))^2)*cos(0.0172*CDAY(I)-1.95);
    end
    dl=DLL;
    %    SET DAYLENGTH TO 1 IF LESS 1 or to 23 if more than 23 (ACCOUNTS FOR HIGH LATITUDE LOCATIONS)
    if dl < 1; dl=1; end
    if dl > 23;dl=23;end
    DAYLEN(I)=dl;
end
