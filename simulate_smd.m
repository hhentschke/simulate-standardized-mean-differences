function simulate_smd(simDs)
% ** function simulate_smd(simDs)
% 'computations of standardized mean differences (smd) from simulated data'
% Please see the documentation for an introduction/help and
% template_call_simulate_smd.m for an explanation of input parameters.
% 
% -------------------------------------------------------------------------
% simulate_smd Version 1.0, April 2018
% Code by Harald Hentschke (University Hospital of Tübingen) 
% 
% Acknowledgements:
% - The code resulted from discussions and paper-in-progress with Rainer
%   Duesing (University of who Osnabrueck) who brought up the issue of bias
%   correction for Hedges's g for dependent data
% - Function fast_corr by Elliot Layden
%   https://de.mathworks.com/matlabcentral/fileexchange/63082-fast-corr
% - Function progressbar by Steve Hoelzer
%   https://de.mathworks.com/matlabcentral/fileexchange/6922-progressbar
% - Function pvpmod by Ulrich Egert
% -------------------------------------------------------------------------


% ----------- precomputations ----------
% the order of parameters = the dimensions of main results variables
% smdEstMn and ciCoverage along which computed values are saved (strings
% must correspond to field names of simDs!)
simDs.paramPointEstim={'nSample';'effectSize';'sRatio';'corrVal'};
% convert to categorical, using itself as valueset
simDs.paramPointEstim=categorical(simDs.paramPointEstim,simDs.paramPointEstim);
% the order of parameters for plotting, to be set by the user via the GUI -
% by default same as above
simDs.paramPointEstimPlotOrder=simDs.paramPointEstim;
% values of the two parameters which have to be fixed for the plots, and
% their indexes into the corresponding fields of simDs
simDs.plotParFixedVal=[NaN NaN];
simDs.plotParFixedValIx=[NaN NaN];
% same for ci
simDs.paramCi=cat(1,simDs.paramPointEstim,{'ciFormula';'biasFac'});  
simDs.paramCi=categorical(simDs.paramCi,simDs.paramCi);
simDs.paramCiPlotOrder=simDs.paramCi;
% determine number of cases of each parameters to be tested:
% - effect size
numEffectSize=numel(simDs.effectSize);
% - variance ratio
numSRatio=numel(simDs.sRatio);
% - sample size
numNSample=numel(simDs.nSample);
% - correlation between groups
numCorrVal=numel(simDs.corrVal);
% - types of CI
numTypeCi=numel(simDs.ciFormula);
% - types of bias correction
numTypeBiasCorrect=numel(simDs.biasFac);
% determine whether a noncentral CI is to be computed
doComputeNoncentral=false;
for k=1:numTypeCi
  if contains(func2str(simDs.ciFormula(k).fun),'noncentral','IgnoreCase',true)
    doComputeNoncentral=true;
  end
end
if doComputeNoncentral
  warndlgH=warndlg('Computing noncentral confidence intervals will be *extremely* time-consuming');
else
  % set up noncentrality parameter as empty matrix 
  ncPar=[];
  warndlgH=[];
end

% compute explicit values of means, variances and standard deviations of
% test cases given user input (fields .m, .s and .sd, respectively)
simDs=popParFromSmd(simDs);

% put out some information on current test set 
numCombinedParams=numEffectSize*numSRatio*numNSample*numCorrVal;
disp(['**** ' mfilename])
disp([int2str(numCombinedParams) ' combinations of parameters'])
% given that the code below will loop over all parameters except
% simDs.effectSize compute the memory requirement of the simulated raw data
% % §§ this info is totally outdated, adapt to most recent changes including
% % ncp or get rid of it altogether
% disp(['simulated raw data will consume at least ' ...
%   num2str(numEffectSize*max(simDs.nSample)*simDs.numTestCase*8/2^20,'%4.0f') ...
%   ' Mb for runs with largest sample size'])
% for progressbar
cumNumNSample=cumsum(simDs.nSample);

% compute actual values of bias correction factors
for k=1:numTypeBiasCorrect
  simDs.biasFac(k).val=simDs.biasFac(k).fun(simDs.df);
end
% for the computations below it is advantageous to have all bias
% correction factors in one matrix
biasFacMatrix=cat(1,simDs.biasFac.val)';

% critical z value corresponding to alpha
zCrit=norminv(1-simDs.alpha/2);

% results, preallocated:
if simDs.useGPU
  % - means of standardized mean differences, estimate
  smdEstMn=nan([numNSample,numEffectSize,numSRatio,numCorrVal],'gpuArray');
  % - coverage of confidence interval
  ciCoverage=nan([numNSample,numEffectSize,numSRatio,numCorrVal,numTypeCi,numTypeBiasCorrect],'gpuArray');
