function KMZ_RFF_predictions_main_std_vs_unstd(trnwin, nSim, gamma, stdize, demean, CVType)
% KMZ_RFF_PREDICTIONS_MAIN_STD_VS_UNSTD Run CV Task 1 for RFF std vs unstd
%
%   Executes the RFF prediction cross-validation pipeline for both RFF 
%   standardization settings (0 and 1). For each setting, it executes 
%   the simulations in parallel.
%
%   Syntax:
%       KMZ_RFF_predictions_main_std_vs_unstd(trnwin, nSim, gamma, stdize, demean, CVType)
%
%   Inputs:
%       trnwin - (numeric vector) Training window sizes (e.g., 12, 60, 120).
%       nSim   - (numeric scalar) Number of simulations (e.g., 1000).
%       gamma  - (numeric scalar) RFF gamma parameter.
%       stdize - (numeric scalar) 1 if predictors were standardized, 0 otherwise.
%       demean - (numeric scalar) 1 if predictors were demeaned, 0 otherwise.
%       CVType - (string/char) Cross-validation type ('LOOCV' or 'OSACV').
%
%   Dependencies:
%       KMZ_tryrff_v2_function_for_each_sim_CV.m

% --- Default Arguments ---
if nargin < 6, CVType = 'LOOCV'; end
if nargin < 5, demean = 0; end
if nargin < 4, stdize = 1; end
if nargin < 3, gamma = 2; end
if nargin < 2, nSim = 1000; end
if nargin < 1, trnwin = 12; end

% --- Input Validation ---
validateattributes(trnwin, {'numeric'}, {'vector','integer','positive'}, mfilename, 'trnwin');
validateattributes(nSim,   {'numeric'}, {'scalar','integer','positive'}, mfilename, 'nSim');
validateattributes(gamma,  {'numeric'}, {'scalar','positive'}, mfilename, 'gamma');
validateattributes(stdize, {'numeric','logical'}, {'scalar'}, mfilename, 'stdize');
validateattributes(demean, {'numeric','logical'}, {'scalar'}, mfilename, 'demean');

if ~ismember(double(stdize), [0, 1]), error('stdize must be 0 or 1.'); end
if ~ismember(double(demean), [0, 1]), error('demean must be 0 or 1.'); end

% Enforce char vector for validatestring compatibility
CVType = validatestring(char(CVType), {'LOOCV','OSACV'}, mfilename, 'CVType');

% --- Main Execution ---
% Run for both RFF standardization settings: 0 (not standardized) and 1 (standardized)
for stdizeRFFs = [0, 1]

    % Create output directory 
    outDirName = [fullfile(pwd, sprintf('individual-files_stdize_%s_RFFs_%d', CVType, stdizeRFFs)), filesep];

    if ~exist(outDirName, 'dir')
        mkdir(outDirName);
    end

    % Execute RFF ridge regressions in parallel for each training window
    for tt = 1:numel(trnwin)
        thisTrn = trnwin(tt);

        fprintf('\nStarting parallel simulations for RFF_std = %d (T = %d)...\n', stdizeRFFs, thisTrn);
        tic;

        parfor randomSeed = 1:nSim
            KMZ_tryrff_v2_function_for_each_sim_CV(gamma, thisTrn, randomSeed, ...
                stdize, demean, stdizeRFFs, outDirName, CVType);
        end

        elapsedTime = toc;
        fprintf('Completed T = %d (RFF_std = %d) in %.2f seconds.\n', thisTrn, stdizeRFFs, elapsedTime);
    end
end
end