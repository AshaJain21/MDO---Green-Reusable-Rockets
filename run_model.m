function [launch_cadence, env_impact, cost] = run_model(design_variables, parameters)

rocket = struct();

[launch_cadence, rocket] = run_mission_module(design_variables, parameters, rocket);

[rocket] = run_engine_module(design_variables, parameters, rocket);

[rocket] = run_aerodynamics_module(design_variables, parameters, rocket);

[rocket] = run_structures_modules(design_variables, parameters, rocket);

[env_impact] =run_env_impact_module(design_variables, rocket);

cost = run_cost_module(design_variables, parameters, rocket, launch_cadence);


end

