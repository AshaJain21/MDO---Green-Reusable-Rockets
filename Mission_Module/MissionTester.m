clear

load('doe_exp5_mission_test_vars.mat')
parameters = setup_parameters();


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
[launch_cadences, rocket] = run_mission_module(design_variables, parameters_fast_fleet)
total_time = sum(launch_cadences(1,:))
fprintf('\n========================\n')

% %TEST MISSION 2
fprintf('>> Test case 2: Fleet of 10, num_launches > fleet_size, fast satellite production (10 months per sat)')
design_variables.stage1.reusable=1;
design_variables.stage2.reusable=1;
design_variables.num_of_launches=100;
[launch_cadences, rocket] = run_mission_module(design_variables, parameters_fast_fleet)
total_time = sum(launch_cadences(1,:))
fprintf('\n========================\n')

%TEST MISSION 3
fprintf('>> Test case 3: No fleet, fast satellite production (10 months per sat)')
design_variables.stage1.reusable=1;
design_variables.stage2.reusable=1;
design_variables.num_of_launches=10;
[launch_cadences, rocket] = run_mission_module(design_variables, parameters_fast_nofleet)
total_time = sum(launch_cadences(1,:))
fprintf('\n========================\n')

% %TEST MISSION 4
fprintf('>> Test case 4: No fleet, no stage 1 reuse, fast satellite production (10 months per sat)')
design_variables.stage1.reusable=0;
design_variables.stage2.reusable=1;
design_variables.num_of_launches=10;
[launch_cadences, rocket] = run_mission_module(design_variables, parameters_fast_nofleet)
total_time = sum(launch_cadences(1,:))
fprintf('\n========================\n')

% %TEST MISSION 5
fprintf('>> Test case 5: Fleet of 10, num_launches < fleet_size, slow satellite production (30 months per sat)')
design_variables.stage1.reusable=1;
design_variables.stage2.reusable=1;
design_variables.num_of_launches=10;
[launch_cadences, rocket] = run_mission_module(design_variables, parameters_slow_fleet)
total_time = sum(launch_cadences(1,:))
fprintf('\n========================\n')

%TEST MISSION 6
fprintf('>> Test case 6: Fleet of 10, num_launches > fleet_size, slow satellite production (30 months per sat)')
design_variables.stage1.reusable=1;
design_variables.stage2.reusable=1;
design_variables.num_of_launches=100;
[launch_cadences, rocket] = run_mission_module(design_variables, parameters_slow_fleet)
total_time = sum(launch_cadences(1,:))
fprintf('\n========================\n')

%TEST MISSION 7
fprintf('>> Test case 7: No fleet, slow satellite production (30 months per sat)')
design_variables.stage1.reusable=1;
design_variables.stage2.reusable=1;
design_variables.num_of_launches=10;
[launch_cadences, rocket] = run_mission_module(design_variables, parameters_slow_nofleet)
total_time = sum(launch_cadences(1,:))
fprintf('\n========================\n')

%TEST MISSION 8
fprintf('>> Test case 8: No fleet, slow satellite production (30 months per sat), large rocket')
design_variables.stage1.reusable=1;
design_variables.stage2.reusable=1;
design_variables.num_of_launches=10;
design_variables.rocket_ri = 4.5;
[launch_cadences, rocket] = run_mission_module(design_variables, parameters_slow_nofleet)
total_time = sum(launch_cadences(1,:))
fprintf('\n========================\n')