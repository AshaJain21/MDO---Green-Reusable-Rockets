function total_cost = run_cost_module(design_variables, parameters, rocket, launch_cadence)
    
    %Launcher material cost
    stg1_mat_volume = ((2*pi*rocket.stg1_radius*rocket.stg1_height) + (pi*srocket.stg1_radius^2)) * rocket.wall_thickness; %material volume of stage 1
    stg2_mat_volume = ((2*pi*rocket.stg2_radius*rocket.stg2_height) + (pi*srocket.stg2_radius^2)) * rocket.wall_thickness; %material volume of stage 2

    launcher_mat_volume = stg1_mat_volume + stg2_mat_volume;

    launcher_mat_cost = launcher_mat_volume * parameters.launcher_mat_density * parameters.mat_unit_cost;
    
    % Launcher development cost
    launcher_dev_cost = compute_launcher_dev_cost(rocket);
    
    %Launcher manufacturing cost
    launcher_manuf_cost = compute_launcher_manuf_cost();

    %Launcher refurbishment cost


    %Propellant costs
    total_prop_cost = calculate_prop_cost(rocket.stg1_prop, rocket.stg1_prop_mass, parameters) + calculate_prop_cost(rocket.stg2_prop, rocket.stg2_prop_mass, parameters);


    total_cost = launcher_mat_cost + launcher_manuf_cost + launcher_refurb_cost + total_prop_cost;
end