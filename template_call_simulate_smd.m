% This is the template of a script defining struct simDs (short for
% 'simulation data set') and running function simulate_smd (short for
% 'computations of standardized mean differences (smd) from simulated
% data'). Change according to your needs.

% type of standardized mean difference (smd)
simDs.name='Hedges''s g';
% shortcut of the above
simDs.tag='hedgesg';
% handle to function computing smd
simDs.smdFun=@hedgesg_dep;
% types of confidence intervals (CI); .fun must be a function handle
% NOTES: 
% i) functions computing CI via noncentral distribution functions MUST
% contain the char array 'noncentral'
% ii) computing noncentral CIs takes an awfully long time
simDs.ciFormula=[];
simDs.ciFormula.fun=@hedgesg_dep_ci_standard;
simDs.ciFormula.name='traditional';
simDs.ciFormula(2).fun=@hedgesg_dep_ci_Bonett;
simDs.ciFormula(2).name='Bonett';
simDs.ciFormula(3).fun=@hedgesg_dep_ci_noncentral;
simDs.ciFormula(3).name='noncentral';
% in case of a noncentral CI specify precision of the noncentrality
% parameter (the smaller the value, the longer it takes)
simDs.ncpPrecision=1e-6;

% range of effect sizes (smd)
simDs.effectSize=[0 0.3 0.6 1.2 2.4];
% range of variance ratios s1/s2 to test
simDs.sRatio=[1 1.5 2];
% define mean of second group
simDs.m2=1;
% define variance of second group
simDs.s2=1;
% correlations
simDs.corrVal=0:0.3:0.9; % Bonett's 2015 set
% number of samples per group
simDs.nSample=[5:10 12:2:20 25 30 40]; % RD and HH's set for paper
% degrees of freedom
simDs.df=simDs.nSample-1;
% number of test cases
simDs.numTestCase=100000;
% alpha for CI
simDs.alpha=.05;

% types of bias correction factors; .fun must be function handles
ix=0;
simDs.biasFac=[];
ix=ix+1;
simDs.biasFac(ix).name='none';
simDs.biasFac(ix).fun=@(df) ones(size(df));
ix=ix+1;
simDs.biasFac(ix).name='Hedges, df=n-1';
simDs.biasFac(ix).fun=@(df) 1-(3./(4*df-1));
ix=ix+1;
simDs.biasFac(ix).name='Hedges, df=n_1+n_2-2';
simDs.biasFac(ix).fun=@(df) 1-(3./(4*2*df-1));
ix=ix+1;
simDs.biasFac(ix).name='Bonett';
simDs.biasFac(ix).fun=@(df) sqrt((df-1)./df);

% type of and seed for random number generator
simDs.rngType='simdTwister';
simDs.rngSeed=0;
% if true, use GPU for core computations to speed up computations (works
% only if parallel computing toolbox is installed and proper hardware is
% available (CUDA-enabled nvidia graphics card); also note that with a
% large number of test cases and sample sizes memory demand may be in the
% Gigabyte range, which may be too high for some cards)
simDs.useGPU=false;

% directory for output
simDs.outDir='d:/hh/projects/mes_biasCorrection/rawFig/';

% call the function
simulate_smd(simDs);