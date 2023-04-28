%% Set up 
clear; clc;
addpath(genpath(pwd))

trial_num = 1;
selected_pt_num = 2;

load('ga_multiobj_run6.mat')
combined_population = mdo_proj_populations;
objective_vals_unsorted = doe_res(trial_num).fval;
x_opt_combined = doe_res(trial_num).x_opt;
load('ga_multiobj_run7.mat', "mdo_proj_populations", "doe_res");
combined_population = [combined_population;mdo_proj_populations];
objective_vals_unsorted = [objective_vals_unsorted; doe_res(trial_num).fval];
x_opt_combined = [x_opt_combined; doe_res(trial_num).x_opt];

objective_vals_unsorted(:,2) = objective_vals_unsorted(:,2)./1e5;
objective_vals_unsorted(:,3) = objective_vals_unsorted(:,3)*1e9;

pareto_points_combined = [x_opt_combined, objective_vals_unsorted];

population_scores = doe_res(trial_num).scores;

filtered_populations = unique(combined_population, 'rows');
filtered_populations = filtered_populations(:, 1:end-1); %This line removes the last column containing the boolean for whether that point is feasible or not. This is necessary to make the setdiff later in the script work

filtered_populations(:, 11) = filtered_populations(:, 11)./1e4;
filtered_populations(:, 12) = filtered_populations(:, 12)*1e9;

pareto_points_unique = unique(pareto_points_combined, 'rows');
xopt = pareto_points_unique(:, 1:9);
objective_vals_unsorted = pareto_points_unique(:, 10:end);

[objective_vals_unsorted, pareto_point_idxs] = paretoFront( objective_vals_unsorted );

xopt = xopt(pareto_point_idxs, :);

% Limit how much of the dominated designs are shown
% od_lim = 0.15;
% cost_lim = 7e10;
% filtered_populations = filtered_populations( (filtered_populations(:,11) <= od_lim) & (filtered_populations(:, 12) <= cost_lim), :);

%% Computing rocket, launch cadence charateristics for pareto front solutions
pareto_points = [doe_res(trial_num).x_opt, doe_res(trial_num).fval];
pareto_points(:, 11) = pareto_points(:, 11)./1e4;
pareto_points(:, 12) = pareto_points(:, 12)*1e9;

% Code to show pareto point is non-dominated
selected_pareto_point = pareto_points(selected_pt_num, :);
dominated_solutions = setdiff(filtered_populations, selected_pareto_point, 'rows');

dom_matrix = zeros(height(dominated_solutions), 4);

for pt_num = 1:height(dominated_solutions)
    sol = dominated_solutions(pt_num, :);
    dominance_test = zeros(1,4);
    dominance_test(1:3) = [(selected_pareto_point(10) < sol(10)), (selected_pareto_point(11) < sol(11)), (selected_pareto_point(12) < sol(12))];
    dominance_test(4) = sum(dominance_test(1:3));
    dom_matrix(pt_num, :) = dominance_test;
end

% Computing rocket, launch cadence charateristics for pareto front
% solutions
parameters = setup_parameters();
engine_prop_db = readtable("engine-prop-combinations.csv");
reentry_shield_material_db = readtable("reentry_shield_materials.csv");
pareto_solution_outputs = [];

for pareto_solu = 1:length(xopt)
    x = xopt(pareto_solu, :);
    engine_prop_1_row = round(x(4));
    engine_prop_2_row = round(x(5));
    reentry_shield_material_row = round(x(6));
    design_variables = setup_designvariables(round(x(1)), round(x(2)), round(x(3)), engine_prop_db(engine_prop_1_row, :), engine_prop_db(engine_prop_2_row, :), reentry_shield_material_db(reentry_shield_material_row, :), x(7), x(8), x(9));
    [launch_cadence, total_rf, total_od, total_gwp, cost, constraints, rocket] = run_model(design_variables, parameters);
    pareto_solution_outputs = [pareto_solution_outputs, struct(rocket=rocket, launch_cadence=launch_cadence)];
end

%% Ploting Pareto
figure(1)
tiledlayout(1,2)

