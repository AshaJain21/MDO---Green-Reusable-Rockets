function [launch_cadence, env_impact, cost] = run_model(design_variables, parameters)

[payload_mass_per_launch, launch_cadence] = run_mission_module(design_variables, parameters);

[engine_thrust, combustion_products, stage_prop_masses] = run_engine_module(design_variables, parameters, payload_mass_per_launch);

[ heat_fluxes, combustion_products_kgs_per_km] = run_aerodynamics_module(design_variables, parameters, engine_thrust, combustion_products);

[stage_1_stuct_arr, stage_2_struct_arr] = run_structures_modules(design_variables, parameters, heat_fluxes, engine_thrust, stage_prop_masses);

[env_impact] =run_env_impact_module(parameters, combustion_products_kgs_per_km, stage_2_struct_arr.dry_mass);

cost = run_cost_module(design_variables, parameters, stage_1_stuct_arr, stage_2_struct_arr, launch_cadence);


end

