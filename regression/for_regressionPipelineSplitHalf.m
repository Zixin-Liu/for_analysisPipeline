% FOR Regression pipeline
%
% 1. Preprocessing and split the data
% 2. Run reduced Bayesian model over the two sets of data separately
% 3. Run regression on each set
% 4. Compare actual and predicted update distributions for each set
% 5. Compute the correlation between the results. 

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

% Then we split the data for validation

[allSubBehavData_Split1, allSubBehavData_Split2] = splitHalf_seq(allSubBehavData);

% -------------------------------------------
% 2. Run reduced Bayesian model over the data set 1
% -------------------------------------------

% Independent normative model parameter initialization
df_model_Split1 = table();
df_model_Split1.omikron_0 = repmat(3, n_subj, 1);
df_model_Split1.omikron_1 = zeros(n_subj, 1);
df_model_Split1.h = repmat(0.1, n_subj, 1);
df_model_Split1.s = ones(n_subj, 1);
df_model_Split1.u = zeros(n_subj, 1);
df_model_Split1.sigma_H = repmat(0.01, n_subj, 1);
df_model_Split1.subj_num = (1:n_subj)';

sim = false; % don't generate predictions
plot_data = false; % no plotting for now

% Run RBM
[~, df_data] = for_simulation(allSubBehavData_Split1, df_model_Split1, n_subj, plot_data, sim);

% Add RU and CPP to data frame
allSubBehavData_Split1.tau_t = df_data.tau_t;
allSubBehavData_Split1.omega_t = df_data.omega_t;

% -------------------------------------------
% 2. Run reduced Bayesian model over the data set 2
% -------------------------------------------

% Independent normative model parameter initialization
df_model_Split2 = table();
df_model_Split2.omikron_0 = repmat(3, n_subj, 1);
df_model_Split2.omikron_1 = zeros(n_subj, 1);
df_model_Split2.h = repmat(0.1, n_subj, 1);
df_model_Split2.s = ones(n_subj, 1);
df_model_Split2.u = zeros(n_subj, 1);
df_model_Split2.sigma_H = repmat(0.01, n_subj, 1);
df_model_Split2.subj_num = (1:n_subj)';

sim = false; % don't generate predictions
plot_data = false; % no plotting for now

% Run RBM
[~, df_data] = for_simulation(allSubBehavData_Split2, df_model_Split2, n_subj, plot_data, sim);

% Add RU and CPP to data frame
allSubBehavData_Split2.tau_t = df_data.tau_t;
allSubBehavData_Split2.omega_t = df_data.omega_t;



% -----------------
% 3. Run regression on set 1
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
results_Regression_Split1 = regression.run_estimation(allSubBehavData_Split1);
parameters = results_Regression_Split1.parameters;
save('parameters.mat', 'parameters');
writetable(parameters, 'parameters.csv');

% Simple plots of key coefficients
behavLabels = {'Int', 'PE', 'PE*RU', 'PE*CPP', 'PE*Hit', 'PE*Noise',...
    'PE*Visible', 'EE*Visble', 'Motor noise', 'LR noise', 'overshoot_lr',... 
    'overshot_prob'};
which_vars_vec = struct2array(reg_vars.which_vars);
behavLabels = behavLabels(which_vars_vec);
gridSize = [3,4];
for_parameterSummary(results_Regression_Split1.parameters, behavLabels, gridSize)

% -----------------
% 3. Run regression on set 2
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
results_Regression_Split2 = regression.run_estimation(allSubBehavData_Split2);
parameters = results_Regression_Split2.parameters;
save('parameters.mat', 'parameters');
writetable(parameters, 'parameters.csv');

% Simple plots of key coefficients
behavLabels = {'Int', 'PE', 'PE*RU', 'PE*CPP', 'PE*Hit', 'PE*Noise',...
    'PE*Visible', 'EE*Visble', 'Motor noise', 'LR noise', 'overshoot_lr',... 
    'overshot_prob'};
which_vars_vec = struct2array(reg_vars.which_vars);
behavLabels = behavLabels(which_vars_vec);
gridSize = [3,4];
for_parameterSummary(results_Regression_Split2.parameters, behavLabels, gridSize)


% ----------------------------------------------------
% 4. Compare actual and predicted update distributions for set 1
% ----------------------------------------------------
 
% Take actual parameter values given specified free parameters
df_params_Split1 = table();
if reg_vars.which_vars.beta_0
    df_params_Split1.beta_0 = results_Regression_Split1.parameters.beta_0;
end

if reg_vars.which_vars.beta_1
    df_params_Split1.beta_1 = results_Regression_Split1.parameters.beta_1;
end

if reg_vars.which_vars.beta_2
    df_params_Split1.beta_2 = results_Regression_Split1.parameters.beta_2;
end

if reg_vars.which_vars.beta_3
    df_params_Split1.beta_3 = results_Regression_Split1.parameters.beta_3;
end

if reg_vars.which_vars.beta_4
    df_params_Split1.beta_4 = results_Regression_Split1.parameters.beta_4;
end

if reg_vars.which_vars.beta_5
    df_params_Split1.beta_5 = results_Regression_Split1.parameters.beta_5;
end

if reg_vars.which_vars.beta_6
    df_params_Split1.beta_6 = results_Regression_Split1.parameters.beta_6;
end

if reg_vars.which_vars.beta_7
    df_params_Split1.beta_7 = results_Regression_Split1.parameters.beta_7;
end

