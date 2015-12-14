% Function to calculate number and value of "synoptic events" used
% in SI calculation.
%
% Usage:
%  [DDE2, DD57, SYNFLAG]=synval(LAG,GDH,ENUM)
%
% Inputs:
%  LAG.........GDH during previous 7 days
%  GDH.........GDH at current time
%  ENUM........Event of interest (1 for leaf, 3 for bloom)
function [DDE2, DD57, SYNFLAG]=synval(LAG,GDH,ENUM)
    
%    THIS SECTION CALCULATES THE SYNOPTIC DATES
SYNFLAG=0;
if(ENUM == 1);
    LIMIT=637;
elseif(ENUM == 3);
    LIMIT=2001;
else
    error('PROBLEM WITH ENUM VALUE');
end

%     NEW SYNOPTIC SEQUENCE
VALUE=GDH+LAG(1)+LAG(2);
if VALUE >= LIMIT; 
    SYNFLAG=1; 
else
    SNYFLAG=0;
end

%     CALCULATE LAST TWO WEEK DEGREE DAY ACCUMULATION
DDE2=GDH+LAG(1)+LAG(2);
DD57=sum(LAG(5:7));
end

