function KMZ_RFF_compare_oracle_std_vs_unstd(trnwin, nSim, gamma, stdize, demean)
% KMZ_RFF_COMPARE_ORACLE_STD_VS_UNSTD Compare performance for RFF standardized vs unstandardized
%
%   Loads combined results for RFF standardization = 1 and 0, compares
%   performance metrics (R2, SR, ER, vol), and writes summary tables/figures.
%
%   Syntax:
%       KMZ_RFF_compare_oracle_std_vs_unstd(trnwin, nSim, gamma, stdize, demean)
%
%   Inputs:
%       trnwin  - (numeric scalar) Training window size.
%       nSim    - (numeric scalar) Number of simulations.
%       gamma   - (numeric scalar) RFF gamma parameter.
%       stdize  - (numeric scalar) 1 if predictors were standardized, 0 otherwise.
%       demean  - (numeric scalar) 1 if predictors were demeaned, 0 otherwise.

% --- Default Arguments ---
if nargin < 5, demean = 0; end
if nargin < 4, stdize = 1; end
if nargin < 3, gamma = 2; end
if nargin < 2, nSim = 1000; end
if nargin < 1, trnwin = 12; end

% --- Input Validation ---
validateattributes(trnwin, {'numeric'}, {'scalar','integer','positive'}, mfilename, 'trnwin');
validateattributes(nSim,   {'numeric'}, {'scalar','integer','positive'}, mfilename, 'nSim');
validateattributes(gamma,  {'numeric'}, {'scalar','positive'}, mfilename, 'gamma');
validateattributes(stdize, {'numeric','logical'}, {'scalar'}, mfilename, 'stdize');
validateattributes(demean, {'numeric','logical'}, {'scalar'}, mfilename, 'demean');

if ~ismember(double(stdize), [0, 1]), error('stdize must be 0 or 1.'); end
if ~ismember(double(demean), [0, 1]), error('demean must be 0 or 1.'); end

% --- Configuration ---
startDateRange = 1926;
endDateRange   = 2020;
suffix = sprintf('trnwin-%d-gamma-%d-stdize-%d-demean-%d-%d-%d', ...
                 trnwin, gamma, stdize, demean, startDateRange, endDateRange);

fprintf('Starting Oracle comparison for T = %d...\n', trnwin);

% Load parameters (use RFF=1 data dir if available, otherwise GenericSimData)
maxP = 12000;
thisRFF_datadir = [fullfile(pwd, 'individual-files_stdize_oracle_RFFs_1'), filesep];
para_str = sprintf('maxP-%d-trnwin-%d-gamma-%d-stdize-%d-demean-%d-v2', ...
                   maxP, trnwin, gamma, stdize, demean);
save_path = fullfile(thisRFF_datadir, para_str);
filename = fullfile(save_path, 'iSim1.mat');

if exist(filename, "file")
    load(filename, 'T', 'nP', 'nL', 'Y', 'Plist', 'log_lamlist', 'dates', 'lamlist');
else
    load('GenericSimData', 'T', 'nP', 'nL', 'Y', 'Plist', 'log_lamlist', 'dates', 'lamlist');
end

% Load combined results for RFF_stdize = 1 and 0 
fprintf('Loading Oracle combined datasets...\n');
combined_data_save_path_RFF_1 = [fullfile(pwd, 'combined_data_RFF_1_oracle'), filesep];
performance_filename_RFF_1 = fullfile(combined_data_save_path_RFF_1, [suffix '.mat']);
if ~exist(performance_filename_RFF_1, 'file')
    error('RFF standardized results file not found: %s', performance_filename_RFF_1);
end
dataStruct_RFF_1 = load(performance_filename_RFF_1, ...
    'locev','ER','SR','vol','IR','IRt','alpha','R2',...
    'ERpct','SRpct','volpct','IRpct','IRtpct','alphapct','R2pct','IRstd',...
    'Bnrmbar','timing','pihat','Yprd','dfOpt_summary');

combined_data_save_path_RFF_0 = [fullfile(pwd, 'combined_data_RFF_0_oracle'), filesep];
performance_filename_RFF_0 = fullfile(combined_data_save_path_RFF_0, [suffix '.mat']);
if ~exist(performance_filename_RFF_0, 'file')
    error('RFF unstandardized results file not found: %s', performance_filename_RFF_0);
end
dataStruct_RFF_0 = load(performance_filename_RFF_0, ...
    'locev','ER','SR','vol','IR','IRt','alpha','R2',...
    'ERpct','SRpct','volpct','IRpct','IRtpct','alphapct','R2pct','IRstd',...
    'Bnrmbar','timing','pihat','Yprd','dfOpt_summary');

