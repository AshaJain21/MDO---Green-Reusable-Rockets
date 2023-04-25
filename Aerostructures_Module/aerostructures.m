%% Aerostructures Module
%MDO Green Rockets
%Written By: Maranda

%Inputs: Design variables, parameters, rocket
%Outputs: Rocket Class w/mass and geometry, heat shield geometry, CHECKS

%Checks I am unsure about: velocity checks? mf>(mi-mprop)?

function [rocket] = aerostructures(design_variables, parameters, rocket)
%intialize constants and other vars
FOS = 1.2; %factor of safety for load on rocket
g = 9.81; %m/s2
ri = design_variables.rocket_ri; %rocket inner radius
st1prop = design_variables.mprop1_guess; %initial prop mass guess
st2prop = design_variables.mprop2_guess; %init prop mass guess stage 2
t1 = design_variables.stage1.engine_prop{1,10}; %thrust
t2 = design_variables.stage2.engine_prop{1,10};
DE1 =design_variables.stage1.engine_prop{1,8}; %engine exit diameter
DE2 =design_variables.stage2.engine_prop{1,8};
rocket.stage1.nEng = calc_inscribed_circles(DE1/2, ri);
stg1_neng = rocket.stage1.nEng;
rocket.stage1.thrust = t1*rocket.stage1.nEng;
thrust1 = rocket.stage1.thrust;
rocket.stage2.nEng = calc_inscribed_circles(DE2/2, ri);
rocket.stage2.thrust = t2*rocket.stage2.nEng;
thrust2 = rocket.stage2.thrust;
stg2_neng = rocket.stage2.nEng;
reuse1 = design_variables.stage1.reusable;
reuse2 = design_variables.stage2.reusable;
mass_eng_st1 = stg1_neng*design_variables.stage1.engine_prop{1,9}; %mass of engines
mass_eng_st2 = stg2_neng*design_variables.stage2.engine_prop{1,9}; %mass of engines
%mdot = f/(isp*g)= mdot
st1ve = g*design_variables.stage1.engine_prop{1,4}; %effective exhaust ve
st2ve = g*design_variables.stage2.engine_prop{1,4};

payh = rocket.payload_height; %get volume of satellites available 
re_mat_density = design_variables.stage2.reentry_shield_material.Density; %[kg/m3] 
strucmat_density = parameters.structural_material.density; %[kg/m3]
sigma_max = parameters.structural_material.fatigue_stress; %max fatigue stress of material MPA
pay_mass = rocket.payload; %pyload mass [kg]
%% get propellat properties

[prop_f1_density, prop_f2_density, prop_ox1_density, prop_ox2_density] =...
    getpropdensity(design_variables, parameters);

%% Calculate propellant volume
OF_prop1 = design_variables.stage1.engine_prop{1,6}; %prop mixing ratio
%massfraction = 1/3.72 vs 2.72/3.72
prop_f1_mass = st1prop*(1/(1+OF_prop1)); %total fuel mass
prop_ox1_mass = st1prop*(OF_prop1/(1+OF_prop1)); %total ox mass
%total stage 1 propellant volume
propvol_st1 = prop_f1_mass/prop_f1_density + prop_ox1_mass/prop_ox1_density;

OF_prop2 = design_variables.stage2.engine_prop{1,6}; %prop mixing ratio
prop_f2_mass = st2prop*(1/(1+OF_prop2)); %total fuel mass
prop_ox2_mass = st2prop*(OF_prop2/(1+OF_prop2)); %total ox mass
%total stage 2 propellant volume
propvol_st2 = prop_f2_mass/prop_f2_density + prop_ox2_mass/prop_ox2_density;


%% Calculate stage height needed to fit payload, and propellant
%Stage 1
st1h = propvol_st1/(pi*ri^2); %vcylinder = pi*r^2*h;
rocket.stage1.height = st1h;

%Stage 2
%combined height needed for propellant vol and payload vol
st2h = propvol_st2/(pi*ri^2) + payh; 
rocket.stage2.height = st2h;

%% Calculate wall thickness and rocket outer radius
%based on known rocket stage thrust and height
%Will need to rerun if max q is not met

[ro] = calc_wallthick(thrust1,thrust2,ri, FOS, sigma_max);

%% Calculate Structural masses

[st1mass, st2mass, heat_shield_mass, SAst2] =...
    struct_calc(st1h,st2h, strucmat_density, ro, ri, re_mat_density);

