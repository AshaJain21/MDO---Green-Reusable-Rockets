% Tester
addpath(genpath([pwd '/combustion_toolbox/']))

rocket.stage1.reusable = 1;
rocket.stage1.mstruct = 10000; %lbs
rocket.stage2.mstruct = 1000;  %lbs
rocket.stage1.ri      = 5;     %m
rocket.stage2.ri      = 5;     %m
% design_variables.engine_prop_1  = cell array;


rocket = CALL_engine_mod(rocket, design_variables);
