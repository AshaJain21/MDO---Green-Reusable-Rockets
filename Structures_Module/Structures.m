%% Structures Module MDO Green Rockets

%Written By: Maranda and Kinjal


%Inputs: Engine Thrust (Engine), Re-entry Shield Material, Structure
%Material, St1&2 radius, structural mass fraction, propellant volume

%Outputs: Rocket Class w/mass and geometry - for Cost and for aero modules
%        
%FOS 1.6-1.7
%SMF = 0.1
%determine mass of shield material required, wall thickness of the aluminum
%body using the aluminum, and the height of the rocket for a given
%propellant volume, get shield thickness required from the heat flux

function [rocket, mass_heatshield] = structures(st1t, st2t, rocket, SMF, reentry_mat, struc_mat)
%intialize constants and other vars
FOS = 1.6; %factor of safety for load on rocket
st1rad = rocket.stage1.radius;
st2rad = rocket.stage2.radius;
re_mat_density = reentry_mat.density; %[kg/m3] %add this on, ignore weight contribution by SMH
re_mat_maxflux = reentry_mat.maxflux; %W/m2 max heat flux the ablative material can undergo w/out failure
strucmat_density = struc_mat.density; %[kg/m3]
sigma_max = struc_mat.fatstrength; %max fatigue stress of material MPA
launch_qrock = rocket.stage1.launchheatflux;
launch_q2 = rocket.stage2.launchheatflux;
re_q1 = rocket.stage1.recoveryheatflux;
re_q2 = rocket.stage2.recoveryheatflux;
%heat flux - get max heat flux from calcs
heatflux = [max(launch_qrock), max(launch_q2), max(re_q1), max(re_q2)]; %heat flux

%get wall thickness
A1 = FOS*st1t/sigma_max; %get area required to accomodate this stress w/chosen FOS
R_inner1 = sqrt(st1rad^2 - A1/pi); %inner radius [m]
wallst1 = st1rad - R_inner1; %[m]

A2 = FOS*st2t/sigma_max; %get area required to accomodate this stress w/chosen FOS
R_inner2 = sqrt(st2rad^2 - A2/pi); %inner radius [m]
wallst2 = st2rad - R_inner2; %[m]

%take largest required wallthickness
wall = [wallst1, wallst2];
wallthickness = max(wall);
%rocket.stage1.wallthick = wallthickness; Do not need the wall thickness
%for any other module?

%rocket structural mass is a fraction of the propellant mass (cost calcs)
rocket.stage1.strucmass = rocket.stage1.propmass*SMF;  
rocket.stage2.strucmass = rocket.stage2.propmass*SMF; 

st1volume = rocket.stage1.strucmass/strucmat_density; %volume of stage 1
st2volume = rocket.stage2.strucmass/strucmat_density; %volume of stage 2

%get height of each stage
st1h = st1volume/(pi*(st1rad^2-R_inner1^2));%[m]
rocket.stage1.height = st1h; %[m]
st2h = st2volume/(pi*(st2rad^2-R_inner2^2));%[m]
rocket.stage2.height = st2h; %[m]

%size shield thickness via max heat flux, ignore time for now but later %this must be updated to include how long that walue of heat flux is held
%for, so we can decrease the thickness predicted here, its probably ~4mm so
%this estimate may be too thick for now
maxq = max(heatflux); %W/m^2 max heat flux at any point in flight

if maxq > re_mat_maxflux %if max heat flux is higher than the shield capacity
    
    

reshieldthick = 0.0508; %[m] shield thickness 2 inches SHOULD THIS BE CALCULATED LATER?

%get mass of shield material required for cost
SAst2 = pi*st2rad^2*st2h; %only need it for the upper stage for re-entry
vol_heatshield = SAst2*reshieldthick;
mass_heatshield = vol_heatshield*re_mat_density; %[kg]



end