%% Aerodynamics - set up parameters
reangle = parameters.reentry_angle;
g = 9.81; %m/s2 accel due to grav
%LEO =<2000 km from SpaceX website ~500 km circular
LEOalt = parameters.orbital_altitude*1000; % [m]  
%orbit @98.9 deg inclination
stgsep = 75e3; %[m] stage separation altitude
h = 0:500:stgsep; %altitude array --> launch until stage separation (75km),
%calculate every 500 m
h2 = stgsep:1000:LEOalt; %altitude array for stage 2 75km to LEO 500 km

%% Launch
%Stage 1
%generate wetted surface area calculation for the flight ->assume parabolic
%mx^2 + bx + c c=0 at t=0, dy/dx  
%theta_l = 0; %launch angle - parabolic y = x^2
%rocket_Sb_launch = pi*ro*2*st2h/cos(theta_l) + pi*ro*2*st1h/cos(theta_l);
mdotst1_f = thrust1/st1ve; %total thrust for all engines
%st1ve = thrust1/mdotst1_f;                                                  
fc = mdotst1_f/st1ve;  %fuel consumption kg per metre; 

mdotst2_f = thrust2/st2ve; %total thrust for all engines
fc2 = mdotst2_f/st2ve;  %fuel consumption kg per metre; 

%Run Aero Launch function (Full Stage 1 and 2 launch to LEO)
[maxq] = launch(h, h2,ro,fc, fc2, st1mass,st1prop,st2prop,st2mass,...
    pay_mass,heat_shield_mass,mass_eng_st1,mass_eng_st2, st1ve, st2ve);

%Check max q ensure wall thickness is enough
%Constraint on wall thickness for max q
%q = stress FOS*thrust/sigma_max = area needed

if maxq > sigma_max
    %fprintf(['Wall thickness for rocket'...                 
     %   'is not enough to support max q in flight']);
    %RERUN STRUCTURES-
    %replace sigma_max with maxq
    ro = calc_wallthick(thrust1,thrust2,ri, FOS, maxq);

    %Calculate updated Structural masses to handle max q
    [st1mass, st2mass, heat_shield_mass, SAst2] =...
        struct_calc(st1h,st2h, strucmat_density, ro, ri, re_mat_density);
% else 
%     fprintf('Wall Thickness Supports Max Q');
end 


%% Calculate FINAL Structural masses
%Stage 1
rocket.ro = ro;
vol = pi*(ro^2 -ri^2)*st1h;
rocket.stage1.mstruct =vol*strucmat_density;

rocket.stage1.mass_eng = mass_eng_st1;
%ROCKET ENGINE MASS
vol2 = pi*(ro^2 -ri^2)*st2h;
rocket.stage2.mstruct =vol2*strucmat_density;
rocket.stage2.mass_eng = mass_eng_st2;

rocket.stage2.heat_shield_SA = SAst2; %[m2] surface area of the heat shield required
rocket.stage2.heatshield_mass = heat_shield_mass;

%% Terminal Velocities
%Landing
if reuse1 == 1 %boost back, landing burn needed 
    st1mpb = st1mass; %(mass post burn, still have some left over for landing)
    st1_Sb_recovery = ro*2*st1h/cos(deg2rad(reangle)); %projected SA 
    %st1_cross_recovery = pi*ro^2; %%cross sectional area at angle of fall 
    %(assume stg1 fall straight vertically)
    %st1tv = zeros(1,length(h));
    %ust1 = zeros(1,length(h));
    %ust1(1) = 0; %assume 0 velocity at separation (after the "boost back")
  %for i = 2:length(h)
     [~,~,~, rho] = atmoscoesa(500);%, 'None'); %calculate terminal vel @ 500 m
      %delv = 2*g*500; %projectile motion NOT SURE IF THIS APPLIES FIXEEEEEE
      %ust1(i) = ust1(i-1) + 2*(-g); %calculate velocity of rocket (downwards)
      Cd = 1.17; %FOR NOW
      st1tv = sqrt(2*st1mpb*g/rho*st1_Sb_recovery*(Cd)); %goes from high alt to end
  %end  
       rocket.stage1.terminal_velocity = st1tv; %where do you want terminal velocity? MAX? ASK ASHA / JUSTIN
