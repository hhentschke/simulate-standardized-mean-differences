function c=computeCiCoverage(ci,popVal,numTestCase)
% ** function c=computeCiCoverage(ci,popVal,numTestCase)
% computes coverage of confidence intervals (CI) from simulated data in
% input variable ci given the population (expected) value popVal. A value
% of 1 corresponds to a coverage of 100%. ci is expected to be 4D with the
% lower and upper values of the CI in the fourth dimension and the number
% of test cases along the third dimension. Specifically, the dimensions of
% ci are
%   [numTypeBiasCorr,numEsVal,numTestCase,(lower/upper)]
% Accordingly, popVal must have dimensions allowing automatic array
% expansion. 

c=sum(ci(:,:,:,1)<=popVal & ci(:,:,:,2)>=popVal,3)/numTestCase;