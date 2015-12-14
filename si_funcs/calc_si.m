function [LF,BL,LSTFR,LFpred,BLpred]=calc_si(Tminall,Tmaxall,latitude)
%Main SI-ML driver function for calculating first leaf, first bloom, and
%least freeze.
%    
%Usage:    
% [LF,BL,LSTFR,LFpred,BLpred]=calc_si(Tmin,Tmax,latitude)
%
%Input:
% Tminall..........2D or 3D array of Tmin values (nyrs x 366 x nstns)
% Tmaxall..........2D or 3D array of Tmax values (nyrs x 366 x nstns)
% lat..............1D vector of latitudes for all stations (1 x nstns)
%
%Output:
% LFMTX............Matrix of leaf out dates (nyrs x 4 x nstns)
%                  (Ordered as [mean plant1 plant2 plant3])
% BLMTX............Matrix of bloom index dates (nyrs x 4 x nstns)
%                  (Ordered as [mean plant1 plant2 plant3])
% LSTFRZMTX........Matrix of last freeze dates (nyrs x 4 x nstns)
% LFpredMTX........Matrix of average leaf components (nyears x 5 x nstns)
% BLpredMTX........Matrix of average blooming components (nyears x 5 x nstns)

% Version 1.3 Oct, 2013
% NO structural changes.
% Some documentation to code added.
% (Ault)
%
% Version 1.2 Sept, 2013
% 1) renamed output fields for compactness (ault)
% 2) Reordered dimensions of output for consistency with input
% (Ault)
%    
% Version 1.1 August, 2013
% 1) Moved all dependencies to external files (ZM + Ault) 
%
% T. R. Ault (toby.ault at gmail d0t com)
% R. Zurita-Milla (zurita.milla at gmail d0t com) 
% J.A.E. van Gijsel (janaelvira at hotmail d0t com)
% VERSION 1.0  13 April 2013
%
% Based on FORTRAN code provided by M. Schwartz (mds@uwm.edu)
% (VERSION 4.0 1/27/2013 optimized to remove code not needed by SI-x calculations)  
% and validated using data from 6 USA weather stations provided by M.Schwartz
%
% VERSION 2.0  15 April 2013 
% for SIx INDATE=1 so the code has been simplified. 
% the CNT in the whileloop has been modified so that for blooming it does not start at 0
% but at the flowering date 
% added AGDH to the matrix of predictors
% 
% VERSION 3.0 16 April 2013
% added the values of individual plants to the output
%
%(NOTE THAT LFpredMTX & BLpredMTX are not validated (yet))

[nyears,ndays,nsites]=size(Tminall);
% Initialize arrays
LFMTX=nan(nyears,nsites,4);
BLMTX=LFMTX;

npred=5; % Number of predictors

% Matrices that predictor variables will be stored in:
LFpredAllSites=nan(nyears,nsites,npred);
BLpredAllSites=nan(nyears,nsites,npred);
LSTFRZAllSites=nan(nyears,nsites);

%Set value of base temperature for GDH calculations
BASET=31; % base temperature in Fahrenheit = ~0 centigrade
daystop=240;
frzval=28;

