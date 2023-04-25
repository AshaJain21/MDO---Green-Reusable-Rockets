function penalized_cost = run_model_derivative(x)
    %Set discrete design variables
    %global scaling_vec
    %xunscaled = x./scaling_vec;

    %# launch,reuse1,reuse2,engine1,engine2,re-entry mat
    %rockets_all = load(rocketall)%readstruct("rocket.mat","FileType",'auto');
    num_launches = 410;
    stage1_boolean = 1;
    stage2_boolean = 0;
    engine_prop_1_row = 11; %
    engine_prop_2_row = 11;
    reentry_shield_material_row = 9;
    warning('OFF', 'MATLAB:table:ModifiedVarnames');
    engine_prop_db = readtable("engine-prop-combinations.csv");
    reentry_shield_material_db = readtable("reentry_shield_materials.csv");

    design_variables = setup_designvariables(num_launches, stage1_boolean,stage2_boolean,...
        engine_prop_db(engine_prop_1_row, :), engine_prop_db(engine_prop_2_row, :), ...
        reentry_shield_material_db(reentry_shield_material_row, :), x(1), x(2), x(3));
    parameters = setup_parameters();
    [~, ~, ~, ~, cost, ~,rocket] = run_model(design_variables, parameters);
    
    %[g, h] = calculate_penalties(constraints);
    g=0;
    h=0;
    penalized_cost  = sum(cost(1, :)) + g + h;
    
    if isfile('rocket_results.mat')
         load('rocket_results');
         rockets_all = [rockets_all, rocket];
    else
         rockets_all = rocket;
    end
    %writestruct(rocketupdate,"rocket.dat","FileType",'auto');
    save('rocket_results', 'rockets_all');
end

function [g, h] = calculate_penalties(constraints)
   g = 0;
   h = 0;
    %Inequality Constraints 
    g = g + max(0, constraints.launch_cadence);
    g1= max(0, constraints.launch_cadence);
    g = g + max(0, constraints.max_cost_year);
    g2 = max(0, constraints.launch_cadence);
    g = g + max(0, constraints.rocket_height);
    g3 =max(0, constraints.rocket_height);
    g = g + max(0, constraints.payload_height);
    g4 = max(0, constraints.payload_height);
    g = g + max(0, constraints.min_stg1_num_engines);
    g5 = max(0, constraints.min_stg1_num_engines);
    g = g + max(0, constraints.max_stg1_num_engines);
    g6 = max(0, constraints.max_stg1_num_engines);
           %[launch cad, cost/yr, rockh, payh, minst1_eng,maxst1_eng]
    gvals = [g1,            g2,     g3,   g4,   g5,         g6];
    %dlmwrite('gvals2_3.dat',gvals, '-append');
    %Equality Constraints 
    h = h + (constraints.mprop1)^2;
    h = h + (constraints.mprop2) ^2;

end