function KMZ_RFF_compare_main_std_vs_unstd(trnwin, nSim, gamma, stdize, demean, CVType)
% KMZ_RFF_COMPARE_MAIN_STD_VS_UNSTD Compare performance for RFF standardized vs unstandardized
%
%   Loads combined results for RFF standardization = 1 and 0, compares
%   performance metrics (R2, SR, ER, vol), and writes summary tables/figures.
%
%   Syntax:
%       KMZ_RFF_compare_main_std_vs_unstd(trnwin, nSim, gamma, stdize, demean, CVType)
%
%   Inputs:
%       trnwin  - (numeric scalar) Training window size.
%       nSim    - (numeric scalar) Number of simulations.
%       gamma   - (numeric scalar) RFF gamma parameter.
%       stdize  - (numeric scalar) 1 if predictors were standardized, 0 otherwise.
%       demean  - (numeric scalar) 1 if predictors were demeaned, 0 otherwise.
%       CVType  - (string/char) Cross-validation type ('LOOCV' or 'OSACV').

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

% Date ranges and file suffix
startDateRange = 1926;
endDateRange   = 2020;
suffix = sprintf('trnwin-%d-gamma-%d-stdize-%d-demean-%d-%d-%d', ...
                 trnwin, gamma, stdize, demean, startDateRange, endDateRange);

% Load parameters (use RFF=1 data dir if available, otherwise GenericSimData)
maxP = 12000;
thisRFF_datadir = [fullfile(pwd, sprintf('individual-files_stdize_%s_RFFs_1', CVType)), filesep];
para_str = sprintf('maxP-%d-trnwin-%d-gamma-%d-stdize-%d-demean-%d-v2', ...
                   maxP, trnwin, gamma, stdize, demean);
save_path = fullfile(thisRFF_datadir, para_str);
filename = fullfile(save_path, 'iSim1.mat');

if exist(filename, "file")
    %load(filename, 'T','nP','nL','Y', 'Plist', 'log_lamlist','dates','lamlist');
    load(filename, 'Plist', 'dates');
end

% Load combined results for RFF_stdize = 1 
combined_data_save_path_RFF_1 = [fullfile(pwd, sprintf('combined_data_RFF_1_%s', CVType)), filesep];
performance_filename_RFF_1 = fullfile(combined_data_save_path_RFF_1, [suffix '.mat']);
if ~exist(performance_filename_RFF_1, 'file')
    error('RFF standardized results file not found: %s', performance_filename_RFF_1);
end
   
dataStruct_RFF_1 = load(performance_filename_RFF_1, ...
    'locev','ER','SR','vol','IR','IRt','alpha','R2',...
    'ERpct','SRpct','volpct','IRpct','IRtpct','alphapct','R2pct','IRstd',...
    'Bnrmbar','timing','pihat','Yprd','lambdaOpt_summary','dfOpt_summary');
    
% Load combined results for RFF_stdize = 0
combined_data_save_path_RFF_0 = [fullfile(pwd, sprintf('combined_data_RFF_0_%s', CVType)), filesep];
performance_filename_RFF_0 = fullfile(combined_data_save_path_RFF_0, [suffix '.mat']);
if ~exist(performance_filename_RFF_0, 'file')
    error('RFF unstandardized results file not found: %s', performance_filename_RFF_0);
end
dataStruct_RFF_0 = load(performance_filename_RFF_0, ...
    'locev','ER','SR','vol','IR','IRt','alpha','R2',...
    'ERpct','SRpct','volpct','IRpct','IRtpct','alphapct','R2pct','IRstd',...
    'Bnrmbar','timing','pihat','Yprd','lambdaOpt_summary','dfOpt_summary');

% --- Plot / output configuration ---
printResultsToExcel = true;
saveFig = false;
printFontSize = 24;
runPerfComps = true; 
figType = "vector";
figPositions = [488.0000  165.8000  709.0000  496.2000];

% x-axis ranges depending on trnwin
switch trnwin
    case 1
        T_xRange = [0:10:50, 11995, 12000]; T_breaks = [51, 11994];
    case 12
        T_xRange = [0:10:50, 990, 1000];    T_breaks = [51, 989];
    case 60
        T_xRange = [0, 5, 10, 195, 200];      T_breaks = [11, 194];
    case 120
        T_xRange = [0, 5, 10, 95, 100];       T_breaks = [11, 94];
    otherwise
        T_xRange = 0:10:50;                   T_breaks = [];
