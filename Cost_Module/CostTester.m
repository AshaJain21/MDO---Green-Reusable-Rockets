clear
addpath(genpath(pwd))

parameters = setup_parameters();

launch_cadences = [
    2.3963    1.9206    1.7733    1.6839    1.6205    1.5716    1.5321    1.4991    1.4708    1.4461; 0         0         0         0         0         0         0         0    1.0000         0];

%Parameters in this test script are based on falcon 9 specifications

rocket.stage1.height = 41; %m
rocket.stage2.height = 14; %m
rocket.wall_thickness = 4.7e-3; %m
rocket.stage1.mprop = 395700; %kg
rocket.stage2.mprop = 92670; %kg
rocket.stage1.mstruct = (0.1*rocket.stage1.mprop);
rocket.stage2.mstruct = (0.1*rocket.stage2.mprop);


design_variables.rocket_ri = 3.7;%m
design_variables.stage1.reusable = 1;
design_variables.stage2.reusable = 1;
design_variables.stage1.engine_prop = {'MA-5A', 'RP-1', 0,0,0,0,0,0, 1610};
design_variables.stage2.engine_prop = {'Vulcain 2', 'LH2', 0,0,0,0,0,0, 1800};


total_cost = run_cost_module(design_variables, parameters, rocket, launch_cadences);


%Reference numbers for output validation:
% 1. https://www.nasa.gov/pdf/586023main_8-3-11_NAFCOM.pdf shows that NASA
% estimated between $1.7B and $4B in development cost initially. Spacex's
% unconventional development methods and the our model not accounting for
% different types of pricing contracts might account for differences
% between our numbers and that presentation 