else
  % - estimated means of standardized mean differences (4D variable)
  smdEstMn=nan([numNSample,numEffectSize,numSRatio,numCorrVal]);
  % - coverage of confidence interval (6D variable)
  ciCoverage=nan([numNSample,numEffectSize,numSRatio,numCorrVal,numTypeCi,numTypeBiasCorrect]);
end

% ----------- the works ----------
% set state and type of random number generator
rng(simDs.rngSeed,simDs.rngType);
% as serious simulations take a while, display a progressbar informing us
% on the progress in the three loops
progressbar('Loop level 1 (sample size)','Loop level 2 (correlations)',...
  'Loop level 3 (variance ratios)')
% in order to keep variable sizes small enough to fit into the GPU's memory
% (usually 1-2 GB) even when the number of test cases is large, loop over
% all parameters except simDs.effectSize
tic
for k=1:numNSample
  progressbar([],0,0) % Reset 2nd & 3rd bar
  % local vars
  n1=simDs.nSample(k);
  n2=n1;
  % factor needed for computation of CI
  tCrit= -tinv(simDs.alpha/2,n1);
  for corrIx=1:numCorrVal
    progressbar([],[],0) % Reset 3rd bar
    for srIx=1:numSRatio
      % generate correlated, normally distributed data:
      % - compute a generic set with
      % i) [nSample(k) * numEffectSize * numTestCase] cases
      % ii) means of zero
      % iii) with variance of the marginal distribution at unity and
      % non-diagonal elements of current correlation value
      d=mvnrnd([0 0],[1 simDs.corrVal(corrIx); simDs.corrVal(corrIx) 1],...
        simDs.numTestCase*n1*numEffectSize);
      % split up and reshape
      if simDs.useGPU
        d1=gpuArray(reshape(d(:,1),[n1,numEffectSize,simDs.numTestCase]));
        d2=gpuArray(reshape(d(:,2),[n1,numEffectSize,simDs.numTestCase]));
      else
        d1=reshape(d(:,1),[n1,numEffectSize,simDs.numTestCase]);
        d2=reshape(d(:,2),[n1,numEffectSize,simDs.numTestCase]);
      end
      clear d
      % set current sd and means (correlation will remain the same)
      d1=d1*simDs.sd(srIx,1)+permute(simDs.m(:,1,srIx),[3 1 2]);
      d2=d2*simDs.sd(srIx,2)+permute(simDs.m(:,2,srIx),[3 1 2]);
      
      % compute a few helper variables needed frequently:
      m1=mean(d1,1);
      s1=var(d1,0,1);
      m2=mean(d2,1);
      s2=var(d2,0,1);
      
      % compute uncorrected value of chosen standardized mean difference
      es=simDs.smdFun(m1,m2,s1,s2);
      % store
      smdEstMn(k,:,srIx,corrIx)=mean(es,3);
      % multiply by the diverse correction factors (including none) and
      % permute; size of es is now 
      % [numTypeBiasCorrect,numEffectSize,simDs.numTestCase]
      es=es.*biasFacMatrix(k,:)';
      % if noncentrality parameter is to be computed, compute covariances
      % before reshaping d1 and d2
      if doComputeNoncentral
        xyCov=sum((d1-m1).*(d2-m2)/(n1-1));
      else
        xyCov=nan;
      end
      % we need correlations between matching columns for the computation
      % of approximate ci. Compute these using Elliot Layden's fast_corr,
      % which is a definite time-saver over the standard corr (we need to
      % reshape d1 and d2 to 2D for fast_corr to work)
      d1=reshape(d1,[n1,numEffectSize*simDs.numTestCase]);
      d2=reshape(d2,[n1,numEffectSize*simDs.numTestCase]);
      xyCorr=fast_corr(d1,d2);
      % reshape back
      xyCorr=reshape(xyCorr,[1 numEffectSize simDs.numTestCase]);
      % compute noncentrality parameter?
      if doComputeNoncentral
        ncPar=computeNoncentralPar(simDs,s1,s2,m1,m2,n1,xyCorr);
      end
      % compute CI(s) and coverage
      for ciIx=1:numTypeCi
        % ci
        ci=simDs.ciFormula(ciIx).fun(es,s1,s2,n1,n2,xyCorr,xyCov,tCrit,zCrit,ncPar);
        % ci coverage
        cic=computeCiCoverage(ci,simDs.effectSize,simDs.numTestCase);
        % note: in the noncentral case, CIs are computed independently of
        % the point estimate (es), so any bias correction applied to the
        % point estimate will not percolate down to ci in that case. This
        % means that variable cic will have only one row, so we have to set
        % the 6th dim indexes of NaN-preallocated variable ciCoverage
        % explicitly here
        ciCoverage(k,:,srIx,corrIx,ciIx,1:size(cic,1))=permute(cic,[3 2 4 5 6 1]);
      end
      progressbar([],[],srIx/numSRatio);
    end
    progressbar([],corrIx/numCorrVal,[]);
  end
  % larger sample sizes require more time, so reflect that in progressbar
  progressbar(cumNumNSample(k)/cumNumNSample(end));
  % after first run of outermost loop delete warning
  if ~isempty(warndlgH) && isgraphics(warndlgH)
    delete(warndlgH)
  end
