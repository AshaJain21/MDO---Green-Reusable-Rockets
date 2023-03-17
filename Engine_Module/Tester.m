% Tester
addpath(genpath([pwd '/combustion_toolbox/']))

design_variables.stage1.reusable = 1;
design_variables.stage1.engine_prop = {"CH4", "LOX", 327, 3.00E+07, 3.6, 34.34, 1.3}; %line
design_variables.stage2.engine_prop = {"CH4", "LOX", 327, 3.00E+07, 3.6, 34.34, 1.3};

rocket.stage1.mstruct = 10000; %lbs
rocket.stage2.mstruct = 1000;  %lbs

design_variables.ri   = 5;     %m

rocket = engine_mod(rocket, design_variables);
