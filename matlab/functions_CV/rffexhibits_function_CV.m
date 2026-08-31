function [] = rffexhibits_function_CV(gamma, trnwin, stdize, demean, RFF_stdize, CVType)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The function generates exhibits in empirical analysis
% Parameters:
% gamma: gamma in Random Fourier Features
% trnwin: training window
% stdize: Standardization. stdize = 1 means True
%
% Additional parameters
% demean: demean = 0 means False. This matches KMZ.
% std_RFFs: 1 means True. We toggle between these.
% CVType: Cross-validation type: Either: "LOOCV" (leave-one-out CV) or
% "OSACV" (one-step-ahead CV)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%tic

%**************************************************************************
% Choices of parameters
%**************************************************************************
if gamma == 0.5
    gamma_str = '0pt5';
else
    gamma_str = num2str(gamma);
end

% Set as function input
% Demeaning = False
% demean      = 0;

% Use subsample
subsamp     = 1;

% max number of Random Fourier Features (RFFs)
maxP        = 12000;

% saving string
para_str = strcat('maxP-', num2str(maxP), '-trnwin-', num2str(trnwin), '-gamma-',...
    num2str(gamma), '-stdize-', num2str(stdize), '-demean-', num2str(demean),'-v2');

% the number of simulations is 1000 - unused
% nSim = 1000;

% save the results
%saveon = 1;

% Local path
thisRFF_datadir = strcat('./individual-files_stdize_',CVType, '_RFFs_', num2str(RFF_stdize),'/');
%gybench_datadir = thisRFF_datadir;
figdir      = strcat('./RFF_Empirical_figures/', para_str,'/','-RFF_stdize_',num2str(RFF_stdize),'/');
datadir = thisRFF_datadir;
save_path = strcat(datadir, para_str);
combined_data_save_path = ['./combined_data_RFF_',num2str(RFF_stdize),'_',CVType,'/'];

% build the output folders
mkdir(figdir);
mkdir(combined_data_save_path);

%**************************************************************************
% Load parameters and benchmark
%**************************************************************************
filename = strcat([save_path '/iSim1.mat']);
%load(filename, 'T','nP','nL','Y', 'Plist', 'log_lamlist','dates','lamlist');
load(filename, 'T','nP','nL','Y','dates');

files_listing   = dir([save_path '/*.mat']);

nSim = size(files_listing, 1);
Yprd_collect    = nan(T,nP,nL,nSim); % predicted Y
Bnrm_collect    = nan(T,nP,nL,nSim); % beta norm
lambdaOpt_collect = nan(T,nP,nL,nSim); % optimal lambda
dfOpt_collect = nan(T,nP,nL,nSim); % corresponding df

%**************************************************************************
% Collect results of 1000 simulations
%**************************************************************************

% load the benchmark of Welch and Goyal (2008) "kitchen sink" regression
%load([gybench_datadir 'gybench-trnwin-' num2str(trnwin) '-stdize-' num2str(stdize)  '-demean-' num2str(demean) '.mat'])

Y_B_file_save = ['trnwin-' num2str(trnwin) '-gamma-' num2str(gamma) '-stdize-' num2str(stdize) '-demean-' num2str(demean) '-Y-B'];
filename = strcat(combined_data_save_path, Y_B_file_save, '.mat');
if isfile(filename)
    % if the combined result exists
    load(filename);
else
    % if the combined result doesn't exist
    for s = 1:nSim
        % disp(s); % random seed
        % load data
        filename = strcat([save_path '/' files_listing(s).name]);
        load(filename, 'Yprd', 'Bnrm','LamOpt','DfOpt');

        Yprd_collect(:,:,:,s)   = Yprd;
        Bnrm_collect(:,:,:,s)   = Bnrm;
        lambdaOpt_collect(:,:,:,s)   = LamOpt; % T x P
        dfOpt_collect(:,:,:,s)   = DfOpt; % T x P
    end

    clearvars Yprd Bnrm LamOpt DfOpt
    Yprd = Yprd_collect;
    Bnrm = Bnrm_collect;

    Bnrmbar     = nanmean(Bnrm,4);  % nanmedian(Bnrm,4);
    Bnrmbar     = squeeze(nanmean(Bnrmbar,1)); % squeeze(nanmedian(Bnrmbar,1));
    timing      = Yprd.*Y';
    pihat       = [squeeze(nanmean(Yprd(:,nP,nL,:),4)) squeeze(nanmean(Yprd(:,1,1,:),4))];
    
    lambdaOpt_summary = nanmean(squeeze(lambdaOpt_collect(:,:,:,:)),3);
    dfOpt_summary = nanmean(squeeze(dfOpt_collect(:,:,:,:)),3);
end

disp('Data Loaded')
%toc

