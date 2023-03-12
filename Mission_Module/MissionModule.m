classdef MissionModule
    properties
        sat_mass %[kg]
        num_sats %[# satellites]
        fleet_size %[# launch vehicles]
        del_window %[months]
        sat_prod_times %[months per satellite]
        size_ubs %size bounds for the rocket size bins
        launcher_refurb_time %[months per launcher]
        launcher_prod_times %[months per launcher]
        LR %learning rate

    end
    methods
        function obj = MissionModule(sat_mass, num_sats, fleet_size, del_window, init_sat_prod_time, booster_refurb_time, LR)
            
            obj.sat_mass = sat_mass;
            obj.num_sats = num_sats;
            obj.fleet_size = fleet_size;
            obj.del_window = del_window;
            obj.launcher_refurb_time = booster_refurb_time;
            obj.LR = LR;

            sat_vec =  1:obj.num_sats;
            obj.sat_prod_times = init_sat_prod_time*sat_vec.^(log(obj.LR)/log(2));

            obj.size_ubs = [3,6,9]; %1st bin driven by electron, 2nd bin driven by falcon 9, large bin driven by SLS
            obj.launcher_prod_times = [0.5, 0.5, 36];
        end
        function [per_launch_mass, launch_cadences, additional_rockets_available] = Run(obj, stg1_reuse, stg2_reuse, num_launches, launcher_radius)
            
            %CALCULATE MASS PER LAUNCH (DIVIDE EVENLY)
            num_sat_per_launch = ceil(obj.num_sats / num_launches);
            per_launch_mass = obj.sat_mass * num_sat_per_launch;

            %DETERMINE LAUNCHER PRODUCTION TIME BASED ON REQUIRED LAUNCHER
            %RADIUS
            for i=1:length(obj.size_ubs)
                size_cat=obj.size_ubs(i);
                if launcher_radius <= size_cat
                    launcher_prod_time = obj.launcher_prod_times(i);
                    break
                end
            end

%             fprintf('============Starting Numbers============\n')
            %SET UP TRACKING VARIABLES FOR SIMULATION
            num_sats_produced = 0;
            num_sats_awaiting_launch = 0;
            num_sats_launched = 0;
            num_launchers_available = obj.fleet_size;
            next_sat_prod_time=obj.sat_prod_times(1);
            next_launcher_prod_time = launcher_prod_time;
            next_launcher_refurb_time = obj.launcher_refurb_time;
            curr_time_step = 0;
            last_launch_time = 0;
            launch_cadences = [];
            additional_rockets_available = 0;

            while num_sats_launched < obj.num_sats
                
                if num_sats_produced < obj.num_sats
                    curr_time_step = min([next_sat_prod_time, next_launcher_prod_time, next_launcher_refurb_time]);
                else
                    curr_time_step = min([next_launcher_prod_time, next_launcher_refurb_time]);
                end

                % PRODUCE WHATEVER SHOULD BE PRODUCED AT THIS TIME
                if (curr_time_step == next_sat_prod_time) && (num_sats_produced < obj.num_sats)
%                     fprintf('\nSatellite being produced!\n')
                    num_sats_produced = num_sats_produced + 1;
                    num_sats_awaiting_launch = num_sats_awaiting_launch + 1;
                    if num_sats_produced < obj.num_sats
                        next_sat_prod_time = curr_time_step + obj.sat_prod_times(num_sats_produced+1);
                    end

%                 elseif (curr_time_step == next_sat_prod_time) && (num_sats_produced >= obj.num_sats)
%                     fprintf('\nSAT PRODUCTION COMPLETE! NO FURTHER SATS PRODUCED\n')
%                     break
                end


                if curr_time_step == next_launcher_prod_time
%                     fprintf('\nLauncher being produced!\n')
                    num_launchers_available = num_launchers_available + 1;
                    next_launcher_prod_time = curr_time_step + launcher_prod_time;
                    additional_rockets_available = additional_rockets_available + 1;
                end

                if curr_time_step == next_launcher_refurb_time
%                     fprintf('\nLauncher being refurbished!\n')
                    num_launchers_available = num_launchers_available + 1;
                    next_launcher_refurb_time = curr_time_step + obj.launcher_refurb_time;
                    additional_rockets_available = additional_rockets_available + 1;
                end

                % CHECK TO SEE IF WE CAN LAUNCH ANYTHING YET (ASSUMES
                % LAUNCH ON DEMAND)
                if (num_sats_awaiting_launch >= num_sat_per_launch) && (num_launchers_available >= 1)
%                     fprintf('============Launch!============\n')
                    num_sats_launched = num_sats_launched + num_sat_per_launch;
                    num_sats_awaiting_launch = num_sats_awaiting_launch - num_sat_per_launch;
                    num_launchers_available = num_launchers_available - 1;
                    launch_cadences(end+1) = curr_time_step - last_launch_time;
                    last_launch_time = curr_time_step;

                end
            end
        end
    end
    
end