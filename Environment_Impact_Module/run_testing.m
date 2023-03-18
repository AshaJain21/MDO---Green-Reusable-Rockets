%Testing script for environment module 
clc;clear;
propellant_mass_burned_per_altitude = containers.Map({'Al2O3', 'NOx', 'COx', 'BC', 'H2O'}, {10, 10, 10, 10 ,10});
second_stage_reentry_mass = 5000;
parameters.reusable_stage = [1,1];
rocket.stage1.prodValues = propellant_mass_burned_per_altitude;
rocket.stage2.prodValues = containers.Map({'Al2O3', 'NOx', 'COx', 'H2O'}, {10, 10, 10 ,10});
rocket.stage2.mstruct = 100;
design_variables.stage2.reusable =0;
env_impact = run_env_impact_module(design_variables, rocket)


