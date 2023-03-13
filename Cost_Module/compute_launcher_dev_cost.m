function launcher_dev_cost = compute_launcher_dev_cost(rocket)
    % Assumptions
    % 1. Assumes no engine development costs

    MY = 120000; %USD, most recent value from Koelle paper

    stg1_total_mass = rocket.stg1_struct_mass + rocket.stg1_prop_mass;
    stg2_total_mass = rocket.stg2_struct_mass + rocket.stg2_prop_mass;

    stage_dev_cost = get_stage_dev_cost(rocket.stg1_reuse, stg1_total_mass, rocket.stg1_prop_mass) + get_stage_dev_cost(rocket.stg2_reuse, stg2_total_mass, rocket.stg2_prop_mass);

    launcher_dev_cost = (1.1 * stage_dev_cost) * MY;

end