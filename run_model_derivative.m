function penalized_cost = run_model_derivative(x)
    %Set discrete design variables 
    num_launches = 45;
    stage1_boolean = 0;
    stage2_boolean = 0;
    engine_prop_1_row = 4;
    engine_prop_2_row = 8;
    reentry_shield_material_row = 9;
    warning('OFF', 'MATLAB:table:ModifiedVarnames');
    engine_prop_db = readtable("engine-prop-combinations.csv");
    reentry_shield_material_db = readtable("reentry_shield_materials.csv");

    design_variables = setup_designvariables(num_launches, stage1_boolean,stage2_boolean, engine_prop_db(engine_prop_1_row, :), engine_prop_db(engine_prop_2_row, :), reentry_shield_material_db(reentry_shield_material_row, :), x(1), x(2), x(3));
    parameters = setup_parameters();
    [~, ~, ~, ~, cost, constraints] = run_model(design_variables, parameters);
    [g, h] = calculate_penalties(constraints);
    penalized_cost  = sum(cost(1, :)) + g + h;

end

function [g, h] = calculate_penalties(constraints)
   g = 0;
   h = 0;
    %Inequality Constraints 
    g = g + max(0, constraints.launch_cadence);
    g = g + max(0, constraints.max_cost_year);
    g = g + max(0, constraints.rocket_height);
    g = g + max(0, constraints.payload_height);
    g = g + max(0, constraints.min_stg1_num_engines);
    g = g + max(0, constraints.max_stg1_num_engines);

    %Equality Constraints 
    h = h + (constraints.mprop1)^2;
    h = h + (constraints.mprop2) ^2;

end