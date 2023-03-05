classdef MissionModule
    properties
        sat_mass
        num_sats
        fleet_size
    end
    methods
        function obj = MissionModule(sat_mass, num_sats, fleet_size)
            obj.sat_mass = sat_mass;
            obj.num_sats = num_sats;
            obj.fleet_size = fleet_size;
        end
        function [per_launch_mass, launch_cadence] = Run(obj, stg1_reuse, stg2_reuse, num_launches)
            test_stg1_reuse = stg1_reuse;
            test_st2_reuse = stg2_reuse;
            test_num_launches = num_launches;
            per_launch_mass = "test";
            launch_cadence = "test";
        end
    end
    
end