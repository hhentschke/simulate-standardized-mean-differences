function ci=hedgesg_dep_ci_standard(es,s1,s2,n1,n2,xyCorr,xyCov,tCrit,zCrit,ncPar)
% ** function ci=hedgesg_dep_ci_standard(es,s1,s2,n1,n2,xyCorr,xyCov,tCrit,zCrit,ncPar)
% computes 'traditional' ci of Hedges's g for dependent data described in
% e.g. Kline (2004) and Nakagawa & Cuthill (2007)

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

% - se
se=sqrt((2-2*xyCorr)./n1 + es.^2./(2*n1-2));
% - ci
ci=cat(4,es-tCrit.*se,es+tCrit.*se);