addpath(genpath(pwd))
%Run script for Design of Experiments 

%One time setup
parameters = setup_parameters();
engine_prop_db = readtable("engine-prop-combinations.csv");
reentry_shield_material_db = readtable("reentry_shield_materials.csv");

%Setting up possible values
num_launches = round(linspace(10, 500, 10));
stg1_reusable = [0,1];
stg2_reusable = [0,1];
radius = linspace(0.8, 4.5, 10);
engine1 = 1:16;
engine2 = 1:16;
reentry_material = 9;
mprop1_guess = [0.97e6, 1.3e6];
mprop2_guess = [1.6e5, 12e5];

%Create experiments matrix
num_experiments = 100; %length(num_launches) * length(stg1_reusable) * length(stg2_reusable) * length(radius) * length(engine1) * length(engine2) * length(mprop1_guess) * length(mprop2_guess);
experiments = zeros(num_experiments, 13);

for i = 1:num_experiments
    fprintf('======= Running Experiment %.15g\n', i)
    %Set up design variables 
    num_of_launches = randsample(num_launches, 1);
    %Engine Prop data 
    engine1_index = randsample(engine1, 1);
    engine_prop_1 = engine_prop_db(engine1_index, :);
    engine_prop_1.Fuel= string(engine_prop_1.Fuel);
    engine_prop_1.Engine = string(engine_prop_1.Engine);
    engine_prop_1.Oxidizer = string(engine_prop_1.Oxidizer);
    
    engine2_index = randsample(engine2, 1);
    engine_prop_2 = engine_prop_db(engine2_index, :);
    engine_prop_2.Fuel= string(engine_prop_2.Fuel);
    engine_prop_2.Engine = string(engine_prop_2.Engine);
    engine_prop_2.Oxidizer = string(engine_prop_2.Oxidizer);

    reentry_shield_material = reentry_shield_material_db(reentry_material, :);

    rocket_radius = randsample(radius, 1);

    reusable_stage_1 = randsample(stg1_reusable, 1);
    reusable_stage_2 = randsample(stg2_reusable, 1);

    mprop1_guess = randsample(mprop1_guess, 1);
    mprop2_guess = randsample(mprop2_guess, 1);

    design_variables = setup_designvariables(num_of_launches, reusable_stage_1, reusable_stage_2, engine_prop_1, engine_prop_2, reentry_shield_material, rocket_radius, mprop1_guess, mprop2_guess);
    [launch_cadence, total_rf, total_od, total_gwp, cost, constraints, rocket] = run_model(design_variables, parameters);
    constraints
    [c, ceq] = calculate_nonpenalty_constraints([num_of_launches, reusable_stage_1, reusable_stage_2, engine1_index, engine2_index, reentry_material, rocket_radius, mprop1_guess, mprop2_guess]);
    if all(c < 0)
        experiments(i, 1:9) = design_variables;
        experiments(i, 10) = sum(cost(1, :));
        experiments(i, 11) = total_rf;
        experiments(i, 12) = total_od; 
    end
   

end

