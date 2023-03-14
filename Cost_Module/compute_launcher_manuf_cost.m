function launcher_manuf_cost = compute_launcher_manuf_cost(rocket, parameters, num_stages)
    % Assumptions
    % 1. Always only 2 stages (N=2)

    N = num_stages;
    n = parameters.num_engines_per_stage;

    stg1_total_mass = (rocket.stg1_struct_mass + rocket.stg1_prop_mass);
    stg2_total_mass = (rocket.stg2_struct_mass + rocket.stg2_prop_mass);

    stg1_manuf_cost = n * 5.0 * (stg1_total_mass^0.46) * parameters.f4;
    stg2_manuf_cost = n * 5.0 * (stg2_total_mass^0.46) * parameters.f4;
    stage_manuf_costs = stg1_manuf_cost + stg2_manuf_cost;

    stg1_engine_manuf_costs = n * 2.5 * stg1_total_mass^0.46 * parameters.f4;
    stg2_engine_manuf_costs = n * 2.5 * stg2_total_mass^0.46 * parameters.f4;
    engine_manuf_costs = stg1_engine_manuf_costs + stg2_engine_manuf_costs;

    launcher_manuf_cost = (1.02^N * (stage_manuf_costs + engine_manuf_costs)) * parameters.MY_value;

end