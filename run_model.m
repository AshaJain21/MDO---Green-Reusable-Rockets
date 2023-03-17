function [launch_cadence, env_impact, cost] = run_model(design_variables, parameters)

rocket.stage1.mstruct=parameters.initial_struct_masses(1);
rocket.stage2.mstruct=parameters.initial_struct_masses(2);

[launch_cadence, rocket] = run_mission_module(design_variables, parameters, rocket);

[rocket] = engine_mod(rocket, design_variables);

rocket.stage1

[rocket] = Structures(design_variables, parameters, rocket);

[rocket] = aerodynamics(design_variables, parameters, rocket);

[env_impact] =run_env_impact_module(design_variables, rocket);

cost = run_cost_module(design_variables, parameters, rocket, launch_cadence);


end

