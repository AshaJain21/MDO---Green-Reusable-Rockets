classdef MissionModule
    properties
        sat_mass %[kg]
        num_sats %[# satellites]
        fleet_size %[# launch vehicles]
        del_window %[months]
        sat_prod_time %[months per satellite]
        booster_refurb_time %[months per booster]
        booster_prod_time %[months per booster]
    end
    methods
        function obj = MissionModule(sat_mass, num_sats, fleet_size, del_window, sat_prod_rate, booster_refurb_time, booster_prod_time)
            obj.sat_mass = sat_mass;
            obj.num_sats = num_sats;
            obj.fleet_size = fleet_size;
            obj.del_window = del_window;
            obj.sat_prod_time = 1/sat_prod_rate;
            obj.booster_refurb_time = booster_refurb_time;
            obj.booster_prod_time = booster_prod_time;
        end
        function [per_launch_mass, launch_cadence] = Run(obj, stg1_reuse, stg2_reuse, num_launches)
            num_sat_per_launch = ceil(obj.num_sats / num_launches);
            per_launch_mass = obj.sat_mass * num_sat_per_launch;
            
            sat_prod_time_per_launch = num_sat_per_launch * obj.sat_prod_time
            
            if num_launches <= obj.fleet_size
                launch_cadence = sat_prod_time_per_launch; %Assume that you can launch as quickly as satellites are produced
            else %NOT WORKING BELOW THIS LINE
                if stg1_reuse==true
                    launch_cadence = ((num_launches-obj.fleet_size)*obj.booster_prod_time*obj.booster_refurb_time) / ( (num_launches-1)*(obj.booster_refurb_time + obj.booster_prod_time)); 
                else
                    launch_cadence = ((num_launches-obj.fleet_size)*obj.booster_prod_time) / (num_launches-1);
                end
            end
        end
    end
    
end