classdef ForRegVars
    %FORREGVARS This class specifies the instance variables
    % of the circular regression model

    properties

        % Coefficient names
        beta_0 = 'beta_0';
        beta_1 = 'beta_1';
        beta_2 = 'beta_2';
        beta_3 = 'beta_3';
        beta_4 = 'beta_4';
        beta_5 = 'beta_5';
        beta_6 = 'beta_6';
        beta_7 = 'beta_7';
        omikron_0 = 'omikron_0';
        omikron_1 = 'omikron_1';
        overshoot_lr = 'overshoot_lr';
        overshoot_prob = 'overshoot_prob';

        % Start point of the parameters
        beta_0_x0 = 0; % intercept
        beta_1_x0 = 0; % PE
        beta_2_x0 = 0; % RU*PE
        beta_3_x0 = 0; % CPP*PE
        beta_4_x0 = 0; % hit*PE
        beta_5_x0 = 0; % kappa*PE
        beta_6_x0 = 0; % visible*PE
        beta_7_x0 = 0; % visible*EE
        omikron_0_x0 = 10; % motor noise
        omikron_1_x0 = 0.1; % learning-rate noise
        overshoot_lr_x0 = 1.5; % overshoot learning rate
        overshoot_prob_x0 = 0.1 % overshoot component

        % Range of starting points
        beta_0_x0_range = [0, 1];
        beta_1_x0_range = [0, 1];
        beta_2_x0_range = [0, 1];
        beta_3_x0_range = [0, 1];
        beta_4_x0_range = [0, 1];
        beta_5_x0_range = [0, 1];
        beta_6_x0_range = [-1, 1];
        beta_7_x0_range = [0, 1];
        omikron_0_x0_range = [1, 10];
        omikron_1_x0_range = [0, 0.5];
        overshoot_lr_x0_range = [1, 2];
        overshoot_prob_x0_range = [0, 0.5];

        % When prior is used: pior mean
        prior_mean
        beta_0_prior_mean = 0;
        beta_1_prior_mean = 0;
        beta_2_prior_mean = 0;
        beta_3_prior_mean = 0;
        beta_4_prior_mean = 0;
        beta_5_prior_mean = 0;
        beta_6_prior_mean = 0;
        beta_7_prior_mean = 0;
        omikron_0_prior_mean = 5;
        omikron_1_prior_mean = 0.1;
        overshoot_lr_prior_mean = 1.5
        overshoot_prob_prior_mean = 0.1

        % When prior is used: pior width
        % Note these can be tuned for future versions
        prior_width
        beta_0_prior_width = 5;
        beta_1_prior_width = 5;
        beta_2_prior_width = 5;
        beta_3_prior_width = 5;
        beta_4_prior_width = 5;
        beta_5_prior_width = 5;
        beta_6_prior_width = 5;
        beta_7_prior_width = 5;
        omikron_0_prior_width = 10;
        omikron_1_prior_width = 0.1;
        overshoot_lr_prior_width = 5;
        overshoot_prob_prior_width = 5;

        % Parameters that should be estimated
        which_vars = struct()
        regressionComponents

        % Estimation lower boundaries
        lowerBoundaries = struct();

        % Estimation lower boundaries
        upperBoundaries = struct();

        % Oher properties
        n_subj = nan;
        rand_sp = true;
        n_sp = 30;
        usePrior = false;

    end

    methods

        function obj = ForRegVars()
            % Constructor to initialize default agent variables

            % Determine which parameters should be estimated
            obj.which_vars.beta_0 = true; % intercept
            obj.which_vars.beta_1 = true; % PE (fixed learning rate)
            obj.which_vars.beta_2 = true; % interaction PE and RU
            obj.which_vars.beta_3 = true; % interaction PE and CPP
            obj.which_vars.beta_4 = true; % interaction PE and hit
            obj.which_vars.beta_5 = true; % interaction PE and noise condition
            obj.which_vars.beta_6 = true; % interaction PE and visible
            obj.which_vars.beta_7 = true; % interaction EE and visible
            obj.which_vars.omikron_0 = true; % motor noise (independent of PE)
            obj.which_vars.omikron_1 = true; % learning-rate noise (dependent on PE)
            obj.which_vars.overshoot_lr = false; % overshoot learning rate
            obj.which_vars.overshoot_prob = false; % overshoot component
            obj.regressionComponents = [obj.which_vars.beta_0, obj.which_vars.beta_1,...
                obj.which_vars.beta_2, obj.which_vars.beta_3, obj.which_vars.beta_4,...
                obj.which_vars.beta_5, obj.which_vars.beta_6, obj.which_vars.beta_7];

            % Estimation lower boundaries
            obj.lowerBoundaries.beta_0_lb = -3.5;
            obj.lowerBoundaries.beta_1_lb = -3.5;
            obj.lowerBoundaries.beta_2_lb = -3.5;
            obj.lowerBoundaries.beta_3_lb = -3.5;
            obj.lowerBoundaries.beta_4_lb = -3.5;
            obj.lowerBoundaries.beta_5_lb = -3.5;
            obj.lowerBoundaries.beta_6_lb = -3.5;
            obj.lowerBoundaries.beta_7_lb = -3.5;
            obj.lowerBoundaries.omikron_0_lb = 3;  % In Matlab, below 3 seems to be problematic
            obj.lowerBoundaries.omikron_1_x0_lb = 0.0;
            obj.lowerBoundaries.overshoot_lr_x0_lb = 1.0;
            obj.lowerBoundaries.overshoot_prob_x0_lb = 0.0;

            % Estimation upper boundaries
            obj.upperBoundaries.beta_0_up = 3.5;
            obj.upperBoundaries.beta_1_up = 3.5;
            obj.upperBoundaries.beta_2_up = 3.5;
            obj.upperBoundaries.beta_3_up = 3.5;
            obj.upperBoundaries.beta_4_up = 3.5;
            obj.upperBoundaries.beta_5_up = 3.5;
            obj.upperBoundaries.beta_6_up = 3.5;
            obj.upperBoundaries.beta_7_up = 3.5;
            obj.upperBoundaries.omikron_0_ub = 20;
            obj.upperBoundaries.omikron_1_x0_ub = 0.5;
            obj.upperBoundaries.overshoot_lr_x0_ub = 2.0;
            obj.upperBoundaries.overshoot_prob_x0_up = 0.5;

            % All prior means
            obj.prior_mean = [obj.beta_0_prior_mean, obj.beta_1_prior_mean,...
                obj.beta_2_prior_mean, obj.beta_3_prior_mean,...
                obj.beta_4_prior_mean, obj.beta_5_prior_mean,...
                obj.beta_6_prior_mean, obj.beta_7_prior_mean];

            % All prior widths
            obj.prior_width = [obj.beta_0_prior_width, obj.beta_1_prior_width,...
                obj.beta_2_prior_width, obj.beta_3_prior_width,...
                obj.beta_4_prior_width, obj.beta_5_prior_width,...
                obj.beta_6_prior_width, obj.beta_7_prior_width];
        end
    end
end