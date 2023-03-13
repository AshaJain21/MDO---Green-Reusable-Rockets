function prop_cost = calculate_prop_cost(prop, prop_mass, parameters)
    prop_unit_cost = parameters.prop_cost(prop);
    prop_cost = prop_mass * prop_unit_cost;
end