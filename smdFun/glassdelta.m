function es=glassdelta(m1,m2,s1,s2)
% ** function es=glassdelta(m1,m2,s1,s2)
% computes Glass's delta (uncorrected for bias)

% NOTE: this is one in a series of functions computing point estimates of
% standardized mean differences from large 3D sets of precomputed means,
% variances etc. These functions
% i) are supposed to run as fast as possible as they will called many times
% within loops, and 
% ii) need to have identical input arguments as they will be used
% interchangeably (that is, called via function handles).
% Hence,  
% i) varargin and any error check whatsoever have been avoided, and 
% ii) there may be some unused input arguments which are, however, used by
% other functions in the series.

es=(m1-m2)./sqrt(s1);
