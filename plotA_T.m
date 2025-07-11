function plotA_T(allSubBehavData, samples)
% This is a simple function that takes the actual UP and
% simulated UP and calculate spearman's correlation with
% according graph generated.


realAT = allSubBehavData.a_t;     
predAT = samples.a_t;    
% Ensure the et does not contain NAN

valid_idx = ~isnan(realAT) & ~isnan(predAT);
realAT = realAT(valid_idx);
predAT = predAT(valid_idx);

% Replace with your own circular data in [-pi, pi]
x = realAT;
y = predAT;

% Compute circular-circular correlation
[rho, pval] = circ_corrcc(x, y);

% 2D histogram (joint density)
edges = linspace(-pi, pi, 100);
[N, Xedges, Yedges] = histcounts2(x, y, edges, edges);

% Plot joint density heatmap
figure('Position', [100 100 800 700]);
imagesc(edges, edges, N');
axis xy;
axis square;
xlabel('real UP');
ylabel('predicted UP');
title('Circular-Circular Joint Density with Correlation');
colormap hot;
colorbar;

if pval >= 0.001

    % Annotate correlation
    text(-pi + 0.2, pi - 0.4, sprintf('\\rho_{circ} = %.2f, p = %.3g', rho, pval), ...
    'Color', 'white', 'FontSize', 14, 'FontWeight', 'bold', 'BackgroundColor', 'black');
else
    % Annotate correlation
    text(-pi + 0.2, pi - 0.4, sprintf('\\rho_{circ} = %.2f, p < 0.001', rho), ...
    'Color', 'white', 'FontSize', 14, 'FontWeight', 'bold', 'BackgroundColor', 'black');

% ---------- Inset Polar Plot with Direction Vector ----------
% Compute mean phase difference vector
% theta_diff = angle(exp(1i*(x - y)));  % difference wrapped to [-pi, pi]
% mean_dir = angle(mean(exp(1i * theta_diff)));
% rho_length = abs(rho);  % correlation strength

% % Create inset
% axes('Position', [0.65, 0.65, 0.25, 0.25]);  % inset position
% polarplot([0 mean_dir], [0 rho_length], 'r-', 'LineWidth', 2);
% rlim([0 1]);
% title('Corr. Dir.');
% set(gca, 'RTick', []);











end