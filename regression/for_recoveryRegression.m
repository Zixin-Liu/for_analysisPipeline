% Parameter recover regression model
%
% 1. Simulate data for recovery
% 2. Estimate regression model
% 3. Plot correlations

% Number of random starting points for regression estimation
n_sp = 50;

% Number of simulations for recovery
n_subj = 100;

% Identify parent directory of this config script
parentDirectory = fileparts(mfilename('fullpath'));
cd(parentDirectory)
addpath(genpath(parentDirectory));

% -----------------------------
% 1. Simulate data for recovery
% -----------------------------

% Initialize regression variables
reg_vars = ForRegVars();
reg_vars.n_subj = n_subj;
reg_vars.n_sp = n_sp;
reg_vars.usePrior = true;

% Determine which parameters should be estimated
reg_vars.which_vars.beta_0 = true; % intercept
reg_vars.which_vars.beta_1 = true; % PE (fixed learning rate)
reg_vars.which_vars.beta_2 = true; % interaction PE and RU
reg_vars.which_vars.beta_3 = true; % interaction PE and CPP
reg_vars.which_vars.beta_4 = true; % interaction PE and hit
reg_vars.which_vars.beta_5 = true; % interaction PE and noise condition
reg_vars.which_vars.beta_6 = true; % interaction PE and visible
reg_vars.which_vars.beta_7 = false; % interaction EE and visible
reg_vars.which_vars.omikron_0 = true; % motor noise (independent of UP)
reg_vars.which_vars.omikron_1 = true; % learning-rate noise (dependent on UP)
reg_vars.which_vars.overshoot_lr = true; % overshoot learning rate
reg_vars.which_vars.overshoot_prob = true; % overshoot component

reg_vars.regressionComponents = [reg_vars.which_vars.beta_0, reg_vars.which_vars.beta_1,...
    reg_vars.which_vars.beta_2, reg_vars.which_vars.beta_3, reg_vars.which_vars.beta_4,...
    reg_vars.which_vars.beta_5, reg_vars.which_vars.beta_6, reg_vars.which_vars.beta_7];

% Create regression-object instance
regression = ForRegression(reg_vars);

% Sample random model parameters that we try to recover
df_params_recovery_regression = table();

if reg_vars.which_vars.beta_0
    df_params_recovery_regression.beta_0 = unifrnd(-0.1,0.1, n_subj, 1);
end

if reg_vars.which_vars.beta_1
    df_params_recovery_regression.beta_1 = rand(n_subj, 1);
end

if reg_vars.which_vars.beta_2
    df_params_recovery_regression.beta_2 = rand(n_subj,1);
end

if reg_vars.which_vars.beta_3
    df_params_recovery_regression.beta_3 = rand(n_subj,1);
end

if reg_vars.which_vars.beta_4
    df_params_recovery_regression.beta_4 = rand(n_subj,1);
end

if reg_vars.which_vars.beta_5
    df_params_recovery_regression.beta_5 = unifrnd(-0.1,0.1, n_subj, 1);
end

if reg_vars.which_vars.beta_6
    df_params_recovery_regression.beta_6 = unifrnd(-0.1,0.1, n_subj, 1);
end

if reg_vars.which_vars.beta_7
    df_params_recovery_regression.beta_7 = unifrnd(-0.1,0.1, n_subj, 1);
end

df_params_recovery_regression.omikron_0 = unifrnd(3, 10, n_subj,1);

if reg_vars.which_vars.omikron_1
    df_params_recovery_regression.omikron_1 = rand(n_subj, 1) * 0.3;
end

if reg_vars.which_vars.overshoot_lr
   df_params_recovery_regression.overshoot_lr = unifrnd(1, 3.5, n_subj,1);
end

if reg_vars.which_vars.overshoot_prob
   df_params_recovery_regression.overshoot_prob = rand(n_subj, 1);
end

df_params_recovery_regression.subj_num = (1:n_subj)';

% Simulate updates based on sampled parameters
n_trials = 240;
samples_sim = regression.sample_data(df_params_recovery_regression, n_trials);

% ----------------------------
% 2. Estimate regression model
% ----------------------------

% Translate table to structure
samplesStruct = table2struct(samples_sim, 'ToScalar', true);

% Estimate regression model
results_recovery_regression = regression.run_estimation(samplesStruct);

% --------------------
% 3. Plot correlations
% --------------------

selVariables = {reg_vars.beta_0, reg_vars.beta_1, reg_vars.beta_2,...
    reg_vars.beta_3, reg_vars.beta_4, reg_vars.beta_5,...
    reg_vars.beta_6, reg_vars.beta_7, reg_vars.omikron_0,...
    reg_vars.omikron_1, reg_vars.overshoot_lr, reg_vars.overshoot_prob};

titleName = {'Int', 'Fixed LR', 'RU',...
    'CPP', 'Hit', 'Noise',...
    'PE-Visible', 'EE-Visible', 'Omikron 0',...
    'Omikron 1', 'OS LR', 'OS Prob'};

whichParamsVec = struct2array(reg_vars.which_vars);
selVariables = selVariables(whichParamsVec);
titleName = titleName(whichParamsVec);
gridSize = [3,4];
for_recoverySummary(df_params_recovery_regression, results_recovery_regression, selVariables, titleName, gridSize);


% 4. Now we start validation

% First we calculate the distance between the samples and the actual data
realUP = allSubBehavData.a_t(~isnan(allSubBehavData.a_t));
predUP = samples_sim.a_t(~isnan(samples_sim.a_t));

realEE = allSubBehavData.e_t(~isnan(allSubBehavData.e_t));
predEE = samples_sim.e_t(~isnan(samples_sim.e_t));

plotE_T(allSubBehavData,samples_sim)