% omikron_0 should be true by default
df_params_Split1.omikron_0 = results_Regression_Split1.parameters.omikron_0;

if reg_vars.which_vars.omikron_1
    df_params_Split1.omikron_1 = results_Regression_Split1.parameters.omikron_1;
end

if reg_vars.which_vars.overshoot_lr
   df_params_Split1.overshoot_lr = results_Regression_Split1.parameters.overshoot_lr;
end

if reg_vars.which_vars.overshoot_prob
   df_params_Split1.overshoot_prob = results_Regression_Split1.parameters.overshoot_prob;
end

% Number of subjects
df_params_Split1.subj_num = (1:n_subj)';

% Sample updates from regression model
n_trials = 120;
samples_split1 = regression.sample_data(df_params_Split1, n_trials, allSubBehavData_Split1);

% Tranlate table to structure
samplesStruct_Split1 = table2struct(samples_split1, 'ToScalar', true);

% Compare actual and predicted updates
% ------------------------------------

% Example subject
% ID = 1;
% for_plotRegUpdate(allSubBehavData_Split1, samples, ID)

% All subjects
for_plotRegUpdate(allSubBehavData_Split1, samples_split1)

% ----------------------------------------------------
% 4. Compare actual and predicted update distributions for set 2
% ----------------------------------------------------
 
% Take actual parameter values given specified free parameters
df_params_Split2 = table();
if reg_vars.which_vars.beta_0
    df_params_Split2.beta_0 = results_Regression_Split2.parameters.beta_0;
end

if reg_vars.which_vars.beta_1
    df_params_Split2.beta_1 = results_Regression_Split2.parameters.beta_1;
end

if reg_vars.which_vars.beta_2
    df_params_Split2.beta_2 = results_Regression_Split2.parameters.beta_2;
end

if reg_vars.which_vars.beta_3
    df_params_Split2.beta_3 = results_Regression_Split2.parameters.beta_3;
end

if reg_vars.which_vars.beta_4
    df_params_Split2.beta_4 = results_Regression_Split2.parameters.beta_4;
end

if reg_vars.which_vars.beta_5
    df_params_Split2.beta_5 = results_Regression_Split2.parameters.beta_5;
end

if reg_vars.which_vars.beta_6
    df_params_Split2.beta_6 = results_Regression_Split2.parameters.beta_6;
end

if reg_vars.which_vars.beta_7
    df_params_Split2.beta_7 = results_Regression_Split2.parameters.beta_7;
end

% omikron_0 should be true by default
df_params_Split2.omikron_0 = results_Regression_Split2.parameters.omikron_0;

if reg_vars.which_vars.omikron_1
    df_params_Split2.omikron_1 = results_Regression_Split2.parameters.omikron_1;
end

if reg_vars.which_vars.overshoot_lr
   df_params_Split2.overshoot_lr = results_Regression_Split2.parameters.overshoot_lr;
end

if reg_vars.which_vars.overshoot_prob
   df_params_Split2.overshoot_prob = results_Regression_Split2.parameters.overshoot_prob;
end

% Number of subjects
df_params_Split2.subj_num = (1:n_subj)';

% Sample updates from regression model
n_trials = 120;
samples_split2 = regression.sample_data(df_params_Split2, n_trials, allSubBehavData_Split2);

% Tranlate table to structure
samplesStruct_Split2 = table2struct(samples_split2, 'ToScalar', true);

% Compare actual and predicted updates
% ------------------------------------

% Example subject
% ID = 1;
% for_plotRegUpdate(allSubBehavData_Split1, samples, ID)

% All subjects
for_plotRegUpdate(allSubBehavData_Split2, samples_split2)


% 5. Now compare between these two splits
% 5.1 a visual examination

split1Up = allSubBehavData_Split2.a_t;
split2Up = samplesStruct_Split2.a_t;


% Create figure
figure()
hold on

% Plot histograms
histogram(split1Up, "facecolor", "k", "facealpha", 0.8, 'BinWidth', 0.05, 'Normalization', 'pdf')
histogram(split2Up, "facecolor", "b", "facealpha", 0.5, 'BinWidth', 0.05, 'Normalization', 'pdf')

% Estimate and plot distributions
[f, xi] = ksdensity(split1Up); % Kernel Density Estimation
plot(xi, f, 'r', 'LineWidth', 2, "color", "k"); % Overlay KDE curve
[f, xi] = ksdensity(split2Up); % Kernel Density Estimation
plot(xi, f, 'r', 'LineWidth', 2, "color", "b"); % Overlay KDE curve

% Add legend
legend(["Split 2", "Sample Split 2"])

% 5.2 now we calculate the correlation of the parameters between the splits
titleName = {'Int', 'Fixed LR', 'RU',...
    'CPP', 'Hit', 'Noise',...
    'PE-Visible',  'Omikron 0',...
    'Omikron 1', 'OS LR', 'OS Prob'};

nParams = width(results_Regression_Split1.parameters);
rho = zeros(nParams,1);
pval = zeros(nParams,1);


for i = 1:nParams
    x = results_Regression_Split1.parameters(:,i);
    x = x{:,1};
    y = results_Regression_Split2.parameters(:,i);
    y= y{:,1};
    [rho(i), pval(i)] = corr(x, y, 'Type', 'Spearman', 'Rows', 'complete');
    fprintf('Parameter %s: Spearman rho = %.3f, p = %.4f\n', titleName{i}, rho(i), pval(i))
end