% percentile list
pctlist     = [1 2.5 5 25 50 75 95 97.5 99];

%% Generate exhibits
%**************************************************************************
% Portfolio Evaluation: Full Sample
%**************************************************************************

if subsamp==1
    subbeg      = [1926 1926 1975];
    subend      = [2020 1974 2020];
else
    subbeg      = 1926;
    subend      = 2020;
end

nPct        = length(pctlist);
nSub        = length(subbeg);

for ss=1:nSub
    % Evaluation period
    locev       = find(dates>=subbeg(ss)*100 & dates<=(subend(ss)+1)*100);

    % Suffix
    suffix      = ['trnwin-' num2str(trnwin) '-gamma-' num2str(gamma) '-stdize-' num2str(stdize) '-demean-' num2str(demean) '-' num2str(subbeg(ss)) '-' num2str(subend(ss))];
    performance_filename = strcat(combined_data_save_path, suffix, '.mat');

    % generate performance measurements
    if isfile(performance_filename)
        load(performance_filename);
    else

        %**************************************************************************
        % Performance initialization
        %**************************************************************************
        ER          = nan(nP,nL);
        SR          = nan(nP,nL);
        vol         = nan(nP,nL);
        IR          = nan(nP,nL);
        IRt         = nan(nP,nL);
        alpha       = nan(nP,nL);
        R2          = nan(nP,nL);
        IRstd       = nan(nP,nL);

        ERpct       = nan(nP,nL,nPct);
        SRpct       = nan(nP,nL,nPct);
        volpct      = nan(nP,nL,nPct);
        IRpct       = nan(nP,nL,nPct);
        IRtpct      = nan(nP,nL,nPct);
        alphapct    = nan(nP,nL,nPct);
        R2pct       = nan(nP,nL,nPct);
        Ytmp        = Y(locev)';
        for p=1:nP
            for l=1:nL
                ERtmp           = nan(nSim,1);
                SRtmp           = nan(nSim,1); % Added
                voltmp          = nan(nSim,1);
                IRtmp           = nan(nSim,1);
                IRttmp          = nan(nSim,1);
                alphatmp        = nan(nSim,1);
                R2tmp           = nan(nSim,1);
                IRstdtmp        = nan(nSim,1);
                timtmp          = squeeze(timing(locev,p,l,:));
                Yprdtmp         = squeeze(Yprd(locev,p,l,:));


                parfor i=1:nSim 
                    stats       = regstats(timtmp(:,i),Ytmp,'linear',{'tstat','r'});
                    SRtmp(i)    = sharpe(timtmp(:,i),0); % explicitly pass 0 cash rate
                    ERtmp(i)    = nanmean(timtmp(:,i));
                    voltmp(i)   = nanstd(timtmp(:,i));
                    IRtmp(i)    = stats.tstat.beta(1)/nanstd(stats.r);
                    IRttmp(i)   = stats.tstat.t(1);
                    alphatmp(i) = stats.tstat.beta(1);
                    IRstdtmp(i) = nanstd(stats.r);

                    loc     = find(~isnan(Yprdtmp(:,i)+Ytmp));
                    R2tmp(i)    = 1-var(Yprdtmp(loc,i)-Ytmp(loc),'omitnan')/var(Ytmp(loc),'omitnan');

                end
                SR(p,l)         = nanmean(SRtmp);
                ER(p,l)         = nanmean(ERtmp);
                vol(p,l)        = nanmean(voltmp);
                IR(p,l)         = nanmean(IRtmp);
                IRt(p,l)        = nanmean(IRttmp);
                alpha(p,l)      = nanmean(alphatmp);
                R2(p,l)         = nanmean(R2tmp);
                IRstd(p,l)      = nanmean(IRstdtmp);

                SRpct(p,l,:)    = prctile(SRtmp,pctlist);
                ERpct(p,l,:)    = prctile(ERtmp,pctlist);
                volpct(p,l,:)   = prctile(voltmp,pctlist);
                IRpct(p,l,:)    = prctile(IRtmp,pctlist);
                IRtpct(p,l,:)   = prctile(IRttmp,pctlist);
                alphapct(p,l,:) = prctile(alphatmp,pctlist);
                R2pct(p,l,:)    = prctile(R2tmp,pctlist);
                %disp(['p=' num2str(p) ', l=' num2str(l)])
            end
        end

        % save the data
        save(performance_filename,'locev','ER','SR', 'vol','IR','IRt','alpha','R2',...
            'ERpct','SRpct', 'volpct','IRpct','IRtpct','alphapct','R2pct', 'IRstd',...
            'Bnrmbar','timing', 'pihat', 'Yprd', 'lambdaOpt_summary','dfOpt_summary','-v7.3')
    end

    
% We end here
%toc

end