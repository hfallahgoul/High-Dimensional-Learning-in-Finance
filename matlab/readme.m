% =========================================================================
% REPLICATION CODE: HIGH-DIMENSIONAL LEARNING IN FINANCE
% =========================================================================
% 
% This repository contains the replication code for Section 3.5.1 of the 
% paper "High-Dimensional Learning in Finance" by Hasan Fallahgoul (2026).
% 
% -------------------------------------------------------------------------
% OVERVIEW
% -------------------------------------------------------------------------
% The code contained in this root directory executes the Cross-Validation 
% (CV) exercises (LOOCV and OSACV) alongside the Oracle procedure. Running 
% the main script will automatically generate all the necessary results, 
% tables, and figures required to replicate the findings in Section 3.5.1 
% of the paper.
% 
% -------------------------------------------------------------------------
% HOW TO RUN
% -------------------------------------------------------------------------
% To run the full pipeline, execute the main script from your MATLAB 
% command window:
% 
%     run_all
% 
% This master script will sequence through the LOOCV, OSACV, and Oracle 
% procedures, handling all intermediate data generation and final exhibit 
% outputs.
% 
% -------------------------------------------------------------------------
% PERFORMANCE AND EXPECTED RUN TIMES
% -------------------------------------------------------------------------
% Please note: The full replication is highly computationally intensive 
% and time-consuming. 
% 
% By default, the paper's results are based on 1,000 simulations. You can 
% perform a quick structural test of the code by changing the simulation 
% parameter to nSim = 1 inside run_all.m before running it. To reproduce 
% the exact results from the paper, you must ensure nSim = 1000.
% 
% Below are the expected execution times for part 1 on standard hardware for a 
% training window of T = 12 using nSim = 1:
% 
%     LOOCV:  750 seconds
%     OSACV:  80 seconds
%     Oracle: 70 seconds
% 
% (Note: The code requires MATLAB Parallel Computing Toolbox, as the scripts 
% utilize parfor loops to distribute the simulation workload).
% 
% -------------------------------------------------------------------------
% ACKNOWLEDGEMENTS
% -------------------------------------------------------------------------
% Base Codebase:
% This codebase was built on top of the original replication code for the 
% following paper:
% KELLY, B., MALAMUD, S. and ZHOU, K. (2024), The Virtue of Complexity in 
% Return Prediction. J Finance, 79: 459-503. https://doi.org/10.1111/jofi.13298
% 
% Special Thanks:
% We gratefully acknowledge the assistance of Daniel Buncic in 
% parameterising several features of the original Kelly et al. replication 
% code for testing and adaptation purposes.