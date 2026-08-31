function KMZ_RFF_evaluate_main_std_vs_unstd(trnwin, nSim, gamma, stdize, demean, CVType)
% KMZ_RFF_EVALUATE_MAIN_STD_VS_UNSTD Evaluate and produce exhibits for RFF std vs unstd
%
%   Runs the exhibit-generation function `rffexhibits_function_CV` 
%   for both RFF standardization settings (1 and 0) across the provided 
%   training windows.
%
%   Syntax:
%       KMZ_RFF_evaluate_main_std_vs_unstd(trnwin, nSim, gamma, stdize, demean, CVType)
%
%   Inputs:
%       trnwin - (numeric vector) Training window sizes (e.g., 12, 60, 120).
%       nSim   - (numeric scalar) Number of simulations (kept for signature consistency).
%       gamma  - (numeric scalar) RFF gamma parameter.
%       stdize - (numeric scalar) 1 if predictors were standardized, 0 otherwise.
%       demean - (numeric scalar) 1 if predictors were demeaned, 0 otherwise.
%       CVType - (string/char) Cross-validation type ('LOOCV' or 'OSACV').
%
%   Dependencies:
%       rffexhibits_function_CV.m

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
% Run exhibits for RFF_stdize = 0 then 1
for stdizeRFFs = [0, 1]
    fprintf('Evaluating CV metrics for RFF_std = %d...\n', stdizeRFFs);

    for idx = 1:numel(trnwin)
        thisTrn = trnwin(idx);
        fprintf('  -> Processing training window T = %d\n', thisTrn);

        % Call exhibit generator for this combination
        rffexhibits_function_CV(gamma, thisTrn, stdize, demean, stdizeRFFs, CVType);
    end
end

fprintf('Evaluation complete for %s.\n', CVType);
end