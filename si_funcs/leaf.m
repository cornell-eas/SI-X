% Function called by calc_si to do most of the heavy living in
% actually calculating spring indices.
%
%Usage:
% [OUTDATE,Xpred]=leaf(MAXARRY,MINARRY,DAYLEN,BASET,INDATE,EVENT,PLANT)
%
% Inputs:
%
%  MAXARRY........Vector of Tmax for a single year/site
%  MINARRY........Vector of Tmax for a single year/site
%  DAYLEN.........Daylength vector for all days corresponding to  MINARRY/MAXARRY
%  BASET.........."Base" temperature from which GDH are calculated
%  INDATE.........Date of "reference" event:
%                     January 1 when first leaf is being calculated
%                     Leaf date when first bloom is being calculated
%  EVENT..........Phenological event to be modeled - 1 for "first
%                 leaf", 3 for "first bloom."
%  PLANT..........Plant species being modeled (1, 2, or 3,
%                 corresponding to lilac, arnold red, or zabelli)
%
% Outputs:
%  OUTDATE.......Day of year (integer) for a given year/site/plant/event
%  Xpred.........State of each of the four predictor values at the
%                time the modeled phenological event occurs.
   
function [OUTDATE,Xpred]=leaf(MAXARRY,MINARRY,DAYLEN,BASET,INDATE,EVENT,PLANT)
    
    ID2=INDATE;
    LAG=zeros(7,1); SYNOP=0; AGDH=0; MDSUM1=0; CNT=INDATE-1; EFLAG=0; Xpred=nan(5,1);

    %Coefficients for Leaf Index:
    Alf=[3.306 13.878 0.201 0.153
         4.266 20.899 0.000 0.248
         2.802 21.433 0.266 0.000];
    

    %Coefficients for Bloom Index: 
    Abl=[-23.934 0.116
         -24.825 0.127
         -11.368 0.096];
     
    %Other constants
    daymax=240;
    
    
    %CALCULATE GDH AND SYNPTIC ACCUMULATIONS
    while 1
        if EFLAG ~= 0; break; end
        if CNT == daymax;
            if EFLAG == 0;OUTDATE=NaN;end;
            break
        end
        CNT=CNT+1;

        %     CHECK FOR MAX-MIN LAG ERRORS
        if CNT >1;
            if(MAXARRY(CNT) < MINARRY(CNT-1));MAXARRY(CNT)=MINARRY(CNT-1);end
            if(MINARRY(CNT) > MAXARRY(CNT-1));MINARRY(CNT)=MAXARRY(CNT-1);end
        end
        
        if MAXARRY(CNT)>=BASET

            %     CALCULATE THE GDH VALUE, AND SYNOPTIC INFO
            GDH=growdh(MAXARRY(CNT),MINARRY(CNT),DAYLEN(CNT),BASET,nan(24,1));

            %     SET ALL LAG VALUES TO DAY 1 VALUES FIRST TIME THROUGH
            if(CNT == 1 && EVENT == 1);
                LAG(1)=GDH;LAG(2)=GDH;
            end
            [DDE2, DD57, SYNFLAG]=synval(LAG,GDH,EVENT);

            %     SET AGDH AND SYNOP ACCUMULATIONS
            if(CNT >=ID2);
                AGDH=GDH+AGDH;
                if(SYNFLAG == 1); SYNOP=SYNOP+1; end
            end

            %     CALCULATE MODEL PREDICTION VALUE, REACHES 1000 WHEN PREDICTED DATE IS ACHIEVED
            if(CNT >=ID2);
                MDS0=CNT-INDATE;
                switch EVENT
                  case 1
                    switch PLANT
                      case 1
                        MDSUM1=(Alf(1,1)*MDS0)+(Alf(1,2)*SYNOP)+(Alf(1,3)*DDE2)+(Alf(1,4)*DD57);
                      case 2
                        MDSUM1=(Alf(2,1)*MDS0)+(Alf(2,2)*SYNOP)+(Alf(2,3)*DDE2)+(Alf(2,4)*DD57);
                      case 3
                        MDSUM1=(Alf(3,1)*MDS0)+(Alf(3,2)*SYNOP)+(Alf(3,3)*DDE2)+(Alf(3,4)*DD57);
                    end
                  case 3
                    switch PLANT
                      case 1
                        MDSUM1=(Abl(1,1)*MDS0)+(Abl(1,2)*AGDH);
                      case 2
                        MDSUM1=(Abl(2,1)*MDS0)+(Abl(2,2)*AGDH);
                      case 3
                        MDSUM1=(Abl(3,1)*MDS0)+(Abl(3,2)*AGDH);

                    end
                end
            else
                MDSUM1=1;
            end
            if(MDSUM1 >= 999.5 && EFLAG == 0);
                Xpred=[MDS0 SYNOP DDE2 DD57 AGDH];
                EFLAG=1;
                switch EVENT
                  case 1
                    switch PLANT
                      case {1,3}
                        OUTDATE=CNT;
                      case 2
                        OUTDATE=CNT+1;
                    end
                  case 3
                    OUTDATE=CNT;
                  otherwise
                    error('Not a valid event.');
                end
            end

            %   LAG VARIABLES SECTION
            LAG(2:7)=LAG(1:6);
            LAG(1)=GDH;
        end
    end
    OUTDATE=round(OUTDATE);
end

