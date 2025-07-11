function densityPlot(targetGroup)

% Create figure
figure()
hold on



% Plot histograms
histogram(targetGroup, "facecolor", "k", "facealpha", 0.8, 'BinWidth', 0.05, 'Normalization', 'pdf')

% Estimate and plot distributions
[f, xi] = ksdensity(targetGroup); % Kernel Density Estimation
plot(xi, f, 'r', 'LineWidth', 2, "color", "k"); % Overlay KDE curve

% Add legend
legend("Participants' Estimation Error");
end
