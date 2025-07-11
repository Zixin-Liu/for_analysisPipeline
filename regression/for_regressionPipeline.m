% FOR Regression pipeline
%
% 1. Preprocessing
% 2. Run reduced Bayesian model over the data
% 3. Run regression
% 4. Compare actual and predicted update distributions

% Number of random starting points for regression estimation
n_sp = 50;
rand_sp = true;

% Identify parent directory of this config script
parentDirectory = 'C:\Users\bbf2518\Documents\GitHub\for_analysisPipeline_og';
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

% -------------------------------------------
% 2. Run reduced Bayesian model over the data
% -------------------------------------------

% Independent normative model parameter initialization
df_model = table();
df_model.omikron_0 = repmat(3, n_subj, 1);
df_model.omikron_1 = zeros(n_subj, 1);
df_model.h = repmat(0.1, n_subj, 1);
df_model.s = ones(n_subj, 1);
df_model.u = zeros(n_subj, 1);
df_model.sigma_H = repmat(0.01, n_subj, 1);
df_model.subj_num = (1:n_subj)';

sim = false; % don't generate predictions
plot_data = false; % no plotting for now

% Run RBM
[~, df_data] = for_simulation(allSubBehavData, df_model, n_subj, plot_data, sim);

% Add RU and CPP to data frame
allSubBehavData.tau_t = df_data.tau_t;
allSubBehavData.omega_t = df_data.omega_t;

% -----------------
% 3. Run regression
% -----------------

% Initialize regression variables
reg_vars = ForRegVars();
reg_vars.n_subj = n_subj;
reg_vars.n_sp = n_sp;
reg_vars.rand_sp = rand_sp;
reg_vars.usePrior = false; %true;

% Determine which parameters should be estimated
reg_vars.which_vars.beta_0 = true; % intercept
reg_vars.which_vars.beta_1 = true; % PE (fixed learning rate)
reg_vars.which_vars.beta_2 = true; % interaction PE and RU
reg_vars.which_vars.beta_3 = true; % interaction PE and CPP
reg_vars.which_vars.beta_4 = true; % interaction PE and hit
reg_vars.which_vars.beta_5 = true; % interaction PE and noise condition
reg_vars.which_vars.beta_6 = true; % interaction PE and visible
reg_vars.which_vars.beta_7 = false; % interaction EE and visible
reg_vars.which_vars.omikron_0 = true; % motor noise (independent of PE)
reg_vars.which_vars.omikron_1 = true; % learning-rate noise (dependent on PE)
reg_vars.which_vars.overshoot_lr = true; % parameter modeling systematic trials with LR > 1 
reg_vars.which_vars.overshoot_prob = true; % overshoot component
reg_vars.regressionComponents = [reg_vars.which_vars.beta_0, reg_vars.which_vars.beta_1,...
    reg_vars.which_vars.beta_2, reg_vars.which_vars.beta_3, reg_vars.which_vars.beta_4,...
    reg_vars.which_vars.beta_5, reg_vars.which_vars.beta_6, reg_vars.which_vars.beta_7];

% Create regression-object instance
regression = ForRegression(reg_vars);

% Estimate regression model
results_Regression = regression.run_estimation(allSubBehavData);
parameters = results_Regression.parameters;
save('parameters.mat', 'parameters');
writetable(parameters, 'parameters.csv');

% Simple plots of key coefficients
behavLabels = {'Int', 'PE', 'PE*RU', 'PE*CPP', 'PE*Hit', 'PE*Noise',...
    'PE*Visible', 'EE*Visble', 'Motor noise', 'LR noise', 'overshoot_lr',... 
    'overshot_prob'};
which_vars_vec = struct2array(reg_vars.which_vars);
behavLabels = behavLabels(which_vars_vec);
gridSize = [3,4];
for_parameterSummary(results_Regression.parameters, behavLabels, gridSize)

% ----------------------------------------------------
% 4. Compare actual and predicted update distributions
% ----------------------------------------------------
 
% Take actual parameter values given specified free parameters
df_params = table();
if reg_vars.which_vars.beta_0
    df_params.beta_0 = results_Regression.parameters.beta_0;
end

if reg_vars.which_vars.beta_1
    df_params.beta_1 = results_Regression.parameters.beta_1;
end

if reg_vars.which_vars.beta_2
    df_params.beta_2 = results_Regression.parameters.beta_2;
end

if reg_vars.which_vars.beta_3
    df_params.beta_3 = results_Regression.parameters.beta_3;
end

if reg_vars.which_vars.beta_4
    df_params.beta_4 = results_Regression.parameters.beta_4;
end

if reg_vars.which_vars.beta_5
    df_params.beta_5 = results_Regression.parameters.beta_5;
end

if reg_vars.which_vars.beta_6
    df_params.beta_6 = results_Regression.parameters.beta_6;
end

if reg_vars.which_vars.beta_7
    df_params.beta_7 = results_Regression.parameters.beta_7;
