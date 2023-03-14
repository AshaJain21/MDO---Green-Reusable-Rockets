function prop_cost = calculate_prop_cost(rocket, design_variables, parameters)
    prop_unit_costs = [parameters.prop_unit_costs(design_variables.engines_propellant(1)), parameters.prop_unit_costs(design_variables.engines_propellant(2))];
    prop_masses = [rocket.stg1_prop_mass, rocket.stg2_prop_mass];
    prop_cost = sum(prop_masses .* prop_unit_costs);
end