end

shrinkage_to_plot = 1;
perfMetricsToPlot = ["R2", "SR", "ER", "vol"];
c = Plist / trnwin; 
log_lam_legend = "CV-Optimal $\lambda$";
combinedShrinkageAndRFFStdLegend = [log_lam_legend + ", RFF Stdize = 1"; log_lam_legend + ", RFF Stdize = 0"];

% --- Optional: run performance comparison plots ---
if runPerfComps
    for idxPlot = 1:length(perfMetricsToPlot)
        perfMetricStr = perfMetricsToPlot(idxPlot);
        perfMetricVal_RFF_1 = dataStruct_RFF_1.(perfMetricStr); 
        perfMetricVal_RFF_0 = dataStruct_RFF_0.(perfMetricStr);
        
        % Annualise where appropriate
        if any(strcmp(perfMetricStr, ["SR", "IR"]))
            perfMetricVal_RFF_1 = perfMetricVal_RFF_1 .* sqrt(12);
            perfMetricVal_RFF_0 = perfMetricVal_RFF_0 .* sqrt(12);
        end
        
        figure('Color','white','Position',figPositions)
        ax = gca;
        for idxL = shrinkage_to_plot
            p1 = plot(ax, c, perfMetricVal_RFF_1(:,idxL), 'linewidth', 1.5); hold on
            plot(ax, c, perfMetricVal_RFF_0(:,idxL), 'linewidth', 1.5, 'LineStyle', '--', 'Color', p1.Color)
        end
        xlabel('$c$','interpreter','latex')
        
        switch perfMetricStr
            case "ER"
                set(gca, 'fontname', 'TimesNewRoman', 'fontsize', printFontSize, 'ylim', [0, 0.0385])
                isBreakAxis = true;
            case "vol"
                set(gca, 'fontname', 'TimesNewRoman', 'fontsize', printFontSize, 'ylim', [0, min(5, max(max(perfMetricVal_RFF_0)) + 0.1)])
                isBreakAxis = true;
            case "R2"
                set(gca, 'fontname', 'TimesNewRoman', 'fontsize', printFontSize); xlim([0, 50])
                isBreakAxis = false;
                legend(combinedShrinkageAndRFFStdLegend, 'fontsize', printFontSize, 'interpreter', 'latex', 'Location', 'southeast');
            case "SR"
                set(gca, 'fontname', 'TimesNewRoman', 'fontsize', printFontSize, 'ylim', [0, 0.5])
                isBreakAxis = true;
        end
        ytickformat('%.2f')
        
        if isBreakAxis
            set(ax, 'xtick', T_xRange)
            breakxaxis_NB(ax, T_breaks, 0.05);
            % Deal with last 2 labels for T=12
            if trnwin == 12
                ax_children = get(gcf, 'children');
                ax_children(2).XAxis.TickLabels = {'0.9k','1k','0.9k','1k','0.9k','0.9k','1k'};
            end
        end
        
        % Build tables and optionally write to Excel
        R1_Tbl = array2table(perfMetricVal_RFF_1, "RowNames", string(Plist), "VariableNames", perfMetricStr);
        R0_Tbl = array2table(perfMetricVal_RFF_0, "RowNames", string(Plist), "VariableNames", perfMetricStr);
        
        R0_lambda_allT = nanmean(dataStruct_RFF_0.lambdaOpt_summary, 1);
        R0_df_allT     = nanmean(dataStruct_RFF_0.dfOpt_summary, 1);
        R0_Tbl = addvars(R0_Tbl, R0_lambda_allT', R0_df_allT', 'NewVariableNames', ["CV_Opt_Lambda", "DF"]);
        
        R1_lambda_allT = nanmean(dataStruct_RFF_1.lambdaOpt_summary, 1);
        R1_df_allT     = nanmean(dataStruct_RFF_1.dfOpt_summary, 1);
        R1_Tbl = addvars(R1_Tbl, R1_lambda_allT', R1_df_allT', 'NewVariableNames', ["CV_Opt_Lambda", "DF"]);
        
        if printResultsToExcel
            thisOutputFileParentName = sprintf("KMZ_T_%d_RFF_Stdize_Compare_%s_NSim_%d", trnwin, CVType, nSim);
            thisOutputFileName = thisOutputFileParentName + "_" + perfMetricStr + ".xlsx";
            writetable(R1_Tbl, thisOutputFileName, "WriteRowNames", true, "WriteVariableNames", true, "Sheet", sprintf("RFFStdize_1_T_%d", trnwin));
            writetable(R0_Tbl, thisOutputFileName, "WriteRowNames", true, "WriteVariableNames", true, "Sheet", sprintf("RFFStdize_0_T_%d", trnwin));
        end
        
        if saveFig
            this_figname = sprintf("%s_T_%d_%s.eps", perfMetricStr, trnwin, CVType);
            if strcmpi(figType, "vector")
                exportgraphics(gcf, this_figname, 'ContentType', 'vector', 'BackgroundColor', 'none');
            else
                exportgraphics(gcf, this_figname, 'ContentType', 'image', 'BackgroundColor', 'none', 'Resolution', 300);
            end
        end
    end
