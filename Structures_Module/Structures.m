%% Structures Module MDO Green Rockets

%Written By: Maranda and Kinjal

%Inputs: Engine Thrust (Engine), Re-entry Shield Material, Structure
%Material, St1&2 radius, structural mass fraction, propellant volume

%Outputs: Rocket Class w/mass and geometry - for Cost and for aero modules
%determine mass of shield material required, wall thickness of the aluminum
%body using the aluminum, and the height of the rocket for a given
%propellant volume, get shield thickness required from the heat flux

%reentryshield material cell array: name,density,heatflux,temperature,cost

function [rocket, CHECK] = Structures(design_variables, parameters, rocket)
%intialize constants and other vars
FOS = 1.4; %factor of safety for load on rocket
%SMF = parameters.struc_to_propellant_mass_ratio; Rewriting code to be in
%terms of structural mass quantities instead of struc mass fraction
ri = design_variables.rocket_ri;
st1prop = design_variables.mprop1_guess;
st2prop = design_variables.mprop2_guess;
%st1mass = rocket.stage1.mstruct;
%st2mass = rocket.stage2.mstruct;
%thrust1 = design_variables.stage1.engine_prop.thrust{1,10};
thrust2 = design_variables.stage2.engine_prop{1,10};
payh = rocket.payload_height; %get volume of satellites available 
%that fit into the given ri
re_mat_density = design_variables.stage2.reentry_shield_material.Density; %[kg/m3] %add this on, ignore weight contribution by SMH
% re_mat_maxflux = design_variables.stage2.reentry_shield_material{3}; %W/m2 max heat flux the ablative material can undergo w/out failure
strucmat_density = parameters.structural_material.density; %[kg/m3]
sigma_max = parameters.structural_material.fatigue_stress; %max fatigue stress of material MPA
prop_f1 = design_variables.stage1.engine_prop{1,2};
prop_ox1 = design_variables.stage1.engine_prop{1,3};
prop_f2 = design_variables.stage2.engine_prop{1,2};
prop_ox2 = design_variables.stage2.engine_prop{1,3};
%parameters.propellant_properties{1,4}; %CHERCH THIS 4th column = density
%[prop_df1, prop_dox1] = getpropdensity();
%[prop_df2, prop_dox2] = getpropdensity();
% launch_qrock = rocket.stage1.launch_qdot;
% launch_q2 = rocket.stage2.launch_qdot;
% re_q1 = rocket.stage1.recovery_qdot;
% re_q2 = rocket.stage2.recovery_qdot;
% st1mass = rocket.stage1.mstruct; %rocket dry mass stage1
% st2mass = rocket.stage2.mstruct;
%heat flux - get max heat flux from calcs
% heatflux = [max(launch_qrock), max(launch_q2), max(re_q1), max(re_q2)]; %heat flux

%% Calculate stage height needed to fit payload, and propellant masses
%Stage 1
vprop1 = st1prop/prop_d; %m^3
st1h = vprop1/(pi*ri^2); %vcylinder = pi*r^2*h;
rocket.stage1.height = st1h;

%Stage 2
vprop2 = st2prop/prop_d; %m^3
%combined height needed for propellant vol and payload vol
st2h = vprop2/(pi*ri^2) + payh; 
rocket.stage2.height = st2h;

%% Calculate wall thickness based on known rocket mass and height
%Stage 1
st1vol = st1mass/strucmat_density; %maxx vol allowed; 
%get ro
A = st1vol/(pi*st1h) ;% ro^2-ri^2
ro_st1 = sqrt(A + ri^2); %outer radius stag1
wallst1 = ro_st1 - ri; %[m]

%Stage 2
st2vol = st2mass/strucmat_density; %maxx vol allowed; 
%get ro
A2 = st2vol/(pi*st2h) ;% ro^2-ri^2
ro_st2 = sqrt(A2 + ri^2); %outer radius stage2
wallst2 = ro_st2 - ri; %[m]

% check is the minimum wall thickness for this ok, also they need to have
%  the same wall thickness, take the thinner one? FOR NOW
%Stage 1
A1check = FOS*thrust1/sigma_max; %get area required to accomodate this stress w/chosen FOS
ro_check1 = sqrt(A1check/pi + ri^2);
t = ro_check1 - ri;
%Stage2
A2check = FOS*thrust2/sigma_max; %get area required to accomodate this stress w/chosen FOS
ro_check2 = sqrt(A2check/pi + ri^2);
t2 = ro_check2 - ri;

CHECK = [1, 1];
if wallst1 < t
    fprintf(['Stage 1 wall thickness for given Stage 1 mass and height'...                 %unsure if i need to check other limits?max q?
        'is not enough to support maximum thrust in flight']);
    CHECK(1) = 0;
