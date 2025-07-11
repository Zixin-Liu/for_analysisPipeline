function compareBIC(results1, results2)
% This compare between models
BIC1 = getBIC(results1);
BIC2 = getBIC(results2);

% Display results
fprintf('Model 1 BIC: %.2f\n', sum(BIC1));
fprintf('Model 2 BIC: %.2f\n', sum(BIC2));

% Model comparison
if sum(BIC1) < sum(BIC2)
    disp('Model 1 is preferred based on BIC.');
else
    disp('Model 2 is preferred based on BIC.');
end

plotBICDifference(BIC1, BIC2);


function BIC = getBIC(results)
% This generates the BIC value

numParticipant = length(results.llh);

for i = 1:numParticipant
    BIC(i) = 2 * results.llh(i) + width(results.parameters) * log(240);
end


end

function plotBICDifference(BIC1, BIC2)
% Plots the difference in BIC between two models per participant

diffBIC = BIC2 - BIC1; % Positive = Model 1 better
numParticipants = length(diffBIC);

figure;
b = bar(diffBIC);

% Color bars based on sign
b.FaceColor = 'flat';
for i = 1:numParticipants
    if diffBIC(i) > 0
        b.CData(i,:) = [0.2, 0.6, 1.0];  % Blue: Model 1 better
    else
        b.CData(i,:) = [1.0, 0.4, 0.4];  % Red: Model 2 better
    end
end

xlabel('Participant');
ylabel('BIC Difference (Model 2 - Model 1)');
title('BIC Difference per Participant');
xticks(1:numParticipants);
grid on;
line(xlim, [0 0], 'Color', 'k', 'LineStyle', '--'); % zero line
legend({'Model 1 Better', 'Model 2 Better'}, 'Location', 'northeast');
end


end
