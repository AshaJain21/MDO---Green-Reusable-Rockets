launch_cadences = [
    2.3963    1.9206    1.7733    1.6839    1.6205    1.5716    1.5321    1.4991    1.4708    1.4461; 0         0         0         0         0         0         0         0    1.0000         0];

%Parameters in this test script are based on falcon 9 specifications

rocket.stg1_height = 41; %m
rocket.stg2_height = 14; %m
rocket.wall_thickness = 4.7e-3; %m
rocket.stg1_prop_mass = 395700; %kg
rocket.stg2_prop_mass = 92670; %kg

design_variables.rocket_radius = 3.7;%m
design_variables.reusable_stages = [1,1];
design_variables.engines_propellant = [3,16];

parameters.structural_material.density = 2700; %kg/m^3, based on aluminum 2219
parameters.structural_material.unit_cost = 2; %$/m^3, note that this number is random
parameters.init_refurb_cost_percentage = 0.7;
parameters.refurb_learning_rate = 0.9;
parameters.manuf_learning_rate = 0.9;
parameters.MY_value = 120000; %USD
parameters.num_engines_per_stage = 4; %Note that this is a random number
parameters.f1 = 0.6; %from koeller paper
parameters.f3 = 1.0; %from koeller paper
parameters.f4 = 0.8; %Note that this is a random number
parameters.struc_to_propellant_mass_ratio = 0.04; %Matching falcon 9 stage 1
parameters.prop_unit_costs = (rand(26)*3) + 5; %Random prop cost data for now


total_cost = run_cost_module(design_variables, parameters, rocket, launch_cadences)