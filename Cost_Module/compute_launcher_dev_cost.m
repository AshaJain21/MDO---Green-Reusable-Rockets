function launcher_dev_cost = compute_launcher_dev_cost(rocket, design_variables, parameters, total_masses)
    % Assumptions
    % 1. Assumes no engine development costs

    stage_dev_cost = get_stage_dev_cost(design_variables.stage1.reusable, total_masses(1), rocket.stage1.mprop, parameters) + get_stage_dev_cost(design_variables.stage2.reusable, total_masses(2), rocket.stage2.mprop, parameters);

    launcher_dev_cost = (1.1 * stage_dev_cost) * parameters.MY_value;

end