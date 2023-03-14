function [per_launch_mass, launch_cadences] = run_mission_module(design_variables, parameters)
    
    %CALCULATE MASS PER LAUNCH (DIVIDE EVENLY)
    num_sat_per_launch = ceil(parameters.num_of_satellites / design_variables.num_of_launches);
    per_launch_mass = parameters.mass_per_satellite * num_sat_per_launch;

    %SET UP LEARNING CURVE FOR SATELLITE PRODUCTION TIMES
    sat_vec =  1:parameters.num_of_satellites;
    sat_prod_times = parameters.init_sat_prod_time*sat_vec.^(log(parameters.sat_prod_learning_rate)/log(2)); %Based on Crawford's Learning Curve

    %DETERMINE LAUNCHER PRODUCTION TIME BASED ON REQUIRED LAUNCHER
    %RADIUS
    launcher_prod_time = get_launcher_prod_time(parameters, design_variables.rocket_radius);
    

%             fprintf('============Starting Numbers============\n')
    %SET UP TRACKING VARIABLES FOR SIMULATION
    tracking_vars.num_sats_produced = 0;
    tracking_vars.num_sats_awaiting_launch = 0;
    tracking_vars.num_sats_launched = 0;
    tracking_vars.next_sat_prod_time=sat_prod_times(1);
    tracking_vars.next_launcher_prod_time = launcher_prod_time;
    tracking_vars.next_launcher_refurb_time = inf;
    tracking_vars.curr_time_step = 0;
    tracking_vars.last_launch_time = 0;
    tracking_vars.launch_cadences = zeros(2,design_variables.num_of_launches);
    tracking_vars.additional_rockets_available = 0;
    tracking_vars.curr_launch_num = 0;
    tracking_vars.ready_q = zeros(1, parameters.rocket_fleet_size);
    tracking_vars.awaiting_refurb = 0;
    tracking_vars.refurb_active = false;
    tracking_vars.curr_launch_num = 0;

    while tracking_vars.num_sats_launched < parameters.num_of_satellites
        
        curr_time_step = get_next_time_step(design_variables, parameters, tracking_vars);

        % SATELLITE PRODUCTION
        if (curr_time_step == tracking_vars.next_sat_prod_time) && (tracking_vars.num_sats_produced < parameters.num_of_satellites)
%                     fprintf('\nSatellite being produced!\n')
            tracking_vars.num_sats_produced = tracking_vars.num_sats_produced + 1;
            tracking_vars.num_sats_awaiting_launch = tracking_vars.num_sats_awaiting_launch + 1;
            if tracking_vars.num_sats_produced < parameters.num_of_satellites
                tracking_vars.next_sat_prod_time = curr_time_step + sat_prod_times(tracking_vars.num_sats_produced+1);
            end
        end

        % LAUNCHER PRODUCTION
        if curr_time_step == tracking_vars.next_launcher_prod_time
%                     fprintf('\nLauncher being produced!\n')
            tracking_vars.ready_q(end+1) = 0;
            tracking_vars.next_launcher_prod_time = curr_time_step + launcher_prod_time;
            tracking_vars.additional_rockets_available = tracking_vars.additional_rockets_available + 1;
        end

        % LAUNCHER REFURBISHMENT
        if (tracking_vars.refurb_active == true) && (curr_time_step == tracking_vars.next_launcher_refurb_time)% && (design_variables.reusable_stages(1) == true)
%                     fprintf('\nLauncher being refurbished!\n')
            tracking_vars.ready_q(end+1) = 1;
            tracking_vars.additional_rockets_available = tracking_vars.additional_rockets_available + 1;
            
            if tracking_vars.awaiting_refurb > 0
                tracking_vars.next_launcher_refurb_time = curr_time_step + parameters.launcher_refurb_time;
                tracking_vars.awaiting_refurb = tracking_vars.awaiting_refurb - 1;
            else
                tracking_vars.refurb_active = false;
            end
        end

        % CHECK TO SEE IF WE CAN LAUNCH ANYTHING YET (ASSUMES
        % LAUNCH ON DEMAND)
        while (floor(tracking_vars.num_sats_awaiting_launch/num_sat_per_launch) > 0) && (length(tracking_vars.ready_q) >= 1)
