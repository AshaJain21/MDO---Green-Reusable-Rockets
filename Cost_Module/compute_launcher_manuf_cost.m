function launcher_manuf_cost = compute_launcher_manuf_cost(parameters, num_stages, total_masses)
    % Assumptions
    % 1. Always only 2 stages (N=2)

    N = num_stages;
    n = parameters.num_engines_per_stage;

    stg1_manuf_cost = n * 5.0 * (total_masses(1)^0.46) * parameters.f4;
    stg1_engine_manuf_costs = n * 2.5 * total_masses(1)^0.46 * parameters.f4;
    
    stg2_manuf_cost = n * 5.0 * (total_masses(2)^0.46) * parameters.f4;
    stg2_engine_manuf_costs = n * 2.5 * total_masses(2)^0.46 * parameters.f4;

    stage_costs = [(stg1_manuf_cost + stg1_engine_manuf_costs); (stg2_manuf_cost + stg2_engine_manuf_costs)];

    launcher_manuf_cost = 1.02^N * stage_costs * parameters.MY_value;

end