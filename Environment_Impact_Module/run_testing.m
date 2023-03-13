%Testing script for environment module 
clc;clear;
propellant_mass_burned_per_altitude = containers.Map({'Al2O3', 'NOx', 'COx'}, {[10, 20, 30; 10, 10, 10], [10, 20, 30; 10, 10, 10], [10, 20, 30; 10, 10, 10]});
second_stage_reentry_mass = 5000;
parameters.reusable_stage = [1,1];
env_impact = run_env_impact_module(propellant_mass_burned_per_altitude, second_stage_reentry_mass, parameters)
