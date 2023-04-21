function [launch_cadences, rocket] = run_mission_module(design_variables, parameters, rocket)

    launch_cadences = [];
    
    %CALCULATE MASS PER LAUNCH (DIVIDE EVENLY)
    num_sat_per_launch = ceil(parameters.num_of_satellites / design_variables.num_of_launches);
    per_launch_mass = parameters.mass_per_satellite * num_sat_per_launch;

    rocket.payload = per_launch_mass;

    %CALCULATE PAYLOAD HEIGHT
    rocket.num_sat_stacks = calc_inscribed_circles(parameters.sat_model_radius, design_variables.rocket_ri);
    rocket.num_sats_per_stack = ceil(num_sat_per_launch / rocket.num_sat_stacks);
    rocket.payload_height = rocket.num_sats_per_stack * parameters.sat_model_height;

    %SET UP LEARNING CURVE FOR SATELLITE PRODUCTION TIMES
    sat_vec =  1:parameters.num_of_satellites;
    sat_prod_times = (parameters.init_sat_prod_time/30)*sat_vec.^(log(parameters.sat_prod_learning_rate)/log(2)); %Based on Crawford's Learning Curve

    %DETERMINE LAUNCHER PRODUCTION AND REFURB TIMES BASED ON REQUIRED LAUNCHER
    %RADIUS
    total_launcher_prod_time = get_launcher_prod_time(parameters, design_variables.rocket_ri);
    first_stage_prod_time = parameters.first_stage_prod_percentage * total_launcher_prod_time;
    second_stage_prod_time = total_launcher_prod_time - first_stage_prod_time;
    launcher_refurb_times = parameters.launcher_refurb_time_percent * total_launcher_prod_time;
    

%             fprintf('============Starting Numbers============\n')
    %SET UP TRACKING VARIABLES FOR SIMULATION
    tracking_vars.num_sats_produced = 0;
    tracking_vars.num_sats_awaiting_launch = 0;
    tracking_vars.num_sats_launched = 0;
    tracking_vars.next_sat_prod_time=sat_prod_times(1);
    tracking_vars.next_launcher_prod_times = [first_stage_prod_time, second_stage_prod_time];
    tracking_vars.stages_awaiting_final = {[], []};
    tracking_vars.next_stage_refurb_time = [inf, inf];
    tracking_vars.last_launch_time = 0;
    tracking_vars.launch_cadences = zeros(2,design_variables.num_of_launches);
    tracking_vars.additional_rockets_available = 0;
    tracking_vars.curr_launch_num = 0;
    tracking_vars.ready_q = zeros(2, parameters.rocket_fleet_size);
    tracking_vars.num_rockets_ready = parameters.rocket_fleet_size;
    tracking_vars.awaiting_refurb = [0,0];
    tracking_vars.refurb_active = [false, false];
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
        if curr_time_step == tracking_vars.next_launcher_prod_times(1)
            tracking_vars = produce_launcher_stage(1, tracking_vars, curr_time_step, first_stage_prod_time);
        end
        if curr_time_step == tracking_vars.next_launcher_prod_times(2)
            tracking_vars = produce_launcher_stage(2, tracking_vars, curr_time_step, second_stage_prod_time);
        end

        % LAUNCHER REFURBISHMENT
        if (tracking_vars.refurb_active(1) == true) && (curr_time_step == tracking_vars.next_stage_refurb_time(1))
            tracking_vars = refurbish_launcher_stage(1, curr_time_step, tracking_vars, launcher_refurb_times);
        end
        if (tracking_vars.refurb_active(2) == true) && (curr_time_step == tracking_vars.next_stage_refurb_time(2))
            tracking_vars = refurbish_launcher_stage(2, curr_time_step, tracking_vars, launcher_refurb_times);
        end


        % CHECK TO SEE IF WE CAN LAUNCH ANYTHING YET (ASSUMES
        % LAUNCH ON DEMAND)
        while (floor(tracking_vars.num_sats_awaiting_launch/num_sat_per_launch) > 0) && (tracking_vars.num_rockets_ready >= 1)
%                     fprintf('============Launch!============\n')
            [tracking_vars, launch_cadences] = conduct_launch(true, num_sat_per_launch, tracking_vars, launch_cadences, curr_time_step, design_variables, parameters, launcher_refurb_times);
        end

        if (tracking_vars.num_sats_awaiting_launch > 0) && (tracking_vars.num_sats_awaiting_launch < num_sat_per_launch) && (tracking_vars.num_sats_produced >= parameters.num_of_satellites) && (length(tracking_vars.ready_q) >= 1)
%                     fprintf('============Last Launch!============\n')
            % Perform a final partial launch of any remaining satellites
            [tracking_vars, launch_cadences] = conduct_launch(false, num_sat_per_launch, tracking_vars, launch_cadences, curr_time_step, design_variables, parameters, launcher_refurb_times);
        end
    end
end

% =========== HELPER FUNCTIONS BELOW THIS LINE ===========================

