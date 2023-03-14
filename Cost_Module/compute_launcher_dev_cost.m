function launcher_dev_cost = compute_launcher_dev_cost(rocket, design_variables, parameters, total_masses)
    % Assumptions
    % 1. Assumes no engine development costs

    stage_dev_cost = get_stage_dev_cost(design_variables.reusable_stages(1), total_masses(1), rocket.stg1_prop_mass, parameters) + get_stage_dev_cost(design_variables.reusable_stages(2), total_masses(2), rocket.stg2_prop_mass, parameters);

    launcher_dev_cost = (1.1 * stage_dev_cost) * parameters.MY_value;

end