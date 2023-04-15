function penalized_cost = run_model_sa(x)
    warning('OFF', 'MATLAB:table:ModifiedVarnames');
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

     if isfile('sa_rocket_results_ga.mat')
         load('sa_rocket_results_ga');
         rockets_all = [rockets_all, rocket];
     else
         rockets_all = rocket;
     end
    
     save('sa_rocket_results_ga', 'rockets_all');
    [g, h] = calculate_penalties(constraints);
    penalized_cost  = sum(cost(1, :)) + g + h;

end

function [g, h] = calculate_penalties(constraints)
   g = 0;
   h = 0;
    %Inequality Constraints 
    g = g + max(0, constraints.launch_cadence);
%     g = g + max(0, constraints.max_cost_year);
    g = g + max(0, constraints.rocket_height);
    g = g + max(0, constraints.payload_height);
    g = g + max(0, constraints.min_stg1_num_engines);
    g = g + max(0, constraints.max_stg1_num_engines);
    g = g + (max(0, constraints.eng_stg1_rocket_size)*100);
    g = g + (max(0, constraints.eng_stg2_rocket_size)*100);

    %Equality Constraints 
    h = h + (constraints.mprop1)^2;
    h = h + (constraints.mprop2) ^2;

end