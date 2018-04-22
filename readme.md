# Computation and visualization of standardized mean differences (smd) from simulated data

This is a project written in Matlab for the large-scale simulation of pairs of repeated-measures data (aka paired, correlated, matched data). The underlying population data can be defined by the user in terms of effect size (=standardized mean difference between the groups), variance ratio, correlation between the groups, and sample size. From the simulated data both point and interval estimates (confidence intervals, CI) of standardized mean differences like e.g. Hedges's g are computed. The results can be visualized with a graphical user interface.

The motivation for the project was to test, across a wide parameter space including small sample sizes 

1. various bias correction factors for the point estimates
2. diverse formulae for CI, specifically comparing approximate to exact CI
3. whether biased or unbiased point estimates are better for the construction of approximate CI.

The code results from discussions (and a paper-in-progress) with Rainer Duesing (University of  Osnabrueck) who brought up the issue of bias correction for Hedges's g for dependent data.

### Some relevant literature
* Bonett, D.G. (2015). Interval estimation of standardized mean differences in paired-samples designs. J. Educ. Behav. Stat. 20, 1–11.
* Cumming, G. (2012). Understanding the new statistics: Effect sizes, confidence intervals, and meta-analysis. (New York: Routledge).

### Technical notes
* Statistics and Machine Learning Toolbox is required.
* The code makes frequent use of the new automatic array expansion as introduced in Matlab Release 2016b, so the code **WILL NOT WORK WITH MATLAB RELEASES R2016a AND LOWER!**

## Quick guide to major files/directories

* template_call_simulate_smd.m - a script defining struct simDs (short for 'simulation data set'). The fields of simDs hold the population parameters and govern the computations

* simulate_smd - main function generating the test data and computing point estimates and CI of standardized mean differences, as well as CI coverage. The function appends the results of the computations to struct simDs mentioned above and saves it at a user-specified location

* /smdFun - functions for the diverse types of standardized mean differences and their CI

* /gui - code for a visualization of the results files;  simulate_smd_plotControlGUI.m opens up a small GUI and generates customizable plots of the results as well as a summary plot of CI coverage

* /accessory - contains additionally required code files, among them some contributed by others (see Acknowledgements)

## Acknowledgements:
* Function [fast_corr](https://de.mathworks.com/matlabcentral/fileexchange/63082-fast-corr) by Elliot Layden
* Function [progressbar](https://de.mathworks.com/matlabcentral/fileexchange/6922-progressbar) by Steve Hoelzer

## Limitations
* documentation is sparse
* functions for Glass's delta have not yet been thoroughly tested
* so far, very few safeguards against user interaction with the GUI that is outside the envisaged workflow (e.g. changing plot parameters before loading data will produce an error)
