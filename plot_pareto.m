clf

trial_num = 1;

objective_vals_unsorted = doe_res(trial_num).fval;
objective_vals_unsorted(:,2) = objective_vals_unsorted(:,2)./1e5;
objective_vals_unsorted(:,3) = objective_vals_unsorted(:,3)*1e9;

population_scores = doe_res(trial_num).scores;

filtered_populations = unique(mdo_proj_populations, 'rows');
filtered_populations(:, 11) = filtered_populations(:, 11)./1e5;
filtered_populations(:, 12) = filtered_populations(:, 12)*1e9;

%% Limit how much of the dominated designs are shown
od_lim = 0.015;
cost_lim = 3e10;
filtered_populations = filtered_populations( (filtered_populations(:,11) <= od_lim) & (filtered_populations(:, 12) <= cost_lim), :);

Computing rocket, launch cadence charateristics for pareto front
solutions
xopt = doe_res(trial_num).xopt;
parameters = setup_parameters();
engine_prop_db = readtable("engine-prop-combinations.csv");
reentry_shield_material_db = readtable("reentry_shield_materials.csv");
rockets = [];
launch_cadences = [];
struct_launch_cadence = struct;
for pareto_solu = 1:length(xopt)
    x = xopt(pareto_solu, :);
    engine_prop_1_row = round(x(4));
    engine_prop_2_row = round(x(5));
    reentry_shield_material_row = round(x(6));
    design_variables = setup_designvariables(round(x(1)), round(x(2)), round(x(3)), engine_prop_db(engine_prop_1_row, :), engine_prop_db(engine_prop_2_row, :), reentry_shield_material_db(reentry_shield_material_row, :), x(7), x(8), x(9));
    [launch_cadence, total_rf, total_od, total_gwp, cost, constraints, rocket] = run_model(design_variables, parameters);
    rockets(i) = rocket;
    struct_launch_cadence.launch_cadence = launch_cadence;
    launch_cadences(i) = struct_launch_cadence;
end


figure(1)
subplot(1,2,1)
plot3(objective_vals(:,1), objective_vals(:,2), objective_vals(:,3), '.-', 'MarkerSize', 20)
grid on
xlabel('Radiative Forcing')
ylabel('Ozone Depletion')
zlabel('Cost')
title('Plot of Pareto Points Only')

subplot(1,2,2)
objective_vals = sortrows(objective_vals_unsorted, [1, 2, 3]);
plot3(objective_vals(:,1), objective_vals(:,2), objective_vals(:,3), '.-', 'MarkerSize', 20)
hold on
scatter3(filtered_populations(:,10), filtered_populations(:,11), filtered_populations(:,12), 100, 'r.')
hold off
grid on
xlabel('Radiative Forcing')
ylabel('Ozone Depletion')
zlabel('Cost')
title('Plot of Pareto Points (blue) with Dominated Solutions (red)')

figure(2)
subplot(1,3,1)
objective_vals = sortrows(objective_vals_unsorted, [3,1]);
% scatter(objective_vals(:,1), objective_vals(:,3), 300, '.')
plot(objective_vals(:,1), objective_vals(:,3), '.-', 'MarkerSize', 20)
hold on
scatter(filtered_populations(:,10), filtered_populations(:,12), 100, 'r.');
hold off
xlabel('Radiative Forcing')
ylabel('Cost')

subplot(1,3,2)
% scatter(objective_vals(:,2), objective_vals(:,3), 300, '.')
objective_vals = sortrows(objective_vals_unsorted, [3,2]);
plot(objective_vals(:,2), objective_vals(:,3), '.-', 'MarkerSize', 20)
hold on
scatter(filtered_populations(:,11), filtered_populations(:,12), 100, 'r.');
hold off
xlabel('Ozone Depletion')
ylabel('Cost')

subplot(1,3,3)
% scatter(objective_vals(:,1), objective_vals(:,2), 300, '.')
objective_vals = sortrows(objective_vals_unsorted, [2,1]);
plot(objective_vals(:,1), objective_vals(:,2), '.-', 'MarkerSize', 20)
hold on
scatter(filtered_populations(:,10), filtered_populations(:,11), 100, 'r.');
hold off
xlabel('Radiative Forcing')
ylabel('Ozone Depletion')


%% Plotting rocket discrete values in pareto solutions 
engine_prop_db = readtable("engine-prop-combinations.csv");
reentry_shield_material_db = readtable("reentry_shield_materials.csv");

%Stage Reusablility Plot
xopt = doe_res(trial_num).xopt;
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
histogram(reusability_combo);
xlabel("Stage Reusability Configuration");
ylabel("Count");
xticklabels( ["Fully Reusable", "Stage 1 Reusable", "Stage 2 Reusable", "Expendable"]);
title("Reusability of Rocket Among Pareto Front Solutions");

%Stage Radius 
xopt = doe_res(trial_num).xopt;
radius_values = xopt(:, 7);
figure();
histogram(radius_values);
xlabel("Rocket Radius (m)");
ylabel("Count");
title("Rocket Radius in Pareto Front Solutions");

%Stage 1 & 2 Engine-Prop Combos 
xopt = doe_res(trial_num).xopt;
stg1_ep_values = xopt(:, 4);
stg2_ep_values = xopt(:, 5);
unique_ids = unique([stg1_ep_values, stg2_ep_values], 'sorted');
labels = strings(length(unique_ids)) ;
for id_index = 1:length(unique_ids)
    id = unique_ids(id_index);
    engine_name = string(engine_prop_db{id, 1});
    fuel_name = string(engine_prop_db{id, 2});
    oxidizer_name = string(engine_prop_db{id, 3});
    labels(i) = strcat(engine_name, ' \n', fuel_name, '\', oxidizer_name);
end
figure();
histogram(stg1_ep_values); hold on;
histogram(stg2_ep_values); hold off;
xlabel("Stage 1 Engine-Propellant Choice");
xticklabels(labels);
ylabel("Count");
title("Stage Engine-Propellant Choice in Pareto Front Solutions");

%Stage Height Plot
rocket_heights = zeros(1, width(rockets));
for p = 1:width(rockets)
    rocket = rockets(i);
    rocket_heights(p) = rocket.stage1.height + rocket.stage2.height;
end
figure();
histogram(reusability_combo);
xlabel("Rocket Height (m)");
ylabel("Count");
title("Rocket Heights in Pareto Front Solutions");


%Rocket Total Propellant Plot
xopt = doe_res(trial_num).xopt;
stg1_propmass = xopt(:, 8);
stg2_propmass = xopt(:, 9);
total_propmass = stg1_propmass + stg2_propmass;
pareto_front_ids = 1:length(xopt);
figure();
scatter(pareto_front_ids, total_propmass, '--','MarkerSize', 16)











