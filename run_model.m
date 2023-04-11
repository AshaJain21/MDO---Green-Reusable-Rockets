function [launch_cadence, total_rf, total_od, total_gwp, cost, constraints, rocket] = run_model(design_variables, parameters)

rocket.stage1.mprop = design_variables.mprop1_guess;
rocket.stage2.mprop = design_variables.mprop2_guess;
[launch_cadence, rocket] = run_mission_module(design_variables, parameters, rocket);

[rocket] = aerostructures(design_variables, parameters, rocket);

[rocket] = engine_mod(rocket, design_variables, parameters);
    
[total_rf, total_od, total_gwp] =run_env_impact_module(design_variables, rocket);

cost = run_cost_module(design_variables, parameters, rocket, launch_cadence);

constraints = 0;

% constraints = run_constraint_module(design_variables, parameters, rocket, launch_cadence, cost);

end
