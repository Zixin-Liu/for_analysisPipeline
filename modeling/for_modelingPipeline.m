% FOR Modeling pipeline
%
% 1. Preprocessing
% 2. Estimate reduced Bayesian model
% 3. Plot estimated parameters

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
n_subj = length(unique(allSubBehavData.ID));

% ----------------------------------
% 2. Estimate reduced Bayesian model
% ----------------------------------

% Initialize estimation variables
est_vars = ForEstVars();
est_vars.n_subj = n_subj;
est_vars.n_sp = n_sp;
est_vars.rand_sp = rand_sp;
est_vars.use_prior = true;

% Select estimated parameters
est_vars.which_vars.omikron_0 = true;
est_vars.which_vars.omikron_1 = true;
est_vars.which_vars.h = true;
est_vars.which_vars.s = true;
est_vars.which_vars.u = true;
est_vars.which_vars.sigma_H = true;
% Todo: examine plausible boundaries, currently not really plausible for radians

% Set agent variables
agent_vars = ForAgentVars();
agent_vars.tau_0 = 0.999;
agent_vars.sigma_0 = 6.1875;
agent_vars.mu_0 = pi;
agent_vars.max_x = 2 * pi;

% Create estimation-object instance
estimation = ForEstimation(est_vars);

% Estimate RBM
results = estimation.run_estimation(allSubBehavData, agent_vars);

% ----------------------------
% 3. Plot estimated parameters
% ----------------------------

behavLabels = {est_vars.omikron_0, est_vars.omikron_1, est_vars.h, est_vars.s, est_vars.u, est_vars.sigma_H};
whichParamsVec = struct2array(est_vars.which_vars);
behavLabels = behavLabels(whichParamsVec);
gridSize = [3,2];
for_parameterSummary(results.parameters, behavLabels, gridSize)