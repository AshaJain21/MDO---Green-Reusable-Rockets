function prop_cost = calculate_prop_cost(rocket, design_variables, parameters)
    stg1_prop = design_variables.stage1.engine_prop(2);
    stg2_prop = design_variables.stage2.engine_prop(2);

    prop_unit_costs = [parameters.prop_unit_costs.Cost(strcmp(parameters.prop_unit_costs.Propellant, stg1_prop)), parameters.prop_unit_costs.Cost(strcmp(parameters.prop_unit_costs.Propellant, stg1_prop))];
    prop_masses = [rocket.stage1.mprop, rocket.stage2.mprop];
    prop_cost = sum(prop_masses .* prop_unit_costs);
end