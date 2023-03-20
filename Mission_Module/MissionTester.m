clear

%BASE PARAMETER DEFINITIONS
parameters.mass_per_satellite = 600; %[kg], v2.0 starlink satellites (from https://en.wikipedia.org/wiki/Starlink)
parameters.num_of_satellites = 8000; %[# of satellites], based on 110 satellites per plane over 48 planes at 340km altitude (from https://www.nasaspaceflight.com/2022/12/spacex-starlink-5-1-launch/)
parameters.delivery_time = 60; %[months] NEED REFERENCE
parameters.rocket_fleet_size = 0; %[# of boosters, counted based on https://en.wikipedia.org/wiki/List_of_Falcon_9_first-stage_boosters counting just boosters awaiting assignment or ready for launch (boosters being refurbished not included)
parameters.init_sat_prod_time = 10;%0.03;%120; %months per satelite (from https://www.cnbc.com/2020/08/10/spacex-starlink-satellte-production-now-120-per-month.html)
parameters.launcher_refurb_times = [60,30]; %[days] (from rough numbers at https://www.quora.com/How-does-SpaceX-refurbish-their-Falcon-9-rockets-after-they-land-How-long-does-it-take)
parameters.launcher_prod_time_bins = [3,6,9; 0.5,0.5, 36];
parameters.sat_prod_learning_rate = 0.6;
parameters.first_stage_prod_percentage = 0.7;


%Create fast, no fleet parameters
parameters_fast_nofleet = parameters;

%Create fast with fleet parameters
parameters_fast_fleet = parameters;
parameters_fast_fleet.rocket_fleet_size = 10;

%Create slow with fleet parameters
parameters_slow_fleet = parameters;
parameters_slow_fleet.init_sat_prod_time = 30;
parameters_slow_fleet.rocket_fleet_size = 10;

%Create slow, no fleet parameters
parameters_slow_nofleet = parameters;
parameters_slow_nofleet.init_sat_prod_time = 0.3;

fprintf('========================\n')
%TEST MISSION 1
fprintf('>> Test case 1: Fleet of 10, num_launches < fleet_size, fast satellite production (10 months per sat)')
design_variables.stage1.reusable=1;
design_variables.stage2.reusable=1;
design_variables.num_of_launches=10;
design_variables.rocket_ri = 5;
[launch_cadences, rocket] = run_mission_module(design_variables, parameters_fast_fleet)
total_time = sum(launch_cadences(1,:))
fprintf('\n========================\n')

% %TEST MISSION 2
fprintf('>> Test case 2: Fleet of 10, num_launches > fleet_size, fast satellite production (10 months per sat)')
design_variables.stage1.reusable=1;
design_variables.stage2.reusable=1;
design_variables.num_of_launches=100;
design_variables.rocket_ri = 5;
[launch_cadences, rocket] = run_mission_module(design_variables, parameters_fast_fleet)
total_time = sum(launch_cadences(1,:))
fprintf('\n========================\n')

%TEST MISSION 3
fprintf('>> Test case 3: No fleet, fast satellite production (10 months per sat)')
design_variables.stage1.reusable=1;
design_variables.stage2.reusable=1;
design_variables.num_of_launches=10;
design_variables.rocket_ri = 5;
[launch_cadences, rocket] = run_mission_module(design_variables, parameters_fast_nofleet)
total_time = sum(launch_cadences(1,:))
fprintf('\n========================\n')

% %TEST MISSION 4
fprintf('>> Test case 4: No fleet, no stage 1 reuse, fast satellite production (10 months per sat)')
design_variables.stage1.reusable=0;
design_variables.stage2.reusable=1;
design_variables.num_of_launches=10;
design_variables.rocket_ri = 5;
[launch_cadences, rocket] = run_mission_module(design_variables, parameters_fast_nofleet)
total_time = sum(launch_cadences(1,:))
fprintf('\n========================\n')

% %TEST MISSION 5
fprintf('>> Test case 5: Fleet of 10, num_launches < fleet_size, slow satellite production (30 months per sat)')
design_variables.stage1.reusable=1;
design_variables.stage2.reusable=1;
design_variables.num_of_launches=10;
design_variables.rocket_ri = 5;
[launch_cadences, rocket] = run_mission_module(design_variables, parameters_slow_fleet)
total_time = sum(launch_cadences(1,:))
fprintf('\n========================\n')

%TEST MISSION 6
fprintf('>> Test case 6: Fleet of 10, num_launches > fleet_size, slow satellite production (30 months per sat)')
design_variables.stage1.reusable=1;
design_variables.stage2.reusable=1;
design_variables.num_of_launches=100;
design_variables.rocket_ri = 5;
[launch_cadences, rocket] = run_mission_module(design_variables, parameters_slow_fleet)
total_time = sum(launch_cadences(1,:))
fprintf('\n========================\n')

%TEST MISSION 7
fprintf('>> Test case 7: No fleet, slow satellite production (30 months per sat)')
design_variables.stage1.reusable=1;
design_variables.stage2.reusable=1;
design_variables.num_of_launches=10;
design_variables.rocket_ri = 5;
[launch_cadences, rocket] = run_mission_module(design_variables, parameters_slow_nofleet)
total_time = sum(launch_cadences(1,:))
fprintf('\n========================\n')

%TEST MISSION 8
fprintf('>> Test case 8: No fleet, slow satellite production (30 months per sat), large rocket')
design_variables.stage1.reusable=1;
design_variables.stage2.reusable=1;
design_variables.num_of_launches=10;
design_variables.rocket_ri = 9;
[launch_cadences, rocket] = run_mission_module(design_variables, parameters_slow_nofleet)
total_time = sum(launch_cadences(1,:))
fprintf('\n========================\n')