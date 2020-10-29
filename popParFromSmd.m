function simDs=popParFromSmd(simDs)
% ** function simDs=popParFromSmd(simDs)
% computes explicit values of means and variances of test cases, given
% user-specified values of 
% - standardized mean difference (smd)
% - variance ratios
% - m2
% - s2
% The sets the variances to fixed values and adjusts the means according to
% specifications of the smd

numEsVal=numel(simDs.effectSize);
numSRatio=numel(simDs.sRatio);
% variances and standard deviations, one row per variance ratio
simDs.s=simDs.s2*[simDs.sRatio(:) ones(numSRatio,1)];
simDs.sd=sqrt(simDs.s);
% simDs.m is a 3D variable: rows=different smds, columns=groups,
% slices=different variance ratios. The first column generated below will
% be overwritten
simDs.m=repmat(simDs.m2,[numEsVal 2 numSRatio]);
% compute required values of second column:
switch simDs.tag
  case 'hedgesg'
    simDs.m(:,1,:)=simDs.m(:,2,:)+simDs.effectSize'.*permute(sqrt(mean(simDs.s,2)),[2 3 1]);
  case 'glassdelta'
    simDs.m(:,1,:)=simDs.m(:,2,:)+simDs.effectSize'.*permute(simDs.sd(:,1),[2 3 1]);
  otherwise
    error('bad simDs.tag')
end