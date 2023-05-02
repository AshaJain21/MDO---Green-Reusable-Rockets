

% Computing rocket, launch cadence charateristics for pareto front
% solutions
parameters = setup_parameters();
engine_prop_db = readtable("engine-prop-combinations.csv");
reentry_shield_material_db = readtable("reentry_shield_materials.csv");
pareto_solution_outputs = [];

for pareto_solu = 1:2
    disp(pareto_solu)
    x = doe_res(pareto_solu, 3:end);
    engine_prop_1_row = round(x(4));
    engine_prop_2_row = round(x(5));
    reentry_shield_material_row = round(x(6));
    design_variables = setup_designvariables(round(x(1)), round(x(2)), round(x(3)), engine_prop_db(engine_prop_1_row, :), engine_prop_db(engine_prop_2_row, :), reentry_shield_material_db(reentry_shield_material_row, :), x(7), x(8), x(9));
    [launch_cadence, total_rf, total_od, total_gwp, cost, constraints, rocket] = run_model(design_variables, parameters);
    pareto_solution_outputs = [pareto_solution_outputs, struct(rocket=rocket, launch_cadence=launch_cadence)];
end