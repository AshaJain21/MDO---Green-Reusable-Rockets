%% Set up 
clear; clc;
clf
addpath(genpath(pwd))

trial_num = 1;
selected_pt_num = 2;
use_optimal_points_all_trials = 1;
data_file_1 = 'ga_multiobj_run8.mat';
additional_data_files_2 = {'ga_multiobj_run9.mat'};

load(data_file_1);
combined_population = mdo_proj_populations;

for i = 1:length(additional_data_files_2)
    data_file_2 = additional_data_files_2{i};
    load(data_file_2, "mdo_proj_populations");    
    combined_population = [combined_population;mdo_proj_populations];
end

filtered_populations = unique(combined_population, 'rows');
filtered_populations = filtered_populations(:, 1:end-1); %This line removes the last column containing the boolean for whether that point is feasible or not. This is necessary to make the setdiff later in the script work
filtered_populations(:, 11) = filtered_populations(:, 11)./1e4;
filtered_populations(:, 12) = filtered_populations(:, 12);

[objective_vals_unsorted, pareto_point_idxs] = paretoFiltering(filtered_populations);
xopt = filtered_populations(pareto_point_idxs, 1:9);
pareto_points = [xopt, objective_vals_unsorted];

% Limit how much of the dominated designs are shown
od_lim = 0.15;
cost_lim = 20;
filtered_populations = filtered_populations( (filtered_populations(:,11) <= od_lim) & (filtered_populations(:, 12) <= cost_lim), :);

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

%% Computing rocket, launch cadence charateristics for pareto front solutions
parameters = setup_parameters();
engine_prop_db = readtable("engine-prop-combinations.csv");
reentry_shield_material_db = readtable("reentry_shield_materials.csv");
pareto_solution_outputs = [];

for pareto_solu = 1:height(xopt)
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
plot3(objective_vals(:,1), objective_vals(:,2), objective_vals(:,3), 'r.-', 'MarkerSize', 20)
grid on
ax1.FontSize = 14;
set(ax1,'Xscale','log','Zscale','log','Yscale','log')
xlabel('Radiative Forcing [mW/m^2]', 'FontSize', 14)
ylabel('Ozone Depletion [%]', 'FontSize', 14)
zlabel('Cost [$USD]', 'FontSize', 14)
title('Plot of Pareto Points Only', 'FontSize', 16)
legend({'Approx. Pareto Front'}, 'FontSize', 16)

ax2 = nexttile;
scatter3(filtered_populations(:,10), filtered_populations(:,11), filtered_populations(:,12), 25, '.', 'MarkerEdgeColor', "#0072BD")
hold on
plot3(objective_vals(:,1), objective_vals(:,2), objective_vals(:,3), 'r.-', 'MarkerSize', 20)
hold off
grid on
ax2.FontSize = 14;
set(ax2,'Xscale','log','Zscale','log','Yscale','log')
xlabel('Radiative Forcing [mW/m^2]', 'FontSize', 14)
ylabel('Ozone Depletion [%]', 'FontSize', 14)
zlabel('Cost [$USD]', 'FontSize', 14)
title('Plot of Pareto Points (Red) With Dominated Solutions (Blue)', 'FontSize', 16)
legend({'Dominated Solutions', 'Approx. Pareto Front'}, 'FontSize', 16)

linkaxes([ax1, ax2], 'xyz')

figure(10)
ax=gca;
scatter3(filtered_populations(:,10), filtered_populations(:,11), filtered_populations(:,12), 25, '.', 'MarkerEdgeColor', "#0072BD")
hold on
plot3(objective_vals(:,1), objective_vals(:,2), objective_vals(:,3), 'r.-', 'MarkerSize', 20)
hold off
grid on
ax.FontSize = 16;
set(ax,'Xscale','log','Zscale','log','Yscale','log')
xlabel('Radiative Forcing [mW/m^2]', 'FontSize', 18)
ylabel('Ozone Depletion [%]', 'FontSize', 18)
zlabel('Cost [$USD]', 'FontSize', 18)
title('Plot of Pareto Points (Red) With Dominated Solutions (Blue)', 'FontSize', 20)
legend({'Dominated Solutions', 'Approx. Pareto Front'}, 'FontSize', 18)


figure(2)
t = tiledlayout(1,2);
title(t, 'Pairwise Pareto Plots of Ozone Depletion, Radiative Forcing and Cost Objectives', 'FontSize', 22)

