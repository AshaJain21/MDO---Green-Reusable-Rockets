addpath(genpath(pwd))
%Run script for Design of Experiments 

%One time setup
parameters = setup_parameters();

%Load data describing each design experiment 
doe_bins = readtable("doe_bins.csv");
othrogonal_array = readtable("design_of_experiments.csv");
num_othrogonal_array = size(othrogonal_array.Experiment); 

%Create experiments table 
experiments = format_final_doe_array(num_othrogonal_array(1), othrogonal_array, doe_bins);
num_experiments = size(experiments.num_of_launches);

%Loading database data
engine_prop_db = readtable("engine-prop-combinations.csv");
reentry_shield_material_db = readtable("reentry_shield_materials.csv");


for i = 1:max(num_experiments)
    fprintf('======= Running Experiment %.15g\n', i)
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

    reusable_stage_1 = experiments.reusable_stage1;
    reusable_stage_2 = experiments.reusable_stage2;

    design_variables = setup_designvariables(num_of_launches, reusable_stage_1, reusable_stage_2, engine_prop_1, engine_prop_2, reentry_shield_material, rocket_radius);

    [delivery_time, env_impact, cost] = run_model(design_variables, parameters);
    experiments{i, 8} = sum(cost(1, :));
end

%Compute the effects of each design variable
[rows, cols] = size(doe_bins);
effects = zeros([(rows*cols+4), 1]);
overall_mean = mean(experiments.output_cost);
effect_count = 1;
for k = 1:rows
    for j = 1:cols
        factor = doe_bins.Properties.VariableNames{j};
        factor_value = doe_bins(k,j);

        effects(effect_count) = mean(experiments.output_cost(experiments(:, factor)== factor_value)) - overall_mean;
        effect_count = effect_count +1;
    end
    
end

for m = 0:1

        effects(effect_count) = mean(experiments.output_cost(experiments(:, "resusable_stage1") == m)) -overall_mean;
        effects(effect_count+1) = mean(experiments.output_cost(experiments(:, "resusable_stage2") == m)) -overall_mean;
        effect_count = effect_count +2;
end 


disp(effects);


function experiments = format_final_doe_array(num_experiments, orthogonal_array, doe_bins)
   num_factors = 5;
   experiments = array2table(zeros(64,8), 'VariableNames',{'num_of_launches', 'engine-prop_1', 'engine-prop_2', 'reentry_shield_material', 'rocket_radius', 'reusable_stage1', 'reusable_stage2', 'output_cost'});
   for exp = 1:num_experiments
       for factor = 2:num_factors+1
           experiments(exp*4-3, factor-1) = doe_bins(orthogonal_array{exp, factor}, factor);
           experiments(exp*4-2, factor-1) = doe_bins(orthogonal_array{exp, factor}, factor);
           experiments(exp*4-1, factor-1) = doe_bins(orthogonal_array{exp, factor}, factor);
           experiments(exp*4, factor-1) = doe_bins(orthogonal_array{exp, factor}, factor);
       end
       experiments{exp*4-3, 6} = 1;
       experiments{exp*4-3, 7} = 1;
       experiments{exp*4-3, 8} = 0;
       experiments{exp*4-2, 6} = 1;
       experiments{exp*4-2, 7} = 0;
       experiments{exp*4-2, 8} = 0;
       experiments{exp*4-1, 6} = 0;
       experiments{exp*4-1, 7} = 1;
       experiments{exp*4-1, 8} = 0;
       experiments{exp*4, 6} = 0;
       experiments{exp*4, 7} = 0;
       experiments{exp*4, 8} = 0;

   end
end



