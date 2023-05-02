clear

%One time setup
parameters = setup_parameters();

%Loading database data
engine_prop_db = readtable("engine-prop-combinations.csv");
reentry_shield_material_db = readtable("reentry_shield_materials.csv");

designs_to_rerun = table2array(readtable("a3_rerun_designs.csv"));
results_col = zeros(height(designs_to_rerun), 1);
designs_to_rerun(:, end+1) = results_col;

for i = 1:height(designs_to_rerun)
    %Set up design variables 
    num_of_launches = designs_to_rerun(i, 1);
    %Engine Prop data 
    engine_prop_1 = engine_prop_db(designs_to_rerun(i, 2), :);
    engine_prop_1.Fuel= string(engine_prop_1.Fuel);
    engine_prop_1.Engine = string(engine_prop_1.Engine);
    engine_prop_1.Oxidizer = string(engine_prop_1.Oxidizer);
    
    engine_prop_2 = engine_prop_db(designs_to_rerun(i, 3), :);
    engine_prop_2.Fuel= string(engine_prop_2.Fuel);
    engine_prop_2.Engine = string(engine_prop_2.Engine);
    engine_prop_2.Oxidizer = string(engine_prop_2.Oxidizer);
    
    reentry_shield_material = reentry_shield_material_db(designs_to_rerun(i, 4), :);
    rocket_radius = designs_to_rerun(i, 5);
    
    reusable_stage_1 = designs_to_rerun(i, 6);
    reusable_stage_2 = designs_to_rerun(i, 7);
    
    mprop1_guess = 3e6;
    mprop2_guess = 1e6;
    
    design_variables = setup_designvariables(num_of_launches, reusable_stage_1, reusable_stage_2, engine_prop_1, engine_prop_2, reentry_shield_material, rocket_radius, mprop1_guess, mprop2_guess);
    
    [launch_cadence, total_rf, total_od, total_gwp, cost, constraints, rocket] = run_model(design_variables, parameters);

    designs_to_rerun(i, 8) = sum(cost(1, :));

end