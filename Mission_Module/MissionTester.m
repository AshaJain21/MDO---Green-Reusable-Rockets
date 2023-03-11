import MissionModule.*

%PARAMETER DEFINITIONS
sat_mass = 1250; %[kg], v2.0 starlink satellites (from https://en.wikipedia.org/wiki/Starlink)
num_sats = 5280; %[# of satellites], based on 110 satellites per plane over 48 planes at 340km altitude (from https://www.nasaspaceflight.com/2022/12/spacex-starlink-5-1-launch/)
del_window = 48; %[months] NEED REFERENCE
fleet_size = 15; %[# of boosters, counted based on https://en.wikipedia.org/wiki/List_of_Falcon_9_first-stage_boosters counting just boosters awaiting assignment or ready for launch (boosters being refurbished not included)
sat_prod_time = 0.025;%120; %satellites per month (from https://www.cnbc.com/2020/08/10/spacex-starlink-satellte-production-now-120-per-month.html)
booster_refurb_time = 60/30; %[days] (from rough numbers at https://www.quora.com/How-does-SpaceX-refurbish-their-Falcon-9-rockets-after-they-land-How-long-does-it-take)
booster_prod_time = 18; %[days] (from rough numbers at https://space.stackexchange.com/questions/10003/how-long-does-it-take-to-build-a-falcon-9-rocket)
LR = 0.9;

mm = MissionModule(sat_mass, num_sats, fleet_size, del_window, sat_prod_time, booster_refurb_time, LR);

fprintf('========================\n')
%TEST MISSION 1
fprintf('>> Test case where num_launches < fleet_size')
stg1_reuse=true;
stg2_reuse=true;
num_launches=2;
[per_launch_mass, launch_cadences] = mm.Run(stg1_reuse, stg2_reuse, num_launches, 5)
total_time = sum(launch_cadences)
fprintf('\n========================\n')

%TEST MISSION 2
fprintf('>> Test case where num_launches > fleet_size')
stg1_reuse=true;
stg2_reuse=true;
num_launches=30;
[per_launch_mass, launch_cadences] = mm.Run(stg1_reuse, stg2_reuse, num_launches, 5)
total_time = sum(launch_cadences)
fprintf('========================\n')