function ci=glassdelta_dep_ci_Bonett(es,s1,s2,n1,n2,xyCorr,xyCov,tCrit,zCrit,ncPar)
% ** function ci=glassdelta_dep_ci_Bonett(es,s1,s2,n1,n2,xyCorr,xyCov,tCrit,zCrit,ncPar)
% computes ci of Glass's delta for dependent data described by Bonett
% (2015).

% NOTE: this is one in a series of functions computing confidence intervals
% from large 3D sets of precomputed means, variances etc. These functions
% i) are supposed to run as fast as possible as they will called many times
% within loops, and 
% ii) need to have identical input arguments as they will be used
% interchangeably (that is, called via function handles).
% Hence,  
% i) varargin and any error check whatsoever have been avoided, and 
% ii) there are some unused input arguments which are, however, used by
% other functions in the series.

df=n1-1;
% - variance of difference scores
sD=s1+s2-2*xyCorr.*sqrt(s1.*s2);
% - se (formula 11)
se=sqrt(es.^2./(2*df) + sD./(s1.^2.*df));
% - ci (note usage of zCrit instead of tCrit!)
ci=cat(4,es-zCrit.*se,es+zCrit.*se);
