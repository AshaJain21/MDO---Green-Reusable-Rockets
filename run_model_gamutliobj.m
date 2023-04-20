function objectives = run_model_gamutliobj(x)
    objectives = zeros(1,4);
    engine_prop_1_row = round(x(4));
    engine_prop_2_row = round(x(5));
    engine_prop_db = readtable("engine-prop-combinations.csv");
    reentry_shield_material_row = round(x(6));
    reentry_shield_material_db = readtable("reentry_shield_materials.csv");

    design_variables = setup_designvariables(round(x(1)), round(x(2)), round(x(3)), engine_prop_db(engine_prop_1_row, :), engine_prop_db(engine_prop_2_row, :), reentry_shield_material_db(reentry_shield_material_row, :), x(7), x(8), x(9));
    parameters = setup_parameters();
    g = 0;
    h = 0;
    [~, total_rf, total_od, total_gwp, cost, ~, ~] = run_model(design_variables, parameters);
%     objectives(1) = total_rf;
    objectives(1) = total_od;
    objectives(2) = total_gwp; 
    objectives(3) = sum(cost(1, :));
end