ax1 = nexttile;
objective_vals = sortrows(objective_vals_unsorted, [1, 2, 3]);
plot3(objective_vals(:,1), objective_vals(:,2), objective_vals(:,3), '.-', 'MarkerSize', 20)
grid on
set(ax1,'Xscale','log','Zscale','log','Yscale','log')
xlabel('Radiative Forcing [W/m^2]', 'FontSize', 14)
ylabel('Ozone Depletion [%]', 'FontSize', 14)
zlabel('Cost [$]', 'FontSize', 14)
title('Plot of Pareto Points Only', 'FontSize', 16)
legend({'Pareto Points/Front'}, 'FontSize', 16)

ax2 = nexttile;
plot3(objective_vals(:,1), objective_vals(:,2), objective_vals(:,3), '.-', 'MarkerSize', 20)
hold on
scatter3(filtered_populations(:,10), filtered_populations(:,11), filtered_populations(:,12), 100, 'r.')
hold off
grid on
xlabel('Radiative Forcing [W/m^2]', 'FontSize', 14)
ylabel('Ozone Depletion [%]', 'FontSize', 14)
zlabel('Cost [$]', 'FontSize', 14)
title('Plot of Pareto Points (blue) with Dominated Solutions (red)', 'FontSize', 16)
legend({'Pareto Points/Front', 'Dominated Solutions'}, 'FontSize', 16)

linkaxes([ax1, ax2], 'xyz')

figure(2)
t = tiledlayout(1,3);
title(t, 'Pairwise Pareto Plots of Ozone Depletion, Radiative Forcing and Cost Objectives', 'FontSize', 22)

ax1 = nexttile;
ax1.FontSize = 16;
objective_vals = sortrows(objective_vals_unsorted, [3,1]);
% scatter(objective_vals(:,1), objective_vals(:,3), 300, '.')
plot(objective_vals(:,1), objective_vals(:,3), '.-', 'MarkerSize', 20)
hold on
scatter(filtered_populations(:,10), filtered_populations(:,12), 100, 'r.');
hold off
xlabel('Radiative Forcing [W/m^2]', 'FontSize', 14)
ylabel('Cost [$]', 'FontSize', 14)
legend({'Pareto Points/Front', 'Dominated Solutions'}, 'FontSize', 14)

ax2 = nexttile;
ax2.FontSize = 16;
% scatter(objective_vals(:,2), objective_vals(:,3), 300, '.')
objective_vals = sortrows(objective_vals_unsorted, [3,2]);
plot(objective_vals(:,2), objective_vals(:,3), '.-', 'MarkerSize', 20)
hold on
scatter(filtered_populations(:,11), filtered_populations(:,12), 100, 'r.');
hold off
xlabel('Ozone Depletion [%]', 'FontSize', 14)
ylabel('Cost [$]', 'FontSize', 14)
legend({'Pareto Points/Front', 'Dominated Solutions'}, 'FontSize', 14)

ax3 = nexttile;
ax3.FontSize = 16;
% scatter(objective_vals(:,1), objective_vals(:,2), 300, '.')
objective_vals = sortrows(objective_vals_unsorted, [2,1]);
plot(objective_vals(:,1), objective_vals(:,2), '.-', 'MarkerSize', 20)
hold on
scatter(filtered_populations(:,10), filtered_populations(:,11), 100, 'r.');
hold off
xlabel('Radiative Forcing [W/m^2]', 'FontSize', 14)
ylabel('Ozone Depletion [%]', 'FontSize', 14)
legend({'Pareto Points/Front', 'Dominated Solutions'}, 'FontSize', 14)

figure(3)
indices = 1:height(dom_matrix);
scatter(indices, dom_matrix(:,4), 100, '.')
ax = gca;
ax.FontSize = 14;
ylim([-1, 4])
title('Plot of Dominance Test Results', 'FontSize', 16)
xlabel('Point ID', 'FontSize', 14)
ylabel('Dominance Test Total Score', 'FontSize', 14)


