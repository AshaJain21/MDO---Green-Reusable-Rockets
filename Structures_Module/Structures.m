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

%reentryshield material cell array: name,density,heatflux,temperature,cost

function [rocket] = Structures(design_variables, parameters, rocket)
%intialize constants and other vars
FOS = 1.6; %factor of safety for load on rocket
SMF = parameters.struc_to_propellant_mass_ratio;
ri = design_variables.rocket_ri;
st1prop = rocket.stage1.mprop;
st2prop = rocket.stage2.mprop;
re_mat_density = design_variables.stage2.reentry_shield_material.Density; %[kg/m3] %add this on, ignore weight contribution by SMH
% re_mat_maxflux = design_variables.stage2.reentry_shield_material{3}; %W/m2 max heat flux the ablative material can undergo w/out failure
strucmat_density = parameters.structural_material.density; %[kg/m3]
sigma_max = parameters.structural_material.fatigue_stress; %max fatigue stress of material MPA
% launch_qrock = rocket.stage1.launch_qdot;
% launch_q2 = rocket.stage2.launch_qdot;
% re_q1 = rocket.stage1.recovery_qdot;
% re_q2 = rocket.stage2.recovery_qdot;
st1mass = rocket.stage1.mstruct; %rocket dry mass stage1
st2mass = rocket.stage2.mstruct;
%heat flux - get max heat flux from calcs
% heatflux = [max(launch_qrock), max(launch_q2), max(re_q1), max(re_q2)]; %heat flux

%get wall thickness
A1 = FOS*rocket.stage1.thrust/sigma_max; %get area required to accomodate this stress w/chosen FOS
R_outer1 = sqrt(ri^2 + A1/pi); %outer radius [m]
wallst1 = R_outer1 - ri; %[m]

A2 = FOS*rocket.stage2.thrust/sigma_max; %get area required to accomodate this stress w/chosen FOS
R_outer2 = sqrt(ri^2 + A2/pi); %inner radius [m]
wallst2 = R_outer2 - ri; %[m]

%take largest required wallthickness/radius
rout = [R_outer1, R_outer2];
rocket.ro = max(rout); %get out outer radius of rocket

%wall = [wallst1, wallst2];
%wallthickness = max(wall);
%rocket.stage1.wallthick = wallthickness; Do not need the wall thickness
%for any other module?

%rocket structural mass is a fraction of the propellant mass (cost calcs)
rocket.stage1.mstruct = st1prop*SMF;  
rocket.stage2.mstruct = st2prop*SMF; 

st1volume = st1mass/strucmat_density; %volume of stage 1
st2volume = st2mass/strucmat_density; %volume of stage 2

%get height of each stage
st1h = st1volume/(pi*(R_outer1^2 -ri^2));%[m]
rocket.stage1.height = st1h; %[m]
st2h = st2volume/(pi*(R_outer2^2 - ri^2));%[m]
rocket.stage2.height = st2h; %[m]

%size shield thickness via max heat flux, ignore time for now but later %this must be updated to include how long that walue of heat flux is held
%for, so we can decrease the thickness predicted here, its probably ~4mm so
%this estimate may be too thick for now
% maxq = max(heatflux); %W/m^2 max heat flux at any point in flight

%if maxq > re_mat_maxflux %if max heat flux is higher than the shield capacity 

reshieldthick = 0.0508; %[m] shield thickness 2 inches SHOULD THIS BE CALCULATED LATER?

%get mass of shield material required for cost
SAst2 = pi*ri^2*st2h; %only need it for the upper stage for re-entry
vol_heatshield = SAst2*reshieldthick;
rocket.stage2.heat_shield_mass = vol_heatshield*re_mat_density; %[kg]



end

