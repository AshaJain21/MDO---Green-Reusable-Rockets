%Testing script for environment module 
clc;clear;
second_stage_reentry_mass = 5000;
parameters.reusable_stage = [1,1];
rocket.stage1.prodValues = [10,10,10,10];
rocket.stage1.prodNames = ["NO"; "CO2"; "CO"; "H2O"];
rocket.stage2.prodValues = [10,10,10,10];
rocket.stage2.prodNames = string(["NO"; "CO2";"CO";"H2O"]);
rocket.stage2.mstruct = 100;
rocket.stage1.mprop = 100;
rocket.stage2.mprop = 100;
design_variables.stage1.engine_prop.Fuel = string('UDMH');
design_variables.stage2.engine_prop.Fuel = string('LH2');
design_variables.stage2.reusable =0;
env_impact = run_env_impact_module(design_variables, rocket)