%% Stage Reusablility Plot
% engine_prop_db = readtable("engine-prop-combinations.csv");
% reentry_shield_material_db = readtable("reentry_shield_materials.csv");
% xopt = doe_res(trial_num).x_opt;
reusability_combo = zeros(1, width(xopt));
for p = 1:length(xopt)
    x= xopt(p, :);
    stg1_reusable = x(2);
    stg2_reusable = x(3);
    if stg1_reusable == 1 && stg2_reusable == 1
        reusability_combo(p) = 1;
    elseif stg1_reusable == 1 && stg2_reusable == 0
        reusability_combo(p) = 2;
    elseif stg1_reusable == 0 && stg2_reusable == 1
        reusability_combo(p) = 3;
    else
        reusability_combo(p) = 4;
    end
end
figure();
histogram(reusability_combo, [0.5, 1.5, 2.5, 3.5, 4.5, 5]);
xlabel("Stage Reusability Configuration");
ylabel("Count");
xticklabels( ["", "Fully Reusable", "", "Stage 1 Reusable", "", "Stage 2 Reusable", "", "Expendable"]);
title("Reusability of Rocket Among Pareto Front Solutions");
%% Stage Radius 
%Stage Radius 
radius_values = xopt(:, 7);
figure();
histogram(radius_values, 3);
xlabel("Rocket Radius (m)");
ylabel("Count");
title("Rocket Radius in Pareto Front Solutions");
%% Stage 1 & 2 Engine-Prop Combos 
stg1_ep_values = xopt(:, 4);
stg2_ep_values = xopt(:, 5);
unique_ids = unique([stg1_ep_values, stg2_ep_values], 'sorted');
labels = strings ;
rebased_data_stg1 = zeros(size(stg1_ep_values));
rebased_data_stg2 = zeros(size(stg2_ep_values));
rebased_value = 1;

for id_index = 1:length(unique_ids)
    id = unique_ids(id_index);
    engine_name = string(engine_prop_db{id, 1});
    fuel_name = string(engine_prop_db{id, 2});
    oxidizer_name = string(engine_prop_db{id, 3});
    labels(end+1) = strcat(engine_name, ' : ', fuel_name, ',', oxidizer_name);
    labels(end+1) = "";
    rebased_data_stg1(stg1_ep_values == id) = rebased_value; 
    rebased_value = rebased_value +1;
end

figure();
histogram(rebased_data_stg1,[0.5, 1.5, 2.5] ); %hold on;
%histogram(stg2_ep_values); 
hold off;
xlabel("Stage 1 & 2 Engine-Propellant Choice");
xticklabels(labels);
xtickangle(0);
ylabel("Count");
title("Stage Engine-Propellant Choice in Pareto Front Solutions");

%% Stage Height Plot
rocket_heights = zeros(1, length(pareto_solution_outputs));
for p = 1:length(pareto_solution_outputs)
    rocket = pareto_solution_outputs(p).rocket;
    rocket_heights(p) = rocket.stage1.height + rocket.stage2.height;
end
figure();
histogram(rocket_heights, 10);
xlabel("Rocket Height (m)");
ylabel("Count");
title("Rocket Heights in Pareto Front Solutions");


%% Rocket Total Propellant Plot
stg1_propmass = xopt(:, 8);
stg2_propmass = xopt(:, 9);
total_propmass = stg1_propmass + stg2_propmass;
pareto_front_ids = 1:length(xopt);
figure();
scatter(pareto_front_ids, total_propmass, 16)

%% Launch Cadence Plots
colors = ['r', 'b', 'k', 'g', 'c', 'm', 'y', "#7E2F8E", "#a3957e", "#9F2B68"];
figure()
for j = 1:length(pareto_solution_outputs)
    launch_cadence = pareto_solution_outputs(j).launch_cadence;
    cumulative_launch_cadence = cumsum(launch_cadence(1,:));
    loglog(cumulative_launch_cadence, 'o', "MarkerSize",15) % "MarkerEdgeColor" colors(j)
    hold on
end
legend_labels = append('Pareto #', string(1:length(pareto_solution_outputs)));
legend(legend_labels, 'FontSize', 16)
xlabel('Launch ID', 'FontSize', 16)
ylabel('Number of months since start when launch occurrs', 'FontSize', 16)
title('Launch Cadences for Each Trial', 'FontSize', 16)
ax=gca;
ax.FontSize = 20;
grid on
hold off