ax3 = nexttile;
ax3.FontSize = 18;
objective_vals = sortrows(objective_vals_unsorted, [3,1]);
% scatter(objective_vals(:,1), objective_vals(:,3), 300, '.')
plot(objective_vals(:,1), objective_vals(:,3), 'r.-', 'MarkerSize', 20)
hold on
scatter(filtered_populations(:,10), filtered_populations(:,12), 25, '.', 'MarkerEdgeColor', "#0072BD", 'MarkerEdgeAlpha', 0.2);
hold off
xlabel('Radiative Forcing [mW/m^2]', 'FontSize', 18)
ylabel('Cost [$USD]', 'FontSize', 18)
legend({'Pareto Points/Front', 'Dominated Solutions'}, 'FontSize', 18)

ax4 = nexttile;
ax4.FontSize = 18;
% scatter(objective_vals(:,2), objective_vals(:,3), 300, '.')
objective_vals = sortrows(objective_vals_unsorted, [3,2]);
plot(objective_vals(:,2), objective_vals(:,3), 'r.-', 'MarkerSize', 20)
hold on
scatter2 = scatter(filtered_populations(:,11), filtered_populations(:,12), 25, '.', 'MarkerEdgeColor', "#0072BD");
hold off
alpha(scatter2, 0.1)
xlabel('Ozone Depletion [%]', 'FontSize', 18)
ylabel('Cost [$USD]', 'FontSize', 18)
legend({'Pareto Points/Front', 'Dominated Solutions'}, 'FontSize', 18)

% ax5 = nexttile;
% ax5.FontSize = 18;
% % scatter(objective_vals(:,1), objective_vals(:,2), 300, '.')
% objective_vals = sortrows(objective_vals_unsorted, [2,1]);
% plot(objective_vals(:,1), objective_vals(:,2), 'r.-', 'MarkerSize', 20)
% hold on
% scatter3 = scatter(filtered_populations(:,10), filtered_populations(:,11), 25, '.', 'MarkerEdgeColor', "#0072BD");
% alpha(scatter3, 0.1)
% hold off
% xlabel('Radiative Forcing [mW/m^2]', 'FontSize', 18)
% ylabel('Ozone Depletion [%]', 'FontSize', 18)
% legend({'Pareto Points/Front', 'Dominated Solutions'}, 'FontSize', 18)

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
for p = 1:height(xopt)
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
figure(4);
histogram(reusability_combo, [0.5, 1.5, 2.5, 3.5, 4.5, 5]);
xlabel("Stage Reusability Configuration");
ylabel("Count");
xticklabels( ["", "Fully Reusable", "", "Stage 1 Reusable", "", "Stage 2 Reusable", "", "Expendable"]);
title("Reusability of Rocket Among Pareto Front Solutions");
%% Stage Radius 
%Stage Radius 
radius_values = xopt(:, 7);
figure(5);
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

figure(6);
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
figure(7);
histogram(rocket_heights, 10);
xlabel("Rocket Height (m)");
ylabel("Count");
title("Rocket Heights in Pareto Front Solutions");


%% Rocket Total Propellant Plot
stg1_propmass = xopt(:, 8);
stg2_propmass = xopt(:, 9);
total_propmass = stg1_propmass + stg2_propmass;
pareto_front_ids = 1:height(xopt);
figure(8);
scatter(pareto_front_ids, total_propmass, 16)

%% Launch Cadence Plots
colors = ['r', 'b', 'k', 'g', 'c', 'm', 'y', "#7E2F8E", "#a3957e", "#9F2B68"];
figure(9)
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

function [objective_vals, pareto_point_idxs] = paretoFiltering(input_pts)
    is_dominated = zeros(height(input_pts), 1);

    for pt_num = 1:height(input_pts)
        if is_dominated(pt_num) == 0
            reference_obj = input_pts(pt_num, 10:12);

            for comparison_pt = 1:height(input_pts)
                if (is_dominated(comparison_pt) == 0) && (pt_num ~= comparison_pt)
                    comp_res = reference_obj < input_pts(comparison_pt, 10:12);
                    if sum(comp_res) == 3
                        is_dominated(comparison_pt) = 1;
                    end
                end
            end
        end
    end

    pareto_point_idxs = find(is_dominated == 0);

    input_pts(:, end+1) = is_dominated;
    objective_vals = input_pts(input_pts(:,end)==0, 10:12);

    
end