function curr_time_step = get_next_time_step(design_variables, parameters, tracking_vars)
    times_to_consider = [tracking_vars.next_launcher_prod_times(1), tracking_vars.next_launcher_prod_times(2)];

    if tracking_vars.num_sats_produced < parameters.num_of_satellites
        times_to_consider(end+1) = tracking_vars.next_sat_prod_time;
    end

    if design_variables.stage1.reusable == true
        times_to_consider(end+1) = tracking_vars.next_stage_refurb_time(1);
    end

    if design_variables.stage2.reusable == true
        times_to_consider(end+1) = tracking_vars.next_stage_refurb_time(2);
    end

    curr_time_step = min(times_to_consider);

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

function tracking_vars = place_rocket_in_refurb(stage_num, tracking_vars, curr_time_step, launcher_refurb_times)
    if tracking_vars.refurb_active(stage_num) == false
        tracking_vars.next_stage_refurb_time(stage_num) = curr_time_step + launcher_refurb_times(stage_num);
        tracking_vars.refurb_active(stage_num) = true;
    else
        tracking_vars.awaiting_refurb(stage_num) = tracking_vars.awaiting_refurb(stage_num) + 1;
    end

end

function tracking_vars = add_stage_to_inventory(stage_num, tracking_vars, reused)
    
    if reused == true
        tracking_vars.stages_awaiting_final{stage_num}(end+1) = 1;
    else
        tracking_vars.stages_awaiting_final{stage_num}(end+1) = 0;
    end

    if stage_num == 1
        other_stage = 2;
    else
        other_stage = 1;
    end

    if ~isempty(tracking_vars.stages_awaiting_final{other_stage})
        tracking_vars = produce_final_launcher(tracking_vars);
    end
end

function tracking_vars = produce_launcher_stage(stage_num, tracking_vars, curr_time_step, prod_time)
%     fprintf('\nStage being produced!\n')

    tracking_vars = add_stage_to_inventory(stage_num, tracking_vars, false);
    
    tracking_vars.next_launcher_prod_times(stage_num) = curr_time_step + prod_time;
    
end

function tracking_vars = refurbish_launcher_stage(stage_num, curr_time_step, tracking_vars, launcher_refurb_times)
%     fprintf('\nStage finished refurbishment!\n')

    tracking_vars = add_stage_to_inventory(stage_num, tracking_vars, true);
    
    if tracking_vars.awaiting_refurb(stage_num) > 0
        tracking_vars.next_stage_refurb_time(stage_num) = curr_time_step + launcher_refurb_times(stage_num);
        tracking_vars.awaiting_refurb(stage_num) = tracking_vars.awaiting_refurb(stage_num) - 1;
    else
        tracking_vars.refurb_active(stage_num) = false;
        tracking_vars.next_stage_refurb_time(stage_num) = inf;
    end
end

function tracking_vars = produce_final_launcher (tracking_vars)
    stage1_reuse = tracking_vars.stages_awaiting_final{1}(1);
    stage2_reuse = tracking_vars.stages_awaiting_final{2}(1);
    
    tracking_vars.stages_awaiting_final{1} = tracking_vars.stages_awaiting_final{1}(2:end);
    tracking_vars.stages_awaiting_final{2} = tracking_vars.stages_awaiting_final{2}(2:end);

    tracking_vars.ready_q(:,end+1) = [stage1_reuse, stage2_reuse];
    [num_rows, num_columns] = size(tracking_vars.ready_q);
    tracking_vars.num_rockets_ready = num_columns;
    tracking_vars.additional_rockets_available = tracking_vars.additional_rockets_available + 1;
end

function [tracking_vars, launch_cadences] = conduct_launch(full, num_sat_per_launch, tracking_vars, launch_cadences, curr_time_step, design_variables, parameters, launcher_refurb_times)
    tracking_vars.curr_launch_num = tracking_vars.curr_launch_num + 1;
    
    % Update satellite tracking variables based on whether this is a full
    % launch or partial launch of remaining satellites
    if full == true
        tracking_vars.num_sats_launched = tracking_vars.num_sats_launched + num_sat_per_launch;
        tracking_vars.num_sats_awaiting_launch = tracking_vars.num_sats_awaiting_launch - num_sat_per_launch;
    else
        tracking_vars.num_sats_launched = tracking_vars.num_sats_launched + tracking_vars.num_sats_awaiting_launch;
        tracking_vars.num_sats_awaiting_launch = 0;
    end
    
    % Record the launch cadence for this launch
    launch_cadences(1, tracking_vars.curr_launch_num) = curr_time_step - tracking_vars.last_launch_time;
    launch_cadences(2:3, tracking_vars.curr_launch_num) = tracking_vars.ready_q(:,1);
    
    %Consume a rocket from the queue of ready rockets for the launch
    tracking_vars.ready_q = tracking_vars.ready_q(:, 2:end);
    [num_rows, num_columns] = size(tracking_vars.ready_q);
    tracking_vars.num_rockets_ready = num_columns;
    
    %Place any reusable stages into refurb
    if design_variables.stage1.reusable == true
    tracking_vars = place_rocket_in_refurb(1, tracking_vars, curr_time_step, launcher_refurb_times);
    end
    if design_variables.stage2.reusable == true
    tracking_vars = place_rocket_in_refurb(2, tracking_vars, curr_time_step, launcher_refurb_times);
    end
    
    %Update the last launch time to the current time step
    tracking_vars.last_launch_time = curr_time_step;
end
