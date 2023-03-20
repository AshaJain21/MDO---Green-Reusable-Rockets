% Tester
addpath(genpath([pwd '/combustion_toolbox/']))

design_variables.stage1.reusable = 1;
design_variables.stage1.engine_prop = {"", "RP-1", "LOX", 337, 3.04E+07, 2.63, 36.87, 3.8}; %line
design_variables.stage2.engine_prop = {"", "RP-1", "LOX", 337, 3.04E+07, 2.63, 36.87, 3.8};

rocket.stage1.mstruct = 395700; %kgs
rocket.stage2.mstruct = 9267;   %kgs
rocket.payload        = 480000; %kgs

design_variables.rocket_ri = 1.5;     %m

rocket = engine_mod(rocket, design_variables);