% Plot / output configuration
printResultsToExcel = true;
plotAll = false; % plot results for all shrinkage levels
saveFig = false;
printFontSize = 24;
runPerfComps = true; 
figType = "vector";
figPositions = [488.0000 165.8000 709.0000 496.2000];

% x-axis ranges depending on trnwin
switch trnwin
    case 1
        T_xRange = [0:10:50, 11995, 12000]; T_breaks = [51 11994];
    case 12
        T_xRange = [0:10:50, 990, 1000];    T_breaks = [51 989];
    case 60
        T_xRange = [0,5,10, 195, 200];      T_breaks = [11 194];
    case 120
        T_xRange = [0,5,10, 95, 100];       T_breaks = [11 94];
    otherwise
        T_xRange = 0:10:50;                 T_breaks = [];
end

shrinkage_to_plot = 1:nL;
perfMetricsToPlot = ["R2", "SR", "ER", "vol"];
log_lam_legend = "Oracle $\lambda$";
combinedShrinkageAndRFFStdLegend = [log_lam_legend + ", RFF Stdize = 1"; log_lam_legend + ", RFF Stdize = 0"];

% -------------------------------------------------------------------------
% Optional: Run performance comparison plots
% -------------------------------------------------------------------------
if runPerfComps
    fprintf('Generating performance metric comparisons...\n');
    for idxPlot = 1:length(perfMetricsToPlot)
        perfMetricStr = perfMetricsToPlot(idxPlot);
        perfMetricVal_RFF_1 = dataStruct_RFF_1.(perfMetricStr); 
        perfMetricVal_RFF_0 = dataStruct_RFF_0.(perfMetricStr);
        
        % Annualise where appropriate
        if any(strcmp(perfMetricStr, ["SR", "IR"]))
            perfMetricVal_RFF_1 = perfMetricVal_RFF_1 .* sqrt(12);
            perfMetricVal_RFF_0 = perfMetricVal_RFF_0 .* sqrt(12);
        end
       
        if plotAll
        figure('Color','white','Position',figPositions)
        ax = gca;
        for idxL = shrinkage_to_plot
            p1 = plot(ax, Plist/trnwin, perfMetricVal_RFF_1(:,idxL), 'linewidth', 1.5); hold on
            plot(ax, Plist/trnwin, perfMetricVal_RFF_0(:,idxL), 'linewidth', 1.5, 'LineStyle', '--', 'Color', p1.Color)
        end
        xlabel('$c$','interpreter','latex')
        
        switch perfMetricStr
            case "ER"
                set(gca,'fontname','TimesNewRoman','fontsize',printFontSize,'ylim',[0,0.0385])
                isBreakAxis = true;
            case "vol"
                set(gca,'fontname','TimesNewRoman','fontsize',printFontSize,'ylim',[0,min(5, max(max(perfMetricVal_RFF_0))+ 0.1)])
                isBreakAxis = true;
            case "R2"
                set(gca,'fontname','TimesNewRoman','fontsize',printFontSize); xlim([0,50])
                isBreakAxis = false;
                legend(combinedShrinkageAndRFFStdLegend,'fontsize',printFontSize,'interpreter','latex','Location','southeast');
            case "SR"
                set(gca,'fontname','TimesNewRoman','fontsize',printFontSize,'ylim',[0,0.5])
                isBreakAxis = true;
        end
        ytickformat('%.2f')
        
        if isBreakAxis && ~isempty(T_breaks)
            set(ax,'xtick',T_xRange)
            breakxaxis_NB(ax, T_breaks, 0.05);
            % Deal with last 2 labels specific to TrnWin
            if trnwin == 12
                ax_children = get(gcf,'children');
                ax_children(2).XAxis.TickLabels = {'0.9k','1k','0.9k','1k','0.9k','0.9k','1k'};
            end
        end
        end
        
        % Build tables and optionally write to Excel
        lamlist_names = string(strcat(strcat('$\log_{10}(z)=',num2str(log10(lamlist)')),'$'));
        R1_Tbl = array2table(perfMetricVal_RFF_1, "RowNames", string(Plist), "VariableNames", lamlist_names + "_" + perfMetricStr);
        R0_Tbl = array2table(perfMetricVal_RFF_0, "RowNames", string(Plist), "VariableNames", lamlist_names + "_" + perfMetricStr);
        
        if printResultsToExcel
            thisOutputFileParentName = "KMZ_T_" + num2str(trnwin) + "_RFF_Stdize_Compare_oracle_NSim_" + num2str(nSim);
            thisOutputFileName = thisOutputFileParentName + "_" + perfMetricStr + ".xlsx";
            if ~isempty(dataStruct_RFF_1)
                writetable(R1_Tbl, thisOutputFileName, "WriteRowNames", true, "WriteVariableNames", true, "Sheet", "RFFStdize_1_T_" + trnwin)
            end
            writetable(R0_Tbl, thisOutputFileName, "WriteRowNames", true, "WriteVariableNames", true, "Sheet", "RFFStdize_0_T_" + trnwin)
        end
        
        if plotAll & saveFig
            this_figname = perfMetricStr + "_T_" + num2str(trnwin) + "_oracle.eps";
            if strcmpi(figType, "vector")
                exportgraphics(gcf, char(this_figname), 'ContentType', 'vector', 'BackgroundColor', 'none');
            else
                exportgraphics(gcf, char(this_figname), 'ContentType', 'image', 'BackgroundColor', 'none', 'Resolution', 300);
            end
        end
    end
end

% -------------------------------------------------------------------------
% Process Annualised Out-Of-Sample SR Arrays
% -------------------------------------------------------------------------
fprintf('Extracting optimal metrics...\n');
SR_1 = dataStruct_RFF_1.SR .* sqrt(12);
SR_0 = dataStruct_RFF_0.SR .* sqrt(12);

% Find optimal indices for each row based on Max SR
[max_sr_std, max_col_std] = max(SR_1, [], 2);
[max_sr_raw, max_col_raw] = max(SR_0, [], 2);
num_p = length(Plist);

% Preallocate optimal arrays
oracle_z_std = zeros(num_p, 1);
er_opt_std   = zeros(num_p, 1);
vol_opt_std  = zeros(num_p, 1);
r2_opt_std   = zeros(num_p, 1);
df_opt_std   = zeros(num_p, 1);
sr_opt_std   = max_sr_std;

oracle_z_raw = zeros(num_p, 1);
er_opt_raw   = zeros(num_p, 1);
vol_opt_raw  = zeros(num_p, 1);
r2_opt_raw   = zeros(num_p, 1);
df_opt_raw   = zeros(num_p, 1);
sr_opt_raw   = max_sr_raw;

% Extract corresponding values from matrices natively
for i = 1:num_p
    oracle_z_std(i) = lamlist(max_col_std(i));
    er_opt_std(i)   = dataStruct_RFF_1.ER(i, max_col_std(i));
    vol_opt_std(i)  = dataStruct_RFF_1.vol(i, max_col_std(i));
    r2_opt_std(i)   = dataStruct_RFF_1.R2(i, max_col_std(i));
    df_opt_std(i)   = dataStruct_RFF_1.dfOpt_summary(i, max_col_std(i));
    
    oracle_z_raw(i) = lamlist(max_col_raw(i));
    er_opt_raw(i)   = dataStruct_RFF_0.ER(i, max_col_raw(i));
    vol_opt_raw(i)  = dataStruct_RFF_0.vol(i, max_col_raw(i));
    r2_opt_raw(i)   = dataStruct_RFF_0.R2(i, max_col_raw(i));
    df_opt_raw(i)   = dataStruct_RFF_0.dfOpt_summary(i, max_col_raw(i));
end

% -------------------------------------------------------------------------
% Write to Combined Excel Output Panel
% -------------------------------------------------------------------------
target_rows = [10; 20; 60; 120; 600; 1200; 4000; 8000; 12000];

% Get valid row indices for the targets ensuring they exist in Plist
[valid_targets, row_indices] = ismember(target_rows, Plist);
valid_rows_idx = row_indices(valid_targets);
valid_target_rows = target_rows(valid_targets);

panel_data = [ ...
    valid_target_rows, ...
    oracle_z_std(valid_rows_idx), oracle_z_raw(valid_rows_idx), ...
    sr_opt_std(valid_rows_idx),   sr_opt_raw(valid_rows_idx), ...
    er_opt_std(valid_rows_idx),   er_opt_raw(valid_rows_idx), ...
    vol_opt_std(valid_rows_idx),  vol_opt_raw(valid_rows_idx), ...
    r2_opt_std(valid_rows_idx),   r2_opt_raw(valid_rows_idx), ...
    df_opt_std(valid_rows_idx),   df_opt_raw(valid_rows_idx), ...
];

if printResultsToExcel
    output_file = 'Oracle_Performance_Metrics.xlsx';
    sub_headers  = {'',     'Std',           'Raw', 'Std', 'Raw', 'Std', 'Raw', 'Std', 'Raw', 'Std', 'Raw','Std', 'Raw'};
    main_headers = {'Row', 'Oracle_Lambda', '',    'SR',  '',    'ER',  '',    'Vol', '',    'R2',  '', 'DF', ''};
    
    sheetName = ['T = ', num2str(trnwin)];
    writecell({sprintf('T=%d', trnwin)}, output_file, 'Sheet', sheetName, 'Range', 'A1');
    writecell(sub_headers, output_file, 'Sheet', sheetName, 'Range', 'A2');
    writecell(main_headers, output_file, 'Sheet', sheetName, 'Range', 'A3');
    writematrix(panel_data, output_file, 'Sheet', sheetName, 'Range', 'A4');
    fprintf('Oracle metrics output saved to %s (Sheet: %s)\n', output_file, sheetName);
end

% -------------------------------------------------------------------------
% Plot Oracle Selected Lambda and Degrees of Freedom
% -------------------------------------------------------------------------
fprintf('Plotting Oracle optimal results...\n');
oraclePlotMetrics = ["R2","SR","ER","vol","lambda","df"];
figIdStr = "RFFStdize_Compare";

for idxPlot = 1:length(oraclePlotMetrics)
    perfMetricStr = oraclePlotMetrics(idxPlot);
    figure('Color','white','Position',figPositions)
    ax = gca;
    
    switch perfMetricStr
        case "SR"

            std_metric = sr_opt_std;
            raw_metric = sr_opt_raw;
            globalMin = 0;
            globalMax = max(max(raw_metric), max(std_metric))+ 0.1;
            isBreakAxis = true;

        case "ER"

            std_metric = er_opt_std;
            raw_metric = er_opt_raw;
            globalMin = 0;
            globalMax = max(max(raw_metric), max(std_metric))+ 0.001;
            isBreakAxis = true;


        case "vol"

            std_metric = vol_opt_std;
            raw_metric = vol_opt_raw;
            globalMin = max(min(min(raw_metric), min(std_metric))- 0.1,0);
            globalMax = max(max(raw_metric),max(std_metric))+ 0.1;
            isBreakAxis = true;

        case "R2"

            std_metric = r2_opt_std;
            raw_metric = r2_opt_raw;
            isBreakAxis = false;
           
        case "lambda"
            std_metric = oracle_z_std;
            raw_metric = oracle_z_raw;
            globalMin = min(min(raw_metric), min(std_metric)) - 10;
            globalMax = max(max(raw_metric), max(std_metric)) + 10;
            isBreakAxis = false;

        case "df"
            std_metric = df_opt_std;
            raw_metric = df_opt_raw;
            globalMin = max(min(min(raw_metric), min(std_metric)) - 0.1, 0);
            globalMax = max(max(raw_metric), max(std_metric)) + 0.1;
            isBreakAxis = true;
    end
    
    p1 = plot(ax, Plist/trnwin, std_metric, 'linewidth', 1.5); hold on;
    plot(ax, Plist/trnwin, raw_metric, 'linewidth', 1.5, 'LineStyle', '--', 'Color', p1.Color)
    xlabel('$c$','interpreter','latex')
    
    if strcmpi(perfMetricStr,"R2")
        xlim([0,50])
        yLimRange = ax.YLim;
        lh = legend(combinedShrinkageAndRFFStdLegend,'fontsize',printFontSize,'interpreter','latex','Location','southeast');
    else
        yLimRange = [globalMin,globalMax];
    end
    set(gcf, 'Position', figPositions);
    set(gca, 'fontname', 'TimesNewRoman', 'fontsize', printFontSize, 'ylim', yLimRange)
    ytickformat('%.2f')
    
    if isBreakAxis && ~isempty(T_breaks)
        set(ax,'xtick',T_xRange)
        breakxaxis_NB(ax, T_breaks, 0.05);
        % Deal with last 2 labels specific to TrnWin
        ax_children = get(gcf,'children');
        if trnwin == 1
            ax_children(2).XAxis.TickLabels = {'11.9k','12k','11.9k','12k','11.9k','11.9k','12k'};
        elseif trnwin == 12
            ax_children(2).XAxis.TickLabels = {'0.9k','1k','0.9k','1k','0.9k','0.9k','1k'};
        end
    end
    
    if saveFig
        this_figname = perfMetricStr + "_T_" + num2str(trnwin) + "_oracle_" + figIdStr + ".eps";
        if strcmpi(figType, "vector")
            exportgraphics(gcf, char(this_figname), 'ContentType', 'vector', 'BackgroundColor', 'none');
        else
            exportgraphics(gcf, char(this_figname), 'ContentType', 'image', 'BackgroundColor', 'none', 'Resolution', 300);
        end
    end
end

fprintf('Oracle comparison complete.\n');
end