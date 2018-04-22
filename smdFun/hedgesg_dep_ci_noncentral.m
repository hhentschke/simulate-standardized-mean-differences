function ci=hedgesg_dep_ci_noncentral(es,s1,s2,n1,n2,xyCorr,xyCov,tCrit,zCrit,ncPar)
% ** function ci=hedgesg_dep_ci_noncentral(es,s1,s2,n1,n2,xyCorr,xyCov,tCrit,zCrit,ncPar)
% computes ci of Hedges's g for dependent data based on the noncentral t
% distribution as described in Algina & Keselman 2003

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

% formula (9)
ci=ncPar.*sqrt((2*s1+2*s2-4*xyCov)./(n1*(s1+s2)));
ci=permute(ci,[4 2 3 1]);