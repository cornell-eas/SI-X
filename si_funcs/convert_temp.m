function outT=convert_temp(inT,inunits,outunits)

if inunits=='C' & outunits=='F'
    outT=(9/5)*inT+32;
elseif inunits=='K' & outunits=='F'
    outT=(9/5)*inT-459.67;
elseif inunits=='F' & outunits=='C';
    outT=(inT-32)*5/9;
elseif inunits=='F' & outunits=='K';
    outT=(inT+459.67)*5/9;
end