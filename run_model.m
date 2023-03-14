function success = run_model(design_variables, parameters)

[payload_mass_per_launch, launch_cadence] = run_mission_module(design_variables, parameters);

[] = run_engine_module(design_variables, parameters);

[] = run_aerodynamics_module();





end

