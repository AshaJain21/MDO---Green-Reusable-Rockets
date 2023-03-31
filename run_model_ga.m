function [cost] = run_model_ga(x)
    design_variables = setup_designvariables(round(x(1)), round(x(2)), round(x(3)), round(x(4)), round(x(5)), round(x(6)), x(7), x(8), x(9));
    parameters = setup_parameters();
    [~, ~, ~, ~, cost, constraints] = run_model(design_variables, parameters);
    [g, h] = calculate_penalties(constraints);
    cost  = cost + g + h;

end

function [g, h] = calculate_penalties(constraints)
   g = 0;
   h = 0;
    %Inequality Constraints 
    g = g + max(0, constraints.launch_cadence);
    g = g + max(0, constraints.max_cost_year);
    g = g + max(0, constraints.rocket_height);
    g = g + max(0, constraints.min_stg1_num_engines);
    g = g + max(0, constraints.max_stg1_num_engines);

    %Equality Constraints 
    h = h + (constraints.mprop1)^2;
    h = h + (constraints.mprop2) ^2;

end