elseif wallst2 < t
    fprintf(['Stage 2 wall thickness for given Stage 2 mass and height'...                 %unsure if i need to check other limits?max q?
        'is not enough to support maximum thrust in flight']);
    CHECK(2) = 0;
elseif wallst2 < t2
    fprintf(['Stage 2 wall thickness for given Stage 2 mass and height'...                 %unsure if i need to check other limits?max q?
        'is not enough to support maximum thrust in flight']);
    CHECK(2) = 0;
elseif wallst1 < t2
    fprintf('More mass required such that stage 1 and 2 have same wall thickness');
else 
    fprintf('PASSED!');
end 

%% Recalculate Structural masses
%if all pass, take the thicker for mass required and update
%final masses 
%stages must have same wall thicknes
if CHECK(1) == 1
    if wallst1 < wallst2 && wallst2 > t2
        fprintf("Stage 1 Wall Thickness Recalc");
        vol = pi*(ro_st2^2 -ri^2)*st1h;
        %new mass
        rocket.stage1.mstruct =vol*strucmat_density;
        rocket.ro = ro_st2;
    elseif wallst1 < wallst2 && wallst2 < t2
        fprintf("Stage 1 Wall Thickness Recalc");
        vol = pi*(ro_check2^2 -ri^2)*st1h;
        %new mass
        rocket.stage1.mstruct =vol*strucmat_density;
        rocket.ro = ro_check2;
    end
elseif CHECK(1) == 0
%recalc
    if wallst1 < wallst2 && wallst2 > t2
        fprintf("Stage 1 Wall Thickness Recalc");
        vol = pi*(ro_st2^2 -ri^2)*st1h;
        %new mass
        rocket.stage1.mstruct = vol*strucmat_density;
        rocket.ro = ro_st2;
    elseif wallst1 < wallst2 && wallst2 < t2
        fprintf("Stage 1 Wall Thickness Recalc");
        vol = pi*(ro_check2^2 -ri^2)*st1h;
        %new mass
        rocket.stage1.mstruct =vol*strucmat_density;
        rocket.ro = ro_check2;
    elseif wallst1 > wallst2 %we know t1>wallst1
        vol = pi*(ro_check1^2 -ri^2)*st1h;
        %new mass
         rocket.stage1.mstruct =vol*strucmat_density;
         rocket.ro = ro_check1;
    end
end

if CHECK(2) == 1
    if wallst2 < wallst1 && wallst1 > t
        fprintf("Stage 2 Wall Thickness Recalc");
        vol = pi*(ro_st1^2 -ri^2)*st2h;
        %new mass
        rocket.stage2.mstruct =vol*strucmat_density;
    elseif wallst2 < wallst1 && wallst1 < t
        fprintf("Stage 2 Wall Thickness Recalc");
        vol = pi*(ro_check1^2 -ri^2)*st2h;
        %new mass
        rocket.stage2.mstruct =vol*strucmat_density;
    end
elseif CHECK(1) == 0
%recalc
    if wallst2 < wallst1 && wallst > t
        fprintf("Stage 2 Wall Thickness Recalc");
        vol = pi*(ro_st1^2 -ri^2)*st2h;
        %new mass
        rocket.stage2.mstruct = vol*strucmat_density;
    elseif wallst2 < wallst1 && wallst < t
        fprintf("Stage 2 Wall Thickness Recalc");
        vol = pi*(ro_check1^2 -ri^2)*st2h;
        %new mass
        rocket.stage2.mstruct =vol*strucmat_density;
    elseif wallst2 > wallst1 %we know t1>wallst1
        vol = pi*(ro_check2^2 -ri^2)*st2h;
        %new mass
         rocket.stage2.mstruct =vol*strucmat_density;
    end
end

%check constraints - 

%% Size shield thickness via max heat flux
%ignore time for now but later %this must be updated to include how long that walue of heat flux is held
%for, so we can decrease the thickness predicted here, its probably ~4mm so
%this estimate may be too thick for now
% maxq = max(heatflux); %W/m^2 max heat flux at any point in flight

%if maxq > re_mat_maxflux %if max heat flux is higher than the shield capacity 

reshieldthick = 0.0508; %[m] shield thickness 2 inches SHOULD THIS BE CALCULATED LATER?
%get mass of shield material required for cost
SAst2 = pi*rocket.ro*2*st2h; %only need it for the upper stage for re-entry
vol_heatshield = SAst2*reshieldthick;
heat_shield_mass = vol_heatshield*re_mat_density; %[kg]
rocket.stage2.heat_shield_SA = SAst2; %[m2] surface area of the heat sheild required
rocket.stage2.heatshield_mass = heat_shield_mass;


end

