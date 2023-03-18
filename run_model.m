function [launch_cadence, env_impact, cost] = run_model(design_variables, parameters)

rocket.stage1.mstruct=parameters.initial_struct_masses(1);
rocket.stage2.mstruct=parameters.initial_struct_masses(2);

[launch_cadence, rocket] = run_mission_module(design_variables, parameters, rocket);

% avg_error_perc = 1;
% num_iterations = 0;
% previous_prop_masses = [rocket.stage1.mprop, rocket.stage2.mprop];
% 
% while (avg_error_perc >= parameters.loop_termination_threshold) && (num_iterations <= parameters.max_loop_iterations)
% 
%     num_iterations = num_iterations + 1;

[rocket] = engine_mod(rocket, design_variables);

[rocket] = Structures(design_variables, parameters, rocket);

[rocket] = aerodynamics(design_variables, parameters, rocket);

% avg_error_perc = calculate_curr_error(rocket, previous_prop_masses);
% 
% end

[env_impact] =run_env_impact_module(design_variables, rocket);

cost = run_cost_module(design_variables, parameters, rocket, launch_cadence);

end

function avg_error_perc = calculate_curr_error(rocket, previous_prop_masses)
    new_prop_masses = [rocket.stage1.mprop, rocket.stage2.mprop];
    error_perc = (new_prop_masses - previous_prop_masses) ./ previous_prop_masses;
    avg_error_perc = sum(error_perc)/2;
end