end
%Re-entry from LEO Stg 2 %heat flux %angle, radius, length of stg2 - 
if reuse2 == 1 %re-entry, landing burn needed + belly flop
    st2mpb = st2mass; %(mass post burn, t over for landing)
    %cross sectional area at angle of fall
    st2_cross_recovery = pi*ro^2/cos(deg2rad(reangle)); 
    st2_Sb_recovery = ro*2*st2h/cos(deg2rad(reangle)); %total wetted area not sure which to use!!!!!!!!!!!!!!!!!!!!!!
    alt = 500:2000:LEOalt; %full altitude of deorbit [m]
    st2tv = zeros(1,length(alt));
    ust2 = zeros(1,length(alt));
    ust2(1) = 7.2e3; %assume a deorbit velocity of ~7.2 km/s from staging paper
    q = zeros(1,length(alt)); %rocket dynamic pressure
    %[~,~,~, rho1] = atmoscoesa(LEOalt, 'None');
    q(1) = 0; %neglect air drag here
%time = zeros(1, (length(h) + length(h2))-1) ;%per m total time for reaching LEO
%accel = zeros(1,length(h));
    for i = 2:(length(alt)) 
       if alt(end-i+1) > 84852
           rho =0; %neglect drag
            %[~,~,~, rho] = atmoscoesa(84852); %change this later
       else
            [~,~,~, rho] = atmoscoesa(alt(end-i+1), 'None'); %start at altitude of sep.
       end
       Cd = 1.17; %FOR NOW
        %[~,~,~,rho] = atmoscoesa(h(i), 'None');
       D = q(i-1)*st2_Sb_recovery*Cd; %CD cylinder
       accel = D/st2mpb - g; %drag and gravity
       ust2(i) =sqrt( (ust2(i-1))^2 + 2*accel*2000); %500 m
       q(i) = 0.5*rho*ust2(i)^2; %dynamic pressure
       %need final velocity 500 m above ground
       st2tv(i) = sqrt(2*st2mpb*g/rho*st2_Sb_recovery*(Cd)); %goes from high alt to end
    end
      rocket.stage2.terminal_velocity = st2tv(end); %IMPLEMENT TOTAL DRY MASS + NOT TERMINAL VELOCITY
end


end

function [prop_f1_density, prop_f2_density, prop_ox1_density, prop_ox2_density] =...
    getpropdensity(design_variables, parameters)
%get names
prop_f1 = design_variables.stage1.engine_prop.Fuel;
prop_ox1 = design_variables.stage1.engine_prop.Oxidizer;
prop_f2 = design_variables.stage2.engine_prop.Fuel;
prop_ox2 = design_variables.stage2.engine_prop.Oxidizer;

%find density in cost .csv 
matchf1 = strcmp(parameters.propellant_properties.Propellant, prop_f1);
locate_f1 = find(matchf1);
prop_f1_density = parameters.propellant_properties...
    {locate_f1,4};

matchf2 = strcmp(parameters.propellant_properties.Propellant, prop_f2);
locate_f2 = find(matchf2);
prop_f2_density = parameters.propellant_properties...
   {locate_f2,4};

matchox1 = strcmp(parameters.propellant_properties.Propellant, prop_ox1);
locate_ox1 = find(matchox1);
prop_ox1_density = parameters.propellant_properties...
    {locate_ox1,4};

matchox2 = strcmp(parameters.propellant_properties.Propellant, prop_ox2);
locate_ox2 = find(matchox2);
prop_ox2_density = parameters.propellant_properties...
    {locate_ox2,4};

end

function [ro] = calc_wallthick(thrust1,thrust2,ri, FOS, sigma_max)
%Stage 1
A1 = FOS*thrust1/sigma_max; %get area required to accomodate this stress w/chosen FOS
ro_1 = sqrt(A1/pi + ri^2);
t1 = ro_1 - ri;
%Stage2
A2 = FOS*thrust2/sigma_max; %get area required to accomodate this stress w/chosen FOS
ro_2 = sqrt(A2/pi + ri^2);
t2 = ro_2 - ri;
    %take thickest wall thickness for rocket
    if t1 < t2
        roinit = ro_2;
        t = t2;
    elseif t1>t2
        roinit = ro_1;
        t = t1;
    else %t1=t2
        roinit=0.004+ri; 
    end
ro = max(0.004+ri, roinit); %wall thickness must be at least 4mm
end

function [st1mass, st2mass, heat_shield_mass, SAst2]= struct_calc(st1h,st2h, strucmat_density, ro, ri, re_mat_density) 
%Stage 1rocket.ro = ro_st2;
vol = pi*(ro^2 -ri^2)*st1h;
st1mass =vol*strucmat_density; %initial rocket stage 1 mass

