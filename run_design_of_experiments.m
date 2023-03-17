addpath(genpath(pwd))
%Run script for Design of Experiments 

%One time setup
parameters = setup_parameters();

%Load data describing each design experiment 
doe_bins = readtable("doe_bins.csv");
experiments = readtable("design_of_experiments.csv");
num_experiments = size(experiments.Experiment); 
experiments = format_final_doe_array(num_experiments(1), experiments, doe_bins);

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
    engine_prop_1.Fuel= string(engine_prop_1.Fuel);
    engine_prop_1.Engine = string(engine_prop_1.Engine);
    engine_prop_1.Oxidizer = string(engine_prop_1.Oxidizer);
    
    engine_prop_2 = engine_prop_db(experiments{i, 4}, :);
    engine_prop_2.Fuel= string(engine_prop_2.Fuel);
    engine_prop_2.Engine = string(engine_prop_2.Engine);
    engine_prop_2.Oxidizer = string(engine_prop_2.Oxidizer);

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
        design_variables = setup_designvariables(num_of_launches, reusable_stage_1, reusable_stage_2, engine_prop_1, engine_prop_2, reentry_shield_material, rocket_radius);
    
        [launch_cadence, env_impact, cost] = run_model(design_variables, parameters);
        Output.launch_cadence = launch_cadence;
        Output.env_impact = env_impact;
        Output.cost = cost;
        output_struct_array(output_count)  = Output;
        output_count = output_count + 1;

        break

    end

end

function experiments = format_final_doe_array(num_experiments, experiments, doe_bins)
   num_factors = 5;

   for exp = 1:num_experiments
       for factor = 2:num_factors+1
           experiments(exp, factor) = doe_bins(experiments{exp, factor}, factor);
       end
   end
end