%                     fprintf('============Launch!============\n')
            tracking_vars.curr_launch_num = tracking_vars.curr_launch_num + 1;

            tracking_vars.num_sats_launched = tracking_vars.num_sats_launched + num_sat_per_launch;
            tracking_vars.num_sats_awaiting_launch = tracking_vars.num_sats_awaiting_launch - num_sat_per_launch;

            launch_cadences(1, tracking_vars.curr_launch_num) = curr_time_step - tracking_vars.last_launch_time;
            launch_cadences(2, tracking_vars.curr_launch_num) = tracking_vars.ready_q(1);

            tracking_vars.ready_q = tracking_vars.ready_q(2:end);
            if design_variables.reusable_stages(1) == true
                tracking_vars = place_rocket_in_refurb(tracking_vars, curr_time_step, parameters);
            end

            tracking_vars.last_launch_time = curr_time_step;
        end

        if (tracking_vars.num_sats_awaiting_launch > 0) && (tracking_vars.num_sats_awaiting_launch < num_sat_per_launch) && (tracking_vars.num_sats_produced >= parameters.num_of_satellites) && (length(tracking_vars.ready_q) >= 1)
%                     fprintf('============Last Launch!============\n')
            tracking_vars.num_sats_launched = tracking_vars.num_sats_launched + tracking_vars.num_sats_awaiting_launch;
            tracking_vars.num_sats_awaiting_launch = 0;
            launch_cadences(1, tracking_vars.curr_launch_num) = curr_time_step - tracking_vars.last_launch_time;
            launch_cadences(2, tracking_vars.curr_launch_num) = tracking_vars.ready_q(1);
            tracking_vars.ready_q = tracking_vars.ready_q(2:end);
            tracking_vars.last_launch_time = tracking_vars.curr_time_step;
        end
    end
end

function curr_time_step = get_next_time_step(design_variables, parameters, tracking_vars)
    if tracking_vars.num_sats_produced < parameters.num_of_satellites
        if design_variables.reusable_stages(1) == true
            curr_time_step = min([tracking_vars.next_sat_prod_time, tracking_vars.next_launcher_prod_time, tracking_vars.next_launcher_refurb_time]);
        else
            curr_time_step = min([tracking_vars.next_sat_prod_time, tracking_vars.next_launcher_prod_time]);
        end
    else
        if design_variables.reusable_stages(1) == true
            curr_time_step = min([tracking_vars.next_launcher_prod_time, tracking_vars.next_launcher_refurb_time]);
        else
            curr_time_step = tracking_vars.next_launcher_prod_time;
        end
    end
end

function launcher_prod_time = get_launcher_prod_time(parameters, launcher_radius)
    launcher_prod_time = 0;
    [num_rows, num_columns] = size(parameters.launcher_prod_time_bins);
    for i=1:num_columns
        size_cat=parameters.launcher_prod_time_bins(1,i);
        if launcher_radius <= size_cat
            launcher_prod_time = parameters.launcher_prod_time_bins(2,i);
            break
        end
    end
    assert(launcher_prod_time > 0, 'Launcher radius provided is larger than the maximum size in parameters.launcher_prod_time_bins')
end

function tracking_vars = place_rocket_in_refurb(tracking_vars, curr_time_step, parameters)
    if tracking_vars.refurb_active == false
        tracking_vars.next_launcher_refurb_time = curr_time_step + parameters.launcher_refurb_time;
        tracking_vars.refurb_active = true;
    else
        tracking_vars.awaiting_refurb = tracking_vars.awaiting_refurb + 1;
    end

end