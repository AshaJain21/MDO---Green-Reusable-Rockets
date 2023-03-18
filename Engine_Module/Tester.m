% Tester
addpath(genpath([pwd '/combustion_toolbox/']))

design_variables.stage1.reusable = 1;
design_variables.stage1.engine_prop = {"", "RP-1", "LOX", 304, 1.08E+07, 2.36, 21.4, 0.9}; %line
design_variables.stage2.engine_prop = {"", "RP-1", "LOX", 304, 1.08E+07, 2.36, 21.4, 0.9};

rocket.stage1.mstruct = 10000; %kgs
rocket.stage2.mstruct = 55000;   %kgs

design_variables.rocket_ri   = 1.7;     %m

rocket = engine_mod(rocket, design_variables);