end
% gather
if simDs.useGPU
  smdEstMn=gather(smdEstMn);
  ciCoverage=gather(ciCoverage);
end
% store & disp timing info
simDs.simDurationSeconds=toc;
disp(['simulations done after ' int2str(round(simDs.simDurationSeconds)) ' seconds']);

% after all's done attach the two results variables to simD and save
simDs.smdEstMn=smdEstMn;
simDs.ciCoverage=ciCoverage;
save([simDs.outDir 'simulate_smd_' simDs.tag datestr(now,30) '.mat'],'simDs');
disp('data saved')


% --------------------- LOCAL FUNCTIONS -----------------------------------
function ncPar=computeNoncentralPar(simDs,s1,s2,m1,m2,n1,xyCorr)
% ** function ncPar=computeNoncentralPar(simDs,s1,s2,m1,m2,n1,xyCorr)
% computes the noncentrality parameter for a large set of simulated data
numNcpVal=3;
numEffectSize=numel(simDs.effectSize);
numTestCase=simDs.numTestCase;
% preallocate container for noncentrality parameter
ncPar=nan([2,numEffectSize,simDs.numTestCase]);
% t statistic
tst=(m1-m2)./(sqrt((s1+s2-2*xyCorr.*sqrt(s1.*s2))./n1));
% unfortunately, in case tst has been computed via the GPU it needs to be
% converted to double because none of the noncentral functions in Matlab
% can deal with gpuArrays
tst=gather(tst);
% reshape into 1D array such that t values in columns stay together
tst=permute(tst,[3 2 1]);
tst=tst(:);
% find minimal and maximal T value
minT=min(tst);
maxT=max(tst);
% determine ncp values of these extrema (enlarge CI slightly to avoid
% border effects)
ncpMinT=ncpci(minT,'t',n1-1,'confLevel',1-simDs.alpha*.99,'prec',simDs.ncpPrecision)';
ncpMaxT=ncpci(maxT,'t',n1-1,'confLevel',1-simDs.alpha*.99,'prec',simDs.ncpPrecision)';
ncpLim=[ncpMinT(1) ncpMaxT(2)];
% set up initial full t-ncp parameter space
[tBag,ncpRange]=meshgrid(tst,linspace(ncpLim(1),ncpLim(2),numNcpVal));
p=nctcdf(tBag,n1-1,ncpRange);
% p thresholds
threshP=simDs.alpha/2 * [-1 1] + [1 0];
% ncpString={'lower','upper'};
tBagCenter=tBag(2:end-1,:);
prec=simDs.ncpPrecision;
for ncpIx=1:2
  % disp(['computing noncentral parameter for ' ncpString{ncpIx} ' CI...'])
  % set up initial parameters
  curP=p;
  curNcpRange=ncpRange;
  % current ncp step size
  deltaNcp=diff(curNcpRange(1:2,1));
  nIter=0;
  while deltaNcp>prec
    tmpLogArr=curP>=threshP(ncpIx);
    tmpIx=tmpLogArr & circshift(~tmpLogArr,-1);
    curNcpRange=(curNcpRange(tmpIx)+linspace(0,1,numNcpVal)*deltaNcp)';
    deltaNcp=diff(curNcpRange(1:2,1));
    curP=cat(1,...
      curP(tmpIx)',...
      nctcdf(tBagCenter,n1-1,curNcpRange(2:end-1,:)),...
      curP(circshift(tmpIx,1))');
    nIter=nIter+1;
  end
  %   disp(['specified precision reached after ' int2str(nIter) ' iterations'])
  % after desired precision has been reached, determine final value
  % as the mean of the interval embracing the real value
  tmpLogArr=curP>=threshP(ncpIx);
  tmpIx=tmpLogArr & circshift(~tmpLogArr,-1);
  ncPar(ncpIx,:,:)=permute(reshape(curNcpRange(tmpIx)+deltaNcp/2,[numTestCase,numEffectSize]),[3 2 1]);
end