end

% --- CV summary plots: optimal lambda and DF comparisons ---
R0_lambda_allT = nanmean(dataStruct_RFF_0.lambdaOpt_summary, 1);
R0_df_allT     = nanmean(dataStruct_RFF_0.dfOpt_summary, 1);
R1_lambda_allT = nanmean(dataStruct_RFF_1.lambdaOpt_summary, 1);
R1_df_allT     = nanmean(dataStruct_RFF_1.dfOpt_summary, 1);

% Plot optimal lambda
figure('Color','white','Position',figPositions)
ax = gca;
p1 = plot(ax, c, R0_lambda_allT, 'linewidth', 1.5); hold on
plot(ax, c, R1_lambda_allT, 'linewidth', 1.5, 'LineStyle', '--', 'Color', p1.Color)
xlabel('$c$','interpreter','latex')
set(gcf, 'Position', figPositions);
set(gca, 'fontname', 'TimesNewRoman', 'fontsize', printFontSize)
ytickformat('%.2f')

if isBreakAxis
    set(ax, 'xtick', T_xRange)
    if ~isempty(T_breaks), breakxaxis_NB(ax, T_breaks, 0.05); end
end

if saveFig
    this_figname = sprintf("Lambda_T_%d_%s.eps", trnwin, CVType);
    if strcmpi(figType, "vector")
        exportgraphics(gcf, this_figname, 'ContentType', 'vector', 'BackgroundColor', 'none');
    else
        exportgraphics(gcf, this_figname, 'ContentType', 'image', 'BackgroundColor', 'none', 'Resolution', 300);
    end
end

% Plot optimal DF
figure('Color','white','Position',figPositions)
ax = gca;
p1 = plot(ax, c, R0_df_allT, 'linewidth', 1.5); hold on
plot(ax, c, R1_df_allT, 'linewidth', 1.5, 'LineStyle', '--', 'Color', p1.Color)
xlabel('$c$','interpreter','latex')

% DF y-axis range
globalMinDf = floor(min(min(R0_df_allT), min(R1_df_allT)));
globalMaxDf = ceil(max(max(R0_df_allT), max(R1_df_allT)));
yLimDfRange = [globalMinDf, globalMaxDf];

set(gcf, 'Position', figPositions);
set(gca, 'fontname', 'TimesNewRoman', 'fontsize', printFontSize, 'ylim', yLimDfRange)
ytickformat('%.2f')

if isBreakAxis
    set(ax, 'xtick', T_xRange)
    if ~isempty(T_breaks), breakxaxis_NB(ax, T_breaks, 0.05); end
end

if saveFig
    this_figname = sprintf("DF_T_%d_%s.eps", trnwin, CVType);
    if strcmpi(figType, "vector")
        exportgraphics(gcf, this_figname, 'ContentType', 'vector', 'BackgroundColor', 'none');
    else
        exportgraphics(gcf, this_figname, 'ContentType', 'image', 'BackgroundColor', 'none', 'Resolution', 300);
    end
end
end