% Tester
addpath(genpath([pwd '/combustion_toolbox/']))

design_variables.stage1.reusable = 1;
design_variables.stage1.engine_prop = {"", "RP-1", "LOX", 337.5, 1.8E+07, 2.6, 35, 1.338}; %line
design_variables.stage2.engine_prop = {"", "RP-1", "LOX", 337.5, 1.8E+07, 2.6, 35, 1.338};

rocket.stage1.mstruct = 22000; %kgs
rocket.stage2.mstruct = 4000;   %kgs
rocket.payload        = 20000; %kgs
stage1.alpha          = 0.1; % 10% of payload mass is structure mass
stage2.alpha          = 0.1; % 10% of payload mass is structure mass

design_variables.rocket_ri = 1.5;     %m

rocket = engine_mod(rocket, design_variables);
