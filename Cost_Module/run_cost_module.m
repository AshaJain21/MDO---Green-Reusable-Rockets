function total_cost = run_cost_module(design_variables, parameters, rocket, launch_cadence)
    %Setting up array to track total cost for each launch
    size_launch_schedule = size(launch_schedule);
    total_cost_for_each_launch = zeros([1, size_launch_schedule(2)]);

    %Launcher material cost
    stg1_mat_volume = ((2*pi*rocket.stg1_radius*rocket.stg1_height) + (pi*srocket.stg1_radius^2)) * rocket.wall_thickness; %material volume of stage 1
    stg2_mat_volume = ((2*pi*rocket.stg2_radius*rocket.stg2_height) + (pi*srocket.stg2_radius^2)) * rocket.wall_thickness; %material volume of stage 2

    launcher_mat_volume = stg1_mat_volume + stg2_mat_volume;

    launcher_mat_cost = launcher_mat_volume * parameters.launcher_mat_density * parameters.mat_unit_cost;
    launcher_mat_costs_per_launcher = ones([1, size_launch_schedule(2)]) * launcher_mat_cost;
    total_cost_for_each_launch = total_cost_for_each_launch + launcher_mat_costs_per_launcher;

    
    % Launcher development cost
    launcher_dev_cost = compute_launcher_dev_cost(rocket);
    total_cost_for_each_launch = total_cost_for_each_launch + ones([1, size_launch_schedule(2)]) * launcher_dev_cost / size_launch_schedule(2)

    %Launcher manufacturing cost
    launcher_manuf_cost = compute_launcher_manuf_cost();

     total_cost_for_each_launch = total_cost_for_each_launch + launcher_dev_cost + launcher_manuf_cost;

    %Launcher refurbishment cost

    if parameters.reusable_stage(0) == 1
        stage_1_refurb_cost= compute_refurb_cost(stages_1_manuf_cost, launch_cadence, parameters.refurb_cost_learning_curve);
        total_cost_for_each_launch = total_cost_for_each_launch + stage_1_refurb_cost;
    elseif parameters.reusable_stage(1) == 1
        stage_2_refurb_cost= compute_refurb_cost(stages_2_manuf_cost, launch_cadence, parameters.refurb_cost_learning_curve);
        total_cost_for_each_launch = total_cost_for_each_launch + stage_2_refurb_cost;
    end


    %Propellant costs
    total_prop_cost = calculate_prop_cost(rocket.stg1_prop, rocket.stg1_prop_mass, parameters) + calculate_prop_cost(rocket.stg2_prop, rocket.stg2_prop_mass, parameters);
    total_cost_for_each_launch =total_cost_for_each_launch + ones([1, size_of_launch_schedule(2)]) * total_prop_cost;

    %Spreading costs over time (?) with dev costs amortized, this may boil
    %down to maximum cost per launch 

    total_cost = total_cost_for_each_launch;
end