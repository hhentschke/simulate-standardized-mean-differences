function simulate_smd_plot(handles,doCiCovSummary)
% ** function simulate_smd_plot(handles,doCiCovSummary)

% ------------------- preliminaries ---------------------------------------
% if doCiCovSummary is true, a boxplot summarizing CI coverage across
% parameters space as represented in the data set is generated
if nargin<=1 
  doCiCovSummary=false;
end
% update handles
handles=guidata(handles.guiFigure);
% local copy of simDs ciCoverage
simDs=handles.simDs;
% number of test cases of each parameter
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
% redundant, but handy:
[n1,n2,n3,n4]=size(simDs.smdEstMn);
% convert parameter names to axis or other labels
simDs.paramPointEstimLabels=cell(size(simDs.paramPointEstim));
for k=1:numel(simDs.paramPointEstim)
  switch char(simDs.paramPointEstim(k))
    case 'nSample'
      simDs.paramPointEstimLabels{k}='sample size';
    case 'effectSize'
      simDs.paramPointEstimLabels{k}='effect size';      
    case 'sRatio'
      simDs.paramPointEstimLabels{k}='\sigma_1/\sigma_2';
    case 'corrVal'
      simDs.paramPointEstimLabels{k}='corr. value';      
    otherwise
      error('bad value of simDs.paramPointEstim')
  end
end
% before they may be permuted to allow for multiplication using automatic
% array expansion, stuff all bias correction factors in one matrix
biasFacMatrix=cat(1,simDs.biasFac.val)';

% according to values in simDs.paramPointEstimPlotOrder and
% simDs.plotParFixedValIx
% - extract the portion of data to be plotted from the full data
smdEstMn_subset=permute(simDs.smdEstMn,double(simDs.paramPointEstimPlotOrder));
smdEstMn_subset=smdEstMn_subset(:,:,simDs.plotParFixedValIx(1),simDs.plotParFixedValIx(2));
ciCoverage_subset=permute(simDs.ciCoverage,double(simDs.paramCiPlotOrder));
ciCoverage_subset=ciCoverage_subset(:,:,simDs.plotParFixedValIx(1),simDs.plotParFixedValIx(2),:,:);
% - permute and index bias correction factors in the same manner
for k=1:numel(simDs.biasFac)
  % ensure that they're in the correct dimension to start with (must be a
  % column array), replicate, permute and then index
  simDs.biasFac(k).val=repmat(simDs.biasFac(k).val(:),[1 n2 n3 n4]);
  simDs.biasFac(k).val=permute(simDs.biasFac(k).val,double(simDs.paramPointEstimPlotOrder));
  simDs.biasFac(k).val=simDs.biasFac(k).val(:,:,simDs.plotParFixedValIx(1),simDs.plotParFixedValIx(2));
