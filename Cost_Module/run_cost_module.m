function [total_cost, rocket] = run_cost_module(design_variables, parameters, rocket, launch_cadence)
    %Setting up array to track total cost for each launch
    size_launch_schedule = size(launch_cadence);
    total_cost_for_each_launch = zeros([1, size_launch_schedule(2)]);

    %Computing total stage massesprop 
    stg1_total_mass = rocket.stage1.mprop * (1 + parameters.struc_to_propellant_mass_ratio);
    stg2_total_mass = rocket.stage2.mprop * (1 + parameters.struc_to_propellant_mass_ratio);
    stage_masses = [stg1_total_mass, stg2_total_mass];

    %Launcher material cost
    stg1_mat_volume = ((2*pi*design_variables.rocket_ri*rocket.stage1.height) + (pi*design_variables.rocket_ri^2)) * rocket.wall_thickness; %material volume of stage 1
    stg2_mat_volume = ((2*pi*design_variables.rocket_ri*rocket.stage2.height) + (pi*design_variables.rocket_ri^2)) * rocket.wall_thickness; %material volume of stage 2

    launcher_mat_volume = stg1_mat_volume + stg2_mat_volume;

    launcher_mat_cost = launcher_mat_volume * parameters.structural_material.density * parameters.structural_material.unit_cost;
    launcher_mat_costs_per_launcher = ones([1, size_launch_schedule(2)]) * launcher_mat_cost;
    total_cost_for_each_launch = total_cost_for_each_launch + launcher_mat_costs_per_launcher;

    
    % Launcher development cost
    launcher_dev_cost = compute_launcher_dev_cost(rocket, design_variables, parameters, stage_masses);
    launcher_dev_cost_per_launch = ones([1, size_launch_schedule(2)]) * launcher_dev_cost / size_launch_schedule(2);
    total_cost_for_each_launch = total_cost_for_each_launch + launcher_dev_cost_per_launch;

    %Launcher manufacturing cost
    num_stages = 2;
    init_stage_manuf_costs = compute_launcher_manuf_cost(parameters, design_variables, num_stages, stage_masses, rocket)
    launch_nums = 1:size_launch_schedule(2);
    manuf_cost_per_launch_per_stage = init_stage_manuf_costs * launch_nums.^parameters.manuf_learning_rate;
    total_cost_for_each_launch = total_cost_for_each_launch + sum(manuf_cost_per_launch_per_stage, 1);

    %Launcher refurbishment cost
    if design_variables.stage1.reusable == 1
        stage_1_refurb_cost= compute_refurb_cost(1, manuf_cost_per_launch_per_stage(1,:), size_launch_schedule(2), launch_cadence, parameters);
        total_cost_for_each_launch = total_cost_for_each_launch + stage_1_refurb_cost;
    end
    if design_variables.stage2.reusable == 1
        stage_2_refurb_cost= compute_refurb_cost(2, manuf_cost_per_launch_per_stage(2,:), size_launch_schedule(2), launch_cadence, parameters);
        total_cost_for_each_launch = total_cost_for_each_launch + stage_2_refurb_cost;
    end


    %Propellant costs
    total_prop_cost = calculate_prop_cost(rocket, design_variables, parameters);
    total_cost_for_each_launch =total_cost_for_each_launch + ones([1, size_launch_schedule(2)]) * total_prop_cost;

    %Heat Shield cost
    %TODO!!

    %Spreading costs over time (?) with dev costs amortized, this may boil
    %down to maximum cost per launch

    total_cost = [total_cost_for_each_launch; cumsum(launch_cadence(1,:))];
end