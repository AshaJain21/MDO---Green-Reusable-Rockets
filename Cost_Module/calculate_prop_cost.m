function total_prop_cost = calculate_prop_cost(rocket, design_variables, parameters)
    prop_types = [design_variables.stage1.engine_prop.Fuel, design_variables.stage2.engine_prop.Fuel; design_variables.stage1.engine_prop.Oxidizer, design_variables.stage2.engine_prop.Oxidizer];
    MRs = [design_variables.stage1.engine_prop.O_F, design_variables.stage2.engine_prop.O_F];
    oxidizer_portion = MRs./(MRs+1);
    fuel_portions = [(1-oxidizer_portion); oxidizer_portion];
    fuel_masses = [rocket.stage1.mprop, rocket.stage2.mprop] .* fuel_portions;
    unit_costs = zeros(2,2);
    
    for stage = 1:2
        for fuel = 1:2
            unit_costs(stage, fuel) = parameters.propellant_properties.Cost(strcmp(parameters.propellant_properties.Propellant, prop_types(stage, fuel)));
        end
    end
    
    prop_costs = fuel_masses.*unit_costs;
    total_prop_cost = sum(sum(abs(prop_costs)));
end