addpath(genpath(pwd))
%Run script for Design of Experiments 

parameters = setup_parameters();

%Load data describing each design experiment 
experiments = readtable("design_of_experiments.csv");
num_experiments = size(experiments.Experiment); 

for i = 1:num_experiments
    %Set up design variables 
    num_of_launches = experiments{i, 1};
    reusable_stage_1 = experiments{i, 2};
    reusable_stage_2 = experiments{i,3};
    engine_prop_1 = experiments{i, 4};
    engine_prop_2 = experiments{i, 5};
    reentry_shield_material = experiments{i, 6};
    rocket_radius = experiments{i,7};
    design_variables = setup_designvariables(num_of_launches, reusable_stage_1, reusable_stage_2, engine-prop_1, engine-prop_2, reentry_shield_material, rocket_radius);

    [] = run_model(design_variables, parameters)
end