vol2 = pi*(ro^2 -ri^2)*st2h;
st2mass =vol2*strucmat_density; %initial rocket stage 2 mass


%% Size shield thickness via max heat flux
%its probably ~4mm so this estimate may be too thick for now
% maxq = max(heatflux); %W/m^2 max heat flux at any point in flight
%if maxq > re_mat_maxflux %if max heat flux is higher than the shield capacity 
reshieldthick = 0.0508; %[m] shield thickness 2 inches 
%get mass of shield material required for cost
SAst2 = pi*ro*2*st2h; %only need it for the upper stage for re-entry
vol_heatshield = SAst2*reshieldthick;
heat_shield_mass = vol_heatshield*re_mat_density; %[kg]

end
function [maxq] = launch(h, h2,ro,fc, fc2, st1mass,st1prop,st2prop,st2mass,...
    pay_mass,heat_shield_mass,mass_eng_st1,mass_eng_st2, st1ve, st2ve)
%% Launch
totalmass = st1mass + st1prop + st2prop + st2mass + pay_mass + heat_shield_mass...
    + mass_eng_st1 + mass_eng_st2;
rocket_SA = pi*ro^2;
q = zeros(1,length(h)); %rocket dynamic pressure
rockmass = zeros(1,length(h)); %array of rocket mass
u = zeros(1,length(h)); %array of rocket mass
rockmass(1) = totalmass; %CHECK THAT I SHOULD DO THIS 1:2 OR IF i SHOULD DO IT JUST TO 1 !!!!
time = zeros(1, (length(h) + length(h2))-1) ;%per m total time for reaching LEO
D = zeros(1,length(h));
 for i = 2:length(h) %%%%%%DO I NEED TO DO H-1 IN LENGTH TO ENSURE ROCKET MASS DOES NOT GO OUTSIDE OF ARRAY BOUNDS 
     %get atmospheric data
        [~,~,~,rho] = atmoscoesa(h(i), 'None');

        mi = rockmass(i-1); %initial fuel
        mf = rockmass(i-1) - fc*500; %updates fuel consumption for every 500 m
        rockmass(i) = mf; %update new mass
        delv = -st1ve*log(mf/mi); %ideal rocket equation change in vel IS THIS MASS THE ROCKET MASS OR THE STAGE 1 MASS?
        u(i) = u(i-1) + delv; %2*accel(i)*500); %500 m
        %D(i) = q(i-1)*rocket_SA*1.17; %CD cylinder
        %accel(i) = (thrust1 - D - g*mi)/mi; %drag and gravity
        %u(i) =sqrt( (u(i-1))^2 + 2*accel(i)*500); %500 m
        time(i) = 2/( u(i) + u(i-1) ) ; %basic kinematics
        q(i) = 0.5*rho*u(i)^2; %dynamic pressure
   
 end
maxq1 = max(q);
% %Check St1 velocity?

%% Stage 2 Post Separation
u2 = zeros(1,length(h2)); %stg2 rocket velocity
u2(1) = u(end); %from above
q2 = zeros(1,length(h2)); %rocket dynamic pressure
st2mass_calc = zeros(1,length(h2)); %array of stg2 mass
st2mass_calc(1) = st2mass+st2prop; %starting stage mass 

 for i = 2:length(h2)
     %get atmospheric data
      [~,~,~,rho] = atmoscoesa(h2(i), 'None');
      mi = st2mass_calc(i-1); %initial fuel
      mf = st2mass_calc(i-1) - fc2*1000; %updates fuel consumption for every 1000 m
      st2mass_calc(i) = mf; %update new mass
      %D = q2(i-1)*rocket_SA*1.17; %CD cylinder
      delv = -st2ve*log(mf/mi); %ideal rocket equation change in vel IS TH
      u2(i) =(u2(i-1)) + delv; %500 m
      time(i +length(h)) = 2/(u2(i) + u2(i-1) ) ; %basic kinematics CHECK CONTINUITY HEREEEEEE!!!! There mauy be a gap in time
      q2(i) = 0.5*rho*u2(i)^2; %dynamic pressure
 end
  
maxq2 = abs(max(q2));
maxq = [maxq1, maxq2];
if max(maxq) < 30397.5
    maxq = 30397.5;
else
    maxq = max(maxq);
end


%flighttime = sum(time); %time calc as s/m in flight
end