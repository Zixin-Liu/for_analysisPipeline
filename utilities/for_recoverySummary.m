function for_recoverySummary(trueParams, estParams, selVariables, titleName, gridSize)
% FOR_RECOVERYSUMMARY This function creates a simple plot showing
% parameter values
%
%   Input
%       trueParams: True parameter values
%       estParams: Estimated parameter values
%       selVariables: Selected variables
%       titleName: Title variable names
%       gridSize: Plot grid
%
%   Output
%       None

% Create figure
figure();

% Cycle over parameters
for i = 1:size(estParams.parameters, 2)

    % Create subplot
    subplot(gridSize(1), gridSize(2), i);
    hold on

    % Extract parameter values
    trueParamValue = trueParams.(selVariables{i});
    estParamValue = estParams.parameters.(selVariables{i});

    % Plot parameters
    plot(trueParamValue, estParamValue, 'o')
    [r, p] = corr(trueParamValue, estParamValue, 'type', 'Spearman');
    % title([titleName{i} ': r=' num2str(round(r, 2)) ', p=' num2str(p, '%.3f')])
    title([titleName{i} ': r=' num2str(round(r, 2))]);
    
    % Add axis labels
    xlabel('True parameter')
    ylabel('Estimated parameter')

end
end