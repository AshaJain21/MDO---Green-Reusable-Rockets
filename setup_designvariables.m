function design_variables = setup_designvariables(num_of_launches, reusable_stage_1, reusable_stage_2, engine_prop_1, engine_prop_2, reentry_shield_material, rocket_radius)
    design_variables.num_of_launches = num_of_launches;
    design_variables.reusable_stages = [reusable_stage_1, reusable_stage_2] ;
    design_variables.engines_propellant = [engine_prop_1, engine_prop_2]; 
    design_variables.reentry_shield_material = reentry_shield_material;
    design_variables.rocket_radius = rocket_radius;
end