% Parameter recovery reduced Bayesian model (RBM)
%
% 1. Preprocessing
% 2. Simulate data with RBM
% 3. Estimate RBM
% 4. Plot correlations

% Number of random starting points for model estimation
n_sp = 50;
rand_sp = true;

% Identify parent directory of this config script
parentDirectory = fileparts(fileparts(mfilename('fullpath')));
cd(parentDirectory)
addpath(genpath(parentDirectory));

% This is the BIDS folder
bidsDir = strcat(parentDirectory, filesep, 'for_data', filesep, 'for_bids_data');

% ----------------
% 1. Preprocessing
% ----------------

% Run preprocessing to get all behavioral data
allSubBehavData = for_preprocessing(bidsDir);

% Number of subjects
n_subj = length(unique(allSubBehavData.subj_num));

% Set agent variables
agent_vars = ForAgentVars();
agent_vars.tau_0 = 0.999;
agent_vars.sigma_0 = 6.1875;
agent_vars.mu_0 = 3.1416;
agent_vars.max_x = 2 * pi;

% Initialize estimation variables
est_vars = ForEstVars();
est_vars.n_subj = n_subj;
est_vars.n_sp = n_sp;
est_vars.use_prior = true;
est_vars.rand_sp = rand_sp;

% Determine free parameters
est_vars.which_vars.omikron_0 = true;
est_vars.which_vars.omikron_1 = true;
est_vars.which_vars.h = true;
est_vars.which_vars.s = true;
est_vars.which_vars.u = true;
est_vars.which_vars.sigma_H = true;

% -------------------------
% 2. Simulate data with RBM
% -------------------------

% Randomly sample parameters
% --------------------------

df_model = table();

if est_vars.which_vars.omikron_0
   df_model.omikron_0 = rand(n_subj,1) * 10 + 3;
else
 df_model.omikron_0 = zeros(n_subj, 1);
end

if est_vars.which_vars.omikron_1
    df_model.omikron_1 = rand(n_subj, 1) * 0.3;
else
    df_model.omikron_1 = zeros(n_subj, 1);
end

if est_vars.which_vars.h
    df_model.h = rand(n_subj,1);
else
    df_model.h = ones(n_subj,1) * 0.1;
end

if est_vars.which_vars.s
    df_model.s = rand(n_subj,1);
else
    df_model.s = ones(n_subj,1);
end

if est_vars.which_vars.u
    df_model.u = rand(n_subj,1) * 4;
else
    df_model.u = zeros(n_subj,1);
end

if est_vars.which_vars.sigma_H
    df_model.sigma_H = rand(n_subj, 1) * 0.5;
else
    df_model.sigma_H = zeros(n_subj, 1);
end

df_model.subj_num = (1:n_subj)';

% Run RBM for simulations
sim = true;
plot_data = false; % no plotting for now
[~, df_data, true_params_RBM] = for_simulation(allSubBehavData, df_model, n_subj, plot_data, sim);

% ---------------
% 3. Estimate RBM
% ---------------

% Create estimation-object instance
estimation = ForEstimation(est_vars);

% Translate data table to structure
dataStructSingle = table2struct(df_data, 'ToScalar', true);
dataStructSingle.mu_t = allSubBehavData.mu_t;

% Estimate model
results_recovery_RBM = estimation.run_estimation(dataStructSingle, agent_vars);

% --------------------
% 4. Plot correlations
% --------------------

behavLabels = {est_vars.omikron_0, est_vars.omikron_1, est_vars.h, est_vars.s, est_vars.u, est_vars.sigma_H};
whichParamsVec = struct2array(est_vars.which_vars);
behavLabels = behavLabels(whichParamsVec);
gridSize = [2,3];
for_recoverySummary(true_params_RBM, results_recovery_RBM, behavLabels, behavLabels, gridSize)
