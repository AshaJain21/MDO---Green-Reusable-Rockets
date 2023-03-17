addpath(genpath(pwd))
%Run script for Design of Experiments 

%One time setup
parameters = setup_parameters();

%Load data describing each design experiment 
experiments = readtable("design_of_experiments.csv");
num_experiments = size(experiments.Experiment); 

%Loading database data
engine_prop_db = readtable("engine-prop-combinations.csv");
reentry_shield_material_db = readtable("reentry_shield_materials.csv");


output_struct_array = zeros([1, num_experiments]);
output_count = 1;

for i = 1:num_experiments
    %Set up design variables 
    num_of_launches = experiments{i, 2};
    %Engine Prop data 
    engine_prop_1 = engine_prop_db(experiments{i, 3}, :);
    engine_prop_2 = engine_prop_db(experiments{i, 4}, :);
    reentry_shield_material = reentry_shield_material_db(experiments{i, 5}, :);
    rocket_radius = experiments{i,6};
    for j = 1:4
        if j == 1
        reusable_stage_1 = 1;
        reusable_stage_2 = 1;
        elseif j ==2 
        reusable_stage_1 = 1;
        reusable_stage_2 = 0;
        elseif j ==4 
        reusable_stage_1 = 0;
        reusable_stage_2 = 1;
        else
        reusable_stage_1 = 0;
        reusable_stage_2 = 0;
        end 
        design_variables = setup_designvariables(num_of_launches, reusable_stage_1, reusable_stage_2, engine-prop_1, engine-prop_2, reentry_shield_material, rocket_radius);
    
        [launch_cadence, env_impact, cost] = run_model(design_variables, parameters);
        Output.launch_cadence = launch_cadence;
        Output.env_impact = env_impact;
        Output.cost = cost;
        output_struct_array(output_count)  = Output;
        output_count = output_count + 1;

    end

end