end

% omikron_0 should be true by default
df_params.omikron_0 = results_Regression.parameters.omikron_0;

if reg_vars.which_vars.omikron_1
    df_params.omikron_1 = results_Regression.parameters.omikron_1;
end

if reg_vars.which_vars.overshoot_lr
   df_params.overshoot_lr = results_Regression.parameters.overshoot_lr;
end

if reg_vars.which_vars.overshoot_prob
   df_params.overshoot_prob = results_Regression.parameters.overshoot_prob;
end

% Number of subjects
df_params.subj_num = (1:n_subj)';

% Sample updates from regression model
n_trials = 240;
samples = regression.sample_data(df_params, n_trials, allSubBehavData);


% Tranlate table to structure
samplesStruct = table2struct(samples, 'ToScalar', true);

% Compare actual and predicted updates
% ------------------------------------

% Example subject
% ID = 1;
% for_plotRegUpdate(allSubBehavData, samples, ID)

% All subjects
% for_plotRegUpdate(allSubBehavData, samples);


plotA_T(allSubBehavData, samples);

% Getting the original model 

% -----------------
% 3. Run regression
% -----------------

% Initialize regression variables
reg_vars = ForRegVars();
reg_vars.n_subj = n_subj;
reg_vars.n_sp = n_sp;
reg_vars.rand_sp = rand_sp;
reg_vars.usePrior = false; %true;

% Determine which parameters should be estimated
reg_vars.which_vars.beta_0 = true; % intercept
reg_vars.which_vars.beta_1 = true; % PE (fixed learning rate)
reg_vars.which_vars.beta_2 = true; % interaction PE and RU
reg_vars.which_vars.beta_3 = true; % interaction PE and CPP
reg_vars.which_vars.beta_4 = true; % interaction PE and hit
reg_vars.which_vars.beta_5 = true; % interaction PE and noise condition
reg_vars.which_vars.beta_6 = true; % interaction PE and visible
reg_vars.which_vars.beta_7 = false; % interaction EE and visible
reg_vars.which_vars.omikron_0 = true; % motor noise (independent of PE)
reg_vars.which_vars.omikron_1 = false; % learning-rate noise (dependent on PE)
reg_vars.which_vars.overshoot_lr = false; % parameter modeling systematic trials with LR > 1 
reg_vars.which_vars.overshoot_prob = false; % overshoot component
reg_vars.regressionComponents = [reg_vars.which_vars.beta_0, reg_vars.which_vars.beta_1,...
    reg_vars.which_vars.beta_2, reg_vars.which_vars.beta_3, reg_vars.which_vars.beta_4,...
    reg_vars.which_vars.beta_5, reg_vars.which_vars.beta_6, reg_vars.which_vars.beta_7];

% Create regression-object instance
regression_OG = ForRegression(reg_vars);

% Estimate regression model
results_Regression_OG = regression_OG.run_estimation(allSubBehavData);

% DATA
parameters_OG = results_Regression_OG.parameters;
df_params_OG = table();
if reg_vars.which_vars.beta_0
    df_params_OG.beta_0 = results_Regression_OG.parameters.beta_0;
end

if reg_vars.which_vars.beta_1
    df_params_OG.beta_1 = results_Regression_OG.parameters.beta_1;
end

if reg_vars.which_vars.beta_2
    df_params_OG.beta_2 = results_Regression_OG.parameters.beta_2;
end

if reg_vars.which_vars.beta_3
    df_params_OG.beta_3 = results_Regression_OG.parameters.beta_3;
end

if reg_vars.which_vars.beta_4
    df_params_OG.beta_4 = results_Regression_OG.parameters.beta_4;
end

if reg_vars.which_vars.beta_5
    df_params_OG.beta_5 = results_Regression_OG.parameters.beta_5;
end

if reg_vars.which_vars.beta_6
    df_params_OG.beta_6 = results_Regression_OG.parameters.beta_6;
end

if reg_vars.which_vars.beta_7
    df_params_OG.beta_7 = results_Regression_OG.parameters.beta_7;
end

% omikron_0 should be true by default
df_params_OG.omikron_0 = results_Regression_OG.parameters.omikron_0;


% Number of subjects
df_params_OG.subj_num = (1:n_subj)';


% Sample updates from regression model
n_trials = 240;
samples_OG = regression_OG.sample_data(df_params_OG, n_trials, allSubBehavData);

% Tranlate table to structure
samplesStruct = table2struct(samples_OG, 'ToScalar', true);

% All subjects
%for_plotRegUpdate(allSubBehavData, samples_OG)



% Then we calculate the distance between the samples and the actual data
realUP = allSubBehavData.a_t(~isnan(allSubBehavData.a_t));
predUP_OG = samples_OG.a_t(~isnan(samples_OG.a_t));

UPdistance = ws_distance(realUP, predUP_OG);



% Validation of a_t
plotA_T(allSubBehavData, samples_sim);