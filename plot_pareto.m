clf

trial_num = 1;

objective_vals_unsorted = doe_res(trial_num).fval;
population_scores = doe_res(trial_num).scores;

% objective_vals = sortrows(objective_vals_unsorted, [1,2]);

figure(1)

subplot(2,3,1)
scatter3(objective_vals_unsorted(:,1), objective_vals_unsorted(:,2), objective_vals_unsorted(:,3), 300, 'b.')
xlabel('Radiative Forcing')
ylabel('Ozone Depletion')
zlabel('Cost')

subplot(2,3,2)
scatter3(population_scores(:,1), population_scores(:,2), population_scores(:,3), 300, 'r.')
xlabel('Radiative Forcing')
ylabel('Ozone Depletion')
zlabel('Cost')

subplot(2,3,3)
objective_vals = sortrows(objective_vals_unsorted, [1, 2, 3]);
plot3(objective_vals(:,1), objective_vals(:,2), objective_vals(:,3), 300, 'b.')
xlabel('Radiative Forcing')
ylabel('Ozone Depletion')
zlabel('Cost')

subplot(2,3,4)
objective_vals = sortrows(objective_vals_unsorted, [3,1]);
% scatter(objective_vals(:,1), objective_vals(:,3), 300, '.')
hold on
scatter(population_scores(:,1), population_scores(:,3), 300, 'r');
plot(objective_vals(:,1), objective_vals(:,3), '.-', 'MarkerSize', 16)
hold off
xlabel('Radiative Forcing')
ylabel('Cost')

subplot(2,3,5)
% scatter(objective_vals(:,2), objective_vals(:,3), 300, '.')
objective_vals = sortrows(objective_vals_unsorted, [3,2]);
hold on
scatter(population_scores(:,2), population_scores(:,3), 300, 'r.');
plot(objective_vals(:,2), objective_vals(:,3), '.-', 'MarkerSize', 16)
hold off
xlabel('Ozone Depletion')
ylabel('Cost')

subplot(2,3,6)
% scatter(objective_vals(:,1), objective_vals(:,2), 300, '.')
objective_vals = sortrows(objective_vals_unsorted, [2,1]);
hold on
scatter(population_scores(:,1), population_scores(:,2), 300, 'r.');
plot(objective_vals(:,1), objective_vals(:,2), '.-', 'MarkerSize', 16)
xlabel('Radiative Forcing')
ylabel('Ozone Depletion')