end
% - same with expected effect size values
smdExpected=repmat(simDs.effectSize(:)',[n1 1 n3 n4]);
smdExpected=permute(smdExpected,double(simDs.paramPointEstimPlotOrder));
smdExpected=smdExpected(:,:,simDs.plotParFixedValIx(1),simDs.plotParFixedValIx(2));
% - define x and y axis values and labels
xAx.val=simDs.(char(simDs.paramPointEstimPlotOrder(1)));
xAx.label=simDs.paramPointEstimLabels{double(simDs.paramPointEstimPlotOrder(1))};
yAx.val=simDs.(char(simDs.paramPointEstimPlotOrder(2)));
yAx.label=simDs.paramPointEstimLabels{double(simDs.paramPointEstimPlotOrder(2))};

% ----------- plots of point estimates and correction factors -------------
figure(handles.figHandles(1));
clf
orient landscape
labelscale('scaleFac',1,'fontSz',10,'lineW',1,'markSz',6);

numPlotRow=2;
numPlotCol=max(numTypeBiasCorrect,3);

% surface plot of smd, uncorrected
subplot(numPlotRow,3,1)
[X,Y]=meshgrid(xAx.val,yAx.val);
surf(X,Y,smdEstMn_subset');
axis tight
% set(gca,'zlim',[smdExpected max(smdEstMn_subset(:))*1.005])
xlabel(xAx.label);
ylabel(yAx.label)
zlabel([simDs.name ', uncorrected'])

% line plot of a subset of smd, uncorrected
subplot(numPlotRow,3,2)
plot(xAx.val,smdEstMn_subset,'o-','markersize',4);
nicexyax
hold on
% line(simDs.nSample([1 end]),[1 1]*smdExpected,'linestyle','--','linewidth',2)
% set(gca,'ylim',[smdExpected-.01 max(max(smdEstMn_subset))*1.005])
xlabel(xAx.label);
ylabel([simDs.name ', uncorrected']);
lh=legend(num2str(yAx.val'));
lh.Title.String=yAx.label;
% use this plot to also indicate values of fixed parameters
smarttext({...
  [simDs.paramPointEstimLabels{double(simDs.paramPointEstimPlotOrder(3))} '=' num2str(simDs.plotParFixedVal(1))],...
  [simDs.paramPointEstimLabels{double(simDs.paramPointEstimPlotOrder(4))} '=' num2str(simDs.plotParFixedVal(2))]},...
  0.1,0.85,'fontweight','bold');

% plots of correction factors
subplot(numPlotRow,3,3)
set(gca,'colororder',[0 0 0; .1 1 .2; .3 .7 .3; .8 0 .8],'NextPlot','replacechildren')
plot(simDs.nSample,biasFacMatrix,'s-');
nicexyax
hold on
% line(simDs.nSample([1 end]),[1 1],'linestyle','-','linewidth',2,'color','k')
xlabel('sample size');
ylabel('bias correction factor')
legend({simDs.biasFac.name},'location','south');

% line plots of the estimates of smd relative to the population value
sph=gobjects(numTypeBiasCorrect,1);
for g=1:numTypeBiasCorrect
  sph(g)=subplot(numPlotRow,numPlotCol,numPlotCol+g);
  if ~any(smdExpected)
    % if expected effect size is zero, plot absolute error
    plot(xAx.val,smdEstMn_subset.*simDs.biasFac(g).val-smdExpected,'o-','markersize',4);
    nicexyax
    set(gca,'ylim',[-.1 .1]);
    ylabel('error of point estimate (absolute)')
  else
    plot(xAx.val,100*(smdEstMn_subset.*simDs.biasFac(g).val-smdExpected)./smdExpected,'o-','markersize',4);
    nicexyax
    ylabel('error of point estimate (%)')
  end
  hold on
  line(xAx.val([1 end]),[0 0],'linestyle','--','linewidth',2)
  xlabel(xAx.label);
  title({'Bias correction:', simDs.biasFac(g).name})
end
linkaxes(sph);

% ---------------------- plots of ci coverage -----------------------------
figure(handles.figHandles(2));
clf
orient landscape
labelscale('scaleFac',1,'fontSz',10,'lineW',1,'markSz',6);
numPlotRow=max(numTypeCi,2);
numPlotCol=max(numTypeBiasCorrect,3);
% loop over types of CI
for ciIx=1:numTypeCi
  % loop over bias correction factors
  for g=1:numTypeBiasCorrect
    % line plot of a subset of the coverage of hedges'g' CI
    subplot(numPlotRow,numPlotCol,(ciIx-1)*numPlotCol+g)
    plot(xAx.val,ciCoverage_subset(:,:,:,:,ciIx,g)','o-','markersize',4);
    nicexyax
    hold on
    line(xAx.val([1 end]),[1 1]*(1-simDs.alpha),'linestyle','--','linewidth',2)
    set(gca,'ylim',(1-simDs.alpha)+[-.05 .05])
    xlabel(xAx.label);
    ylabel('CI coverage')
    title({[simDs.ciFormula(ciIx).name '; bias correction:'], simDs.biasFac(g).name})
  end
end
lh=legend(num2str(yAx.val'));
lh.Title.String=yAx.label;

% ---------------------- ci coverage: summary -----------------------------
if doCiCovSummary
  % collect values of ci coverage across parameters effectSize, sRatio and
  % corrVal, and generate a boxplot of these with the values of the remaining
  % three parameters as the grouping variable.
  % Here's the association between dimension and parameter again:
  % [numNSample,numEffectSize,numSRatio,numCorrVal,numTypeCi,numTypeBiasCorrect]
  % Also, convert two of the three grouping vars to categorical to have
  % proper labels in boxplot
  nSampleArr=repmat(simDs.nSample(:),[1,numEffectSize,numSRatio,numCorrVal,numTypeCi,numTypeBiasCorrect]);
  typeCiCat=categorical({simDs.ciFormula.name},{simDs.ciFormula.name})';
  typeCiArr=repmat(permute(typeCiCat,[6 5 4 3 1 2]),[numNSample,numEffectSize,numSRatio,numCorrVal,1,numTypeBiasCorrect]);
  typeBiasCorrectCat=categorical({simDs.biasFac.name},{simDs.biasFac.name})';
  typeBiasCorrectArr=repmat(permute(typeBiasCorrectCat,[6 5 4 3 2 1]),[numNSample,numEffectSize,numSRatio,numCorrVal,numTypeCi,1]);
  
  figure(handles.figHandles(3));
  clf
  orient tall
  boxplot(simDs.ciCoverage(:),{nSampleArr(:),typeCiArr(:),typeBiasCorrectArr(:)},...
    'orientation','horizontal','plotstyle','compact','whisker',10,...
    'FactorGap',[4 2 1],'ColorGroup',typeCiArr(:)); 
  set(gca,'ydir','reverse')
  hold on
  line([1 1]*(1-simDs.alpha),get(gca,'ylim'),'linestyle','--','linewidth',2,...
    'color',[.6 .6 .6])
  xlabel('CI coverage');
  ylabel('parameter combinations');
end