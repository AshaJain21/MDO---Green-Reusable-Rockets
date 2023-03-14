function launcher_dev_cost = compute_launcher_dev_cost(rocket, design_variables, parameters)
    % Assumptions
    % 1. Assumes no engine development costs

    stg1_total_mass = rocket.stg1_struct_mass + rocket.stg1_prop_mass;
    stg2_total_mass = rocket.stg2_struct_mass + rocket.stg2_prop_mass;

    stage_dev_cost = get_stage_dev_cost(design_variables.reusable_stages(1), stg1_total_mass, rocket.stg1_prop_mass, parameters) + get_stage_dev_cost(design_variables.reusable_stages(2), stg2_total_mass, rocket.stg2_prop_mass, parameters);

    launcher_dev_cost = (1.1 * stage_dev_cost) * parameters.MY_value;

end