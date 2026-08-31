% RUN_ALL Master Execution Script for KMZ RFF Standardization Comparison
%
% This script reproduces the main results, tables, and figures for section 3.5.1. 
% It executes the simulation, evaluation, and exhibit generation across 
% different Cross-Validation (CV) methods (LOOCV, OSACV) as well as the Oracle procedure.
%
% Instructions: Ensure your current folder in MATLAB is the root of the 
% replication package before running.

clear; clc; close all;
fprintf('Starting execution at: %s\n', char(datetime('now')));

%% 1. Setup Environment
fprintf('\n--- Setting up environment ---\n');

% Reset path to avoid conflicts with local files, then add project folders
addpath(genpath('./KMZ_based_local.functions/'))
addpath(genpath('./functions_CV/'))
addpath(genpath('./functions_oracle/'))

% Safely start parallel pool if one doesn't already exist
start_parpool_with

%% 2. Global Parameters
fprintf('\n--- Initializing Parameters ---\n');

trnwin = 12;       % Training window (T)
nSim   = 1000;     % Number of simulations
gamma  = 2;        % Gamma parameter in Random Fourier Features
stdize = 1;        % Standardization indicator (1 = True)
demean = 0;        % Demean indicator (0 = False)

fprintf('Training Window: %d\nSimulations: %d\nGamma: %d\nStandardize: %d\nDemean: %d\n', ...
    trnwin, nSim, gamma, stdize, demean);

%% 3. Cross-Validation Procedures (LOOCV, OSACV)
cvMethods = ["LOOCV", "OSACV"];

for i = 1:length(cvMethods)
    CVType = cvMethods(i);
    fprintf('\n======================================================\n');
    fprintf(' Processing CV Method: %s \n', CVType);
    fprintf('======================================================\n');
    
    fprintf('[1/3] Running Simulations and Predictions...\n');
    KMZ_RFF_predictions_main_std_vs_unstd(trnwin, nSim, gamma, stdize, demean, CVType);
    
    fprintf('[2/3] Aggregating and Evaluating...\n');
    KMZ_RFF_evaluate_main_std_vs_unstd(trnwin, nSim, gamma, stdize, demean, CVType);
    
    fprintf('[3/3] Creating Exhibits...\n');
    KMZ_RFF_compare_main_std_vs_unstd(trnwin, nSim, gamma, stdize, demean, CVType);
end

%% 4. Oracle Procedure
fprintf('\n======================================================\n');
fprintf(' Processing Oracle Procedure \n');
fprintf('======================================================\n');

fprintf('[1/3] Running Oracle Simulations and Predictions...\n');
KMZ_RFF_predictions_oracle_std_vs_unstd(trnwin, nSim, gamma, stdize, demean);

fprintf('[2/3] Aggregating and Evaluating Oracle metrics...\n');
KMZ_RFF_evaluate_oracle_std_vs_unstd(trnwin, nSim, gamma, stdize, demean);

fprintf('[3/3] Creating Oracle Exhibits...\n');
KMZ_RFF_compare_oracle_std_vs_unstd(trnwin, nSim, gamma, stdize, demean); 

fprintf('\n--- Replication Pipeline Complete at %s ---\n', char(datetime('now')));
fprintf('Please check the output directories for tables and figures.\n');