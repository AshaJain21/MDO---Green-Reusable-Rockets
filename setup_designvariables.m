function design_variables = setup_designvariables(num_of_launches, reusable_stage_1, reusable_stage_2, engine_prop_1, engine_prop_2, reentry_shield_material, rocket_radius, mprop1_guess, mprop2_guess)
    design_variables.num_of_launches = num_of_launches;
    design_variables.stage1.reusable = reusable_stage_1;
    design_variables.stage2.reusable = reusable_stage_2;
    design_variables.stage1.engine_prop = engine_prop_1;
    design_variables.stage2.engine_prop = engine_prop_2;  
    design_variables.stage2.reentry_shield_material = reentry_shield_material;
    design_variables.rocket_ri = rocket_radius;
    design_variables.mprop1_guess = mprop1_guess;
    design_variables.mprop2_guess = mprop2_guess;
end