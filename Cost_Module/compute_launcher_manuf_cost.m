function launcher_manuf_cost = compute_launcher_manuf_cost(rocket)
    % Assumptions
    % 1. Always only 2 stages (N=2)

    N = 2;
    MY = 120000; %USD, most recent value from Koelle paper
    n = 4; %Number of engines per stage 

    stg1_total_mass = (rocket.stg1_struct_mass + stg1_prop_mass);
    stg2_total_mass = (rocket.stg2_struct_mass + stg2_prop_mass);

    stg1_manuf_cost = n * 5.0 * (stg1_total_mass^0.46) * f4;
    stg2_manuf_cost = n * 5.0 * (stg2_total_mass^0.46) * f4;
    stage_manuf_costs = stg1_manuf_cost + stg2_manuf_cost;

    stg1_engine_manuf_costs = n * 2.5 * stg1_total_mass^0.46 * f4;
    stg2_engine_manuf_costs = n * 2.5 * stg2_total_mass^0.46 * f4;
    engine_manuf_costs = stg1_engine_manuf_costs + stg2_engine_manuf_costs;

    launcher_manuf_cost = (1.02^N * (stage_manuf_costs + engine_manuf_costs)) * MY;

end