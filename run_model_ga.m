function penalized_cost = run_model_ga(x)
    engine_prop_1_row = round(x(4));
    engine_prop_2_row = round(x(5));
    engine_prop_db = readtable("engine-prop-combinations.csv");
    reentry_shield_material_row = round(x(6));
    reentry_shield_material_db = readtable("reentry_shield_materials.csv");

    design_variables = setup_designvariables(round(x(1)), round(x(2)), round(x(3)), engine_prop_db(engine_prop_1_row, :), engine_prop_db(engine_prop_2_row, :), reentry_shield_material_db(reentry_shield_material_row, :), x(7), x(8), x(9));
    parameters = setup_parameters();
    g = 0;
    h = 0;
    [~, ~, ~, ~, cost, constraints, rocket] = run_model(design_variables, parameters);

%     if isfile('rocket_results_ga.mat')
%         load('rocket_results_ga');
%         rockets_all = [rockets_all, rocket];
%     else
%         rockets_all = rocket;
%     end
%     save('rocket_results_ga', 'rockets_all');
    
    [g, h] = calculate_penalties(constraints, parameters, rocket, design_variables);

    penalized_cost  = sum(cost(1, :)) + g + h;
end

function [g, h] = calculate_penalties(constraints, parameters, rocket, design_variables)
   g = 0;
   h = 0;
    %Inequality Constraints 
    g = g + (max(0, constraints.launch_cadence)/(parameters.delivery_time * 12));
    g = g + (max(0, constraints.max_cost_year)/parameters.max_cost_per_year);
    g = g + (max(0, constraints.rocket_height)/parameters.max_rocket_height);
    
    total_rocket_height = rocket.stage1.height + rocket.stage2.height;
    g = g + (max(0, constraints.payload_height)/(parameters.max_payload_height_fraction*total_rocket_height));

    g = g + (max(0, constraints.min_stg1_num_engines)/parameters.min_num_engines);
    g = g + (max(0, constraints.max_stg1_num_engines)/parameters.max_num_engines);
    g = g + (max(0, constraints.eng_stg1_rocket_size)/design_variables.rocket_ri);
    g = g + (max(0, constraints.eng_stg2_rocket_size)/design_variables.rocket_ri);

    %Equality Constraints 
    h = h + (constraints.mprop1/rocket.stage1.mprop)^2;
    h = h + (constraints.mprop2/rocket.stage1.mprop) ^2;

end