%Loop through sites
for s=1:nsites;
    
    %Loop through years
    for yyy=1:nyears
        %%     Check and fill missing values
        % (fortran style)
        MAXNEW=squeeze(Tmaxall(yyy,:,s));
        MINNEW=squeeze(Tminall(yyy,:,s));
        MAXARRY=MAXNEW(1:daystop);
        MINARRY=MINNEW(1:daystop);
        FLAGM=0;
        
        for MM=1:30:211;
            START=MM;
            END=MM+29;            
            %Set quantities used in calculations belo to zero
            ZERMAX=0;CNTMAX=0;AVGMAX=0;ZERMIN=0;CNTMIN=0;AVGMIN=0;
            
            for I=START:END
                if isfinite(MAXARRY(I)) || (MAXARRY(I) > -99 && MAXARRY(I) < 125);
                    if MAXARRY(I) == 0;
                        ZERMAX=ZERMAX+1;
                    end
                    CNTMAX=CNTMAX+1;
                    AVGMAX=AVGMAX+MAXARRY(I);
                end;
                if isfinite(MINARRY(I)) || (MINARRY(I) > -99 && MINARRY(I) < 125);
                    if MINARRY(I) == 0;
                        ZERMIN=ZERMIN+1;
                    end
                    CNTMIN=CNTMIN+1;
                    AVGMIN=AVGMIN+MINARRY(I);
                end
            end
            if CNTMAX < 20 || CNTMIN < 20; 
                FLAGM=1;
            end
            if ZERMAX > 10 || ZERMIN > 10; 
                FLAGM=1;
            end
            if FLAGM ~=1
                AVGMAX=AVGMAX/CNTMAX;
                AVGMIN=AVGMIN/CNTMIN;
                for J=START:END
                    if isnan(MAXARRY(J)) || MAXARRY(J) < -99 || MAXARRY(J) > 125; 
                        MAXARRY(J)=AVGMAX; 
                    end
                    if isnan(MINARRY(J)) || MINARRY(J) < -99 || MINARRY(J) > 125; 
                        MINARRY(J)=AVGMIN;
                    end
                end
            end
        end
        
        % Calculate daylength
        DAYLEN=calc_daylen(daystop,latitude(s));

        %%    Check to see if data is ok, otherwise get another year
        if FLAGM == 1
            LSTFRZ=NaN;LFSINDX=NaN;BLSINDX=NaN;
            LFDATE=[NaN,NaN,NaN];BLDATE=LFDATE;LFpred=nan(3,5);BLpred=LFpred;
        else
            
            % Calculate last 28F freeze date
            LSTFRZ=NaN;
            
            % in FORTRAN: for PPP=1:210; if MINARRY(PPP) <= frzval;
            % LSTFRZ=PPP;end;end;
            % In Matlab:
            LSTFRZ=find(MINARRY<=frzval,1,'last');
            if isempty(LSTFRZ);
                LSTFRZ=NaN;
            end

            % Calculate LEAF, BLOOM, and SINDEX dates
            STRDAT=1;
            LFDATE=[NaN,NaN,NaN];BLDATE=LFDATE;LFpred=nan(3,5);BLpred=LFpred;
            for PLANT=1:3
                EVENT=1;
                [LFDATE(PLANT), LFpred(PLANT,:)]=leaf(MAXARRY,MINARRY,DAYLEN,BASET,STRDAT,EVENT,PLANT);
                EVENT=3;
                if ~any(isnan(LFDATE(PLANT)));
                    [BLDATE(PLANT),BLpred(PLANT,:)]=leaf(MAXARRY,MINARRY,DAYLEN,BASET,LFDATE(PLANT),EVENT,PLANT);
                end
            end
            if all(isfinite(LFDATE)); % all leafing dates .ne. NaN/inf
                LFSINDX=round(mean(LFDATE)); 
                LFpredAllSites(yyy,s,:)=mean(LFpred);
            else
                LFSINDX=NaN;
            end
            if all(isfinite(BLDATE)); % all blooming dates .ne. NaN/inf
                BLSINDX=round(mean(BLDATE)); %round
                BLpredAllSites(yyy,s,:)=mean(BLpred);
            else
                BLSINDX=NaN;
            end
        end
        LFMTX(yyy,s,1)=LFSINDX;
        LFMTX(yyy,s,2:4)=LFDATE';
        
        BLMTX(yyy,s,1)=BLSINDX;
        BLMTX(yyy,s,2:4)=BLDATE';
        
        LSTFRZAllSites(yyy,s,1)=LSTFRZ;
        
    end
end

LF=squeeze(permute(LFMTX,[1 3 2]));
BL=squeeze(permute(BLMTX,[1 3 2]));
LSTFR=squeeze(permute(LSTFRZAllSites,[1 3 2]));
LFpred=squeeze(permute(LFpredAllSites,[1 3 2]));
BLpred=squeeze(permute(BLpredAllSites,[1 3 2]));


end