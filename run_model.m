function [launch_cadence, env_impact, cost] = run_model(design_variables, parameters)

rocket.stage1.mstruct=parameters.initial_struct_masses(1);
rocket.stage2.mstruct=parameters.initial_struct_masses(2);

[launch_cadence, rocket] = run_mission_module(design_variables, parameters, rocket);

% avg_error_perc = 1;
% rocket.iter = 0;
% 
% while (avg_error_perc >= parameters.loop_termination_threshold) && (num_iterations <= parameters.max_loop_iterations)
% 
%     rocket.iter = rocket.iter + 1;
%     previous_struct_masses = [rocket.stage1.mstruct, rocket.stage2.mstruct];
%     fprintf('Current iteration: %.15g. Average error: %.15g\n', num_iterations, avg_error_perc)

[rocket] = engine_mod(rocket, design_variables);

[rocket] = Structures(design_variables, parameters, rocket);

[rocket] = aerodynamics(design_variables, parameters, rocket);
    
%     avg_error_perc = calculate_curr_error(rocket, previous_struct_masses);
% 
% end

[env_impact] =run_env_impact_module(design_variables, rocket);

cost = run_cost_module(design_variables, parameters, rocket, launch_cadence);

end

function avg_error_perc = calculate_curr_error(rocket, previous_struct_masses)
    new_struct_masses = [rocket.stage1.mstruct, rocket.stage2.mstruct];
    error_perc = abs(new_struct_masses - previous_struct_masses) ./ previous_struct_masses;
    avg_error_perc = sum(error_perc)/2;
end