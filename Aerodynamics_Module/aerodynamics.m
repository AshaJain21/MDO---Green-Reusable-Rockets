%% Aerodynamics Modules MDO Green Rockets

%Written By: Maranda


%Inputs: Engine Thrust (Engine), St1 & 2 Engine exhaust exit velocity
%        Re-entry Angle (param), Rocket Class (mass,geometry, reusable)
%        Heat Shield Material Emissivity
%Outputs: Updated Rocket Class(Stg 1&2 Terminal Vel.(Engine)+ Heat Flux
%         for launch and recovery) (Environ)
%         Launch Profile/Orbital Alt - Flight Time, LeoAlt, StgSep Alt(Environ),
%         Checks for Engine
%        

%using belly flop determine SAwet and calculate heat flux using rocket
%geometry
%mass = inert mass + burned prop mass + payload mass
%inert mass = structural mass + engine mass + unburned prop mass
%unburned prop mass = reserve prop mass + deorbit/recovery prop mass
%mass fraction SF - required for reserve
%structural index = ratio of rocket structures wrt total prop
% SI = mstruc/mmprop

%stage mass ratio -total stage mass/mass at end of burn (mass at end of burn = total mass - burned prop mass)
%%%NEED KINJAL TO CALCJLATE THE EMISSIONS PER 500 M FOR THE ROKCET
function [rocket] = aerodynamics(design_variables, parameters, rocket)
%intialize constants and other vars
st1mass = rocket.stage1.mstruct; %dry mass stage 1
st2emiss = rocket.stage2.prodValues; %in kg add together = total prop mass
st1emiss = rocket.stage1.prodValues;
st1prop = rocket.stage1.engine_prop; %total mass - structural mass = prop mass
st2mass = rocket.stage2.mstruct;
st2prop = rocket.stage2.engine_prop;
ro = rocket.ro; %inner radius of rocket
%st2rad = rocket.stage2.ri; %
st1h = rocket.stage1.height;
st2h = rocket.stage2.height;
st1t = rocket.stage1.thrust;
st2t = rocket.stage2.thrust;
st1ve = rocket.stage1.ue;
st2ve = rocket.stage2.ue;
mdotst1_f = rocket.stage1.mdot; %mass flow rate of exhaust 
mdotst2_f = rocket.stage2.mdot; %mass flow rate of exhaust upper stage
e = parameters.structural_material.emissivity; %emissivity of aluminum
%st2emiss_fract = st2emiss/st2prop; %get fraction of prop mass burned /total prop mass assume = relation to mdot - this fraction can be used for mdot
%st2emiss_per_sec = st2emiss_fract*mdotst2_f; %kg/s of emissions
%st1emiss_fract = st1emiss./st1prop;
%st1emiss_per_sec = st1emiss_fract*mdotst1_f; %kg/s of emissions for each emission type
reangle = parameters.reentry_angle;
theight = st1h+st2h; %total rocket height [m]

g = 9.81; %m/s2 accel due to grav
totalmass = st1mass + st1prop + st2prop + st2mass; %starting wet mass of rocket

%%%%NEED TO DERIVE FUNCTION FOR DRAG COEFF OF STARSHIP AS A FXN OF ALTOR MACH CAN BE RELATED TO RE
%Launch
LEOalt = parameters.orbital_altitude*1000; % [m] LEO =<2000 km from SpaceX website ~500 km circular 
%orbit @98.9 deg inclination
stgsep = 75e3; %[m] stage separation altitude
sigma= 5.6703e-8; %(W/m2K4) - The Stefan-Boltzmann Constant

%generate wetted surface area calculation for the flight ->assume parabolic
%mx^2 + bx + c c=0 at t=0, dy/dx  
theta_l = 0; %launch angle - parabolic y = x^2
%wetted area - surface area of rocket for now
rocket_Sb_launch = pi*ro*2*st2h/cos(theta_l) + pi*ro*2*st1h/cos(theta_l);
rocket_cross_launch = pi*ro^2;
fc = mdotst1_f/st1ve;  %fuel consumption kg per metre;
h = 0:500:stgsep; %altitude array --> launch until stage separation (75km),
%calculate every 500 m
h2 = stgsep:1000:LEOalt; %altitude array for stage 2 75km to LEO 500 km

M = zeros(1,length(h)); %Mach number
u = zeros(1,length(h)); %rocket velocity
%prodemiss_1 = zeros(length(st1emiss_per_sec),length(h)); %emissions kg/m stage 1;
rockmass = zeros(1,length(h)); %array of rocket mass
rockmass(1) = totalmass; %CHECK THAT I SHOULD DO THIS 1:2 OR IF i SHOULD DO IT JUST TO 1 !!!!
%generate an array for CD calcs -->body friction drag
Cd_friction = zeros(1,length(h));
time = zeros(1, (length(h) + length(h2))-1) ;%per m total time for reaching LEO
%velocity budget of 9.85 km/s
q_l_presep = zeros(1,length(h)); %heat flux HOW DO I PUT THIS IN THE CLASSSSSS????????????
accel = zeros(1,length(h));
%utrial = zeros(1,length(h));
 for i = 2:length(h) %%%%%%DO I NEED TO DO H-1 IN LENGTH TO ENSURE ROCKET MASS DOES NOT GO OUTSIDE OF ARRAY BOUNDS 
     %get atmospheric data
        [Tair,a,~,rho] = atmoscoesa(h(i));

        mi = rockmass(i-1); %initial fuel
        mf = rockmass(i-1) - fc*500; %updates fuel consumption for every 500 m
        rockmass(i) = mf; %update new mass
        delv = -st1ve*log(mf/mi); %ideal rocket equation change in vel IS THIS MASS THE ROCKET MASS OR THE STAGE 1 MASS?
        %utrial(i) = utrial(i-1) + delv; %calculate velocity of rocket USE OTHER ONE
        %q = 0.5*rho*utrial(i-1)^2; %dynamic pressure
        accel(i) = (st1ve*mdotst1_f)/mi -g;%- (Cd_friction(i-1)*q*pi*ro^2)/mi; %drag and gravity
        u(i) = u(i-1) + 2*accel(i); %500 m
        time(i) = 2/( u(i) + u(i-1) ) ; %basic kinematics
        %prodemiss_1(:,i) = (st1emiss_per_sec./u(i))*500; %kg/m * 500 for 500 m
        %check if there is enough fuel left
%         if mf < (rockmass(i) - st1prop)
%             fprintf('WARNING: Not Enough Fuel for Stage Separation at 75 km!')
%             St1propcheck = 0; %zero = fail
%         end

        if h(i) <= 4572 %set speed of sound and mach number params
            v = (0.000157*exp(0.00002503*h(i)))/3.28^2 ;%[m2/s]
        elseif h(i)>4572 && h(i) <= 9144
             v = (0.000157*exp(0.00002760*h(i) -0.03417))/3.28^2 ;% [m2/s]
        else
             v = (0.000157*exp(0.00004664*h(i) -0.6882))/3.28^2 ;%[m2/s]
        end
        
        M(i) = u(i)/a; %get mach number
        
        %compressible reynold's number
        Re = (a*M(i)*theight/v)*(1 + 0.0283*M(i) - 0.043*M(i)^2 + ...
            0.2107*M(i)^3 -0.03829*M(i)^4 + 0.002709*M(i)^5);

        cf_in = 0.037036*Re^(-0.155079); %incomp skin friction coeff
        %compr skin friction coeff
        cf = cf_in*(1 + 0.00798*M(i) - 0.1813*M(i)^2 + ...
            0.0632*M(i)^3 -0.00933*M(i)^4 + 0.000549*M(i)^5); 
        K = 0.00003; %polished metal MAY CHANGE THISSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
        cf_interm = 1/( 1.89 + 1.62*log10(theight/K))^2.5; %with roughness
        cfterm = cf_interm/(1+0.2044*M(i)^2); %with roughness

        if cf >= cfterm %get CF
            CF_final = cf;
        else
            CF_final = cfterm;
        end

        Cd_friction(i) = CF_final*(1 + 60/(theight/(2*ro))^3 + 0.0025*...
            (theight/(ro*2))*(4*rocket_cross_launch/pi*(2*ro)^2)) ; %NOT SURE IF I SHOULD INCLUDE DRAG FOR EXCRESCENCIES
        %body drag due to friction neglect fins and any protuberances 
        %^needs cross sectional area resistance to body
       %base drag coeff
       %if M(i) < 0.6
        %   ()
      % else 
       %    ()
       %end
    
    %heat flux calc
    %consider convective heat transfer only from speed of flow to rocket
    %wholerocket
    k = 1.74153e-4; %constant for heat t used for Earth
    qconv_l_presep = k*((rho/ro)^0.5)*u(i)^3; %nose radius use - sutton graves
    %hot wall correction Chapman eqn
    %ga = 1.4; %air
    %R = 287; %J/kgK
    %qinf =0.5*rho*M(i)^2*ga*R*Tair; %dynamic pressure
    %qconv2 = alpha*(u(i))^2.15*sqrt(qinf/st1rad); %heat flux W/m^2
                          %%%%%SHOULD I INCLUDE RADIATIVE HEAT TRANSFER VIA BOLTZMANN esigmaT^4
    qrad = e*sigma*Tair^4;
    %kcont = 0.76; %for axisymmetric  body
    %chs = 1- exp(-A*sqrt(M(i)^(2*w -1)*kcont*ninf))
    %qconv3 = chs*0.5*rho*u(i)^3; %this does it for the entire continuum of flow from low speed high density to hypersonic rarefied
    
    q_l_presep(i) = qconv_l_presep + qrad; %most important for stage1
    
   
 end
 
% if (rockmass(end) - st1prop) >= 0
%     fprintf('Stage 1 Fuel Sufficient for Stage Separation!')
%     St1propcheck = 1; %zero = fail one = pass
% end

rocket.stage1.launch_qdot = q_l_presep;

theta_stg2 = 0; %launch angle - parabolic y = x^2 still going up? SET AN ANGLE FOR STAGE 2 AS IT CLIMBS TO LEO FIX THIS
%wetted area - surface area of stg2 post separation
stg2_Sb_sep = pi*ro*2*st2h/cos(theta_l); 
fc2 = st2ve/mdotst2_f;  %fuel consumption kg per metre;

M2 = zeros(1,length(h2)); %Mach number stage 2
M2(1) = M(end); %from above
u2 = zeros(1,length(h2)); %stg2 rocket velocity
u2(1) = u(end); %from above
%prodemiss_2 = zeros(length(st2emiss_per_sec),length(h2)); %emissions kg/m stage 1;
st2mass_calc = zeros(1,length(h2)); %array of stg2 mass
st2mass_calc(1) = st2mass+st2prop; %starting stage mass 
%generate an array for CD calcs -->body friction drag
Cdstg2 = zeros(1,length(h2));
%velocity budget of 9.85 km/s
q_l_st2 = zeros(1,length(h2)); %heat fluc
q_l_st2(1) = q_l_presep(end); %PROBALY NEEDS TO BE DECREASEDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDd
accel2 = zeros(1,length(h2));
 for i = 2:length(h2)
     %stg2 post separation dynamics
     %get atmospheric data
      [Tair,a,~,rho] = atmoscoesa(h2(i));
        
      mi = st2mass_calc(i-1); %initial fuel
      mf = st2mass_calc(i-1) - fc2*1000; %updates fuel consumption for every 1000 m
      st2mass_calc(i) = mf; %update new mass
      delv = -st2ve*log(mf/mi); %ideal rocket equation change in vel
      %u2(i) = u2(i-1) + delv; %calculate velocity of rocket
      %q = 0.5*rho*utrial(i-1)^2; %dynamic pressure
      accel2(i) = (st2ve*mdotst2_f)/mi -g;%- (Cd_friction(i-1)*q*pi*ro^2)/mi; %drag and gravity
      u2(i) = u2(i-1) + 2*accel2(i); %1000 m
      time(i +length(h)) = 2/(u2(i) + u2(i-1) ) ; %basic kinematics CHECK CONTINUITY HEREEEEEE!!!! There mauy be a gap in time
      %prodemiss_2(:,i) = (st2emiss_per_sec./u2(i))*500; %kg/m * 500 for 500 m
%       %check if there is enough fuel left
%       if mf < (st2mass_calc(i) - st1prop)
%           fprintf('WARNING: Not Enough Fuel to Reach LEO!')
%           St2propcheck = 0; %zero = fail
%       end
      
      %h>9144 m
      v = (0.000157*exp(0.00004664*h2(i) -0.6882))/3.28^2 ;%[m2/s]
      M2(i) = u2(i)/a; %get mach number
    
      %compressible reynold number
      Re = (a*M2(i)*st2h/v)*(1 + 0.0283*M2(i) - 0.043*M2(i)^2 + ...
            0.2107*M2(i)^3 -0.03829*M2(i)^4 + 0.002709*M2(i)^5);

       cf_in = 0.037036*Re^(-0.155079); %incomp skin friction coeff
       %compr skin friction coeff
       cf = cf_in*(1 + 0.00798*M2(i) - 0.1813*M2(i)^2 + ...
            0.0632*M2(i)^3 -0.00933*M2(i)^4 + 0.000549*M2(i)^5); 
        K = 0.00003; %polished metal MAY CHANGE THISSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
        cf_interm = 1/( 1.89 + 1.62*log10(st2h/K))^2.5; %with roughness
        cfterm = cf_interm/(1+0.2044*M2(i)^2); %with roughness

        if cf >= cfterm %get CF
            CF_final = cf;
        else
            CF_final = cfterm;
        end
        Cdstg2(i) = CF_final*(1 + 60/(st2h/(ro*2))^3 + 0.0025*(st2h/(ro*2))...
            )*(4*stg2_Sb_sep/pi*(ro*2)^2) ; %NOT SURE IF I SHOULD INCLUDE DRAG FOR EXCRESCENCIES
        %body drag due to friction neglect fins and any protuberances 
        %soupcan -->can change this to incorporate a nosecone
        %need resistance to body

    %heat flux calc
    %consider convective heat transfer only from speed of flow to rocket
    k = 1.74153e-4; %constant for heat t used for Earth
    qconv_st2 = k*((rho/ro)^0.5)*u2(i)^3; %nose radius use - sutton graves
    %hot wall correction Chapman eqn
    %ga = 1.4; %air
    %R = 287; %J/kgK
    %qinf =0.5*rho*M2(i)^2*ga*R*Tair; %dynamic pressure
    %qconv2 = alpha*(u(i))^2.15*sqrt(qinf/st1rad); %heat flux W/m^2
                                    %%%%%SHOULD I INCLUDE RADIATIVE HEAT TRANSFER VIA BOLTZMANN esigmaT^4
    qrad = e*sigma*Tair^4;
    %kcont = 0.76; %for axisymmetric  body
    %chs = 1- exp(-A*sqrt(M(i)^(2*w -1)*kcont*ninf))
    %qconv3 = chs*0.5*rho*u(i)^3; %this does it for the entire continuum of flow from low speed high density to hypersonic rarefied
    
    q_l_st2(i) = qconv_st2 + qrad;
    
 end
  
% if (st2mass_calc(end) - st2prop) >= 0
%     fprintf('Stage 2 Fuel Sufficient for LEO!')
%     St2propcheck = 1; %zero = fail one = pass
% end 

%if delV < 8.8e3
%      fprintf('Stage 2 not fast enough')
%end
rocket.stage2.launch_qdot = q_l_st2;

%orbital veloctiy required for orbit 2nd stage only assuming circular orbit %CONSTRAINT %(from NASA) MAY REVISIT
RE = 6377830; %radius of Earth [m]
Vorb = sqrt(g*RE^2/(RE+LEOalt)); %~ 8.8e3; %[m/s] actually (current calc gives ~7.62 km/s SHOULD I UPDATE THIS VELOCITY BUDGET???
% if u2(end) < Vorb
%     fprintf('Danger, Stage 2 Velocity Not High Enough to Support Orbital flight!')  
%     Vorbcheck = 0; %fail
% else
%     Vorbcheck = 1; %pass
% end

flighttime = sum(time); %time calc as s/m in flight


%Calculate emissions per 500 m for launch based on input emissions from
%engine stage1 and 2 combined
%rocket.emiss_per500m = [prodemiss_1 prodemiss_2]; 
%concatenate emissions at stage 1 - stage2 for launch

%Boost Back Stg1: terminal velocity, separation @75 km (get rho)
%assume a fall angle from normal (vertical) 10 degrees
%stage mass ratio -total stage mass/mass at end of burn (mass at end of burn = total mass - burned prop mass
%calculate terminal velocities for re-entry and landing burn and boost back
% elseif reusable ==0
% fprintf('Not Re-usable, ignore return flight')
%
%Landing Burn
if design_variables.stage1.reusable == 1 %boost back, landing burn needed 
    st1mpb = st1mass; %(mass post burn, still have some left over for landing)
    st1_Sb_recovery = pi*ro*2*st1h; %total SA at angle of fall 
    st1_cross_recovery = pi*ro^2; %%cross sectional area at angle of fall (assume stg1 fall straight vertically)
    st1tv = zeros(1,length(h));
    Mst1 = zeros(1,length(h));
    ust1 = zeros(1,length(h));
    ust1(1) = 0; %assume 0 velocity at separation (after the "boost back" maneuver)
    q_st1_rec = zeros(1,length(h));
    
  for i = 2:length(h)
     [Tair,a,~, rho] = atmoscoesa(h(end-i+1)); %start at altitude of separation
      %delv = 2*g*500; %projectile motion NOT SURE IF THIS APPLIES FIXEEEEEEEEEEEEEEEEEEEEEE
      ust1(i) = ust1(i-1) + 2*(-g); %calculate velocity of rocket (downwards)

        if h(end-i+1) <= 4572 %set speed of sound and mach number params
            v = (0.000157*exp(0.00002503*h(end-i+1)))/3.28^2 ;%[m2/s]
        elseif h(end-i+1)>4572 && h(end-i+1) <= 9144
             v = (0.000157*exp(0.00002760*h(end-i+1) -0.03417))/3.28^2 ;% [m2/s]
        else
             v = (0.000157*exp(0.00004664*h(end-i+1) -0.6882))/3.28^2 ;%[m2/s]
        end
        
        Mst1(i) = ust1(i)/a; %get mach number
        
        %compressible reynold number
        Re = (a*Mst1(i)*st1h/v)*(1 + 0.0283*Mst1(i) - 0.043*Mst1(i)^2 + ...
            0.2107*Mst1(i)^3 -0.03829*Mst1(i)^4 + 0.002709*Mst1(i)^5);

        cf_in = 0.037036*Re^(-0.155079); %incomp skin friction coeff
        %compr skin friction coeff
        cf = cf_in*(1 + 0.00798*Mst1(i) - 0.1813*Mst1(i)^2 + ...
            0.0632*Mst1(i)^3 -0.00933*Mst1(i)^4 + 0.000549*Mst1(i)^5); 
        K = 0.00003; %polished metal MAY CHANGE THISSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
        cf_interm = 1/( 1.89 + 1.62*log10(st1h/K))^2.5; %with roughness
        cfterm = cf_interm/(1+0.2044*Mst1(i)^2); %with roughness

        if cf >= cfterm %get CF
            CF_final = cf;
        else
            CF_final = cfterm;
        end

        CD = CF_final*(1 + 60/(st1h/(ro*2))^3 + 0.0025*(st1h/(ro*2)) )*(4*st1_Sb_recovery/pi*(ro*2)^2) ; %NOT SURE IF I SHOULD INCLUDE DRAG FOR EXCRESCENCIES
        %body drag due to friction neglect fins and any protuberances 

        st1tv(i) = sqrt(2*st1mpb*g/rho*st1_cross_recovery*abs(CD)); %goes from high alt to end
        k = 1.74153e-4; %constant for heat t used for Earth
        qconv_st1_rec = k*((rho/ro)^0.5)*ust1(i)^3; %nose radius use - sutton graves
        qrad = e*sigma*Tair^4;
        q_st1_rec(i) = qconv_st1_rec + qrad;
  end
       rocket.stage1.recovery_qdot = q_st1_rec;
       rocket.stage1.terminal_velocity = st1tv;
end
%UPPer atmosphere boost back -need
%Re-entry from LEO Stg 2 %heat flux %angle, radius, length of stg2 - 
%calculated wetted area
if design_variables.stage2.reusable == 1 %re-entry, landing burn needed + belly flop
    st2mpb = st2mass; %(mass post burn, still have some left over for landing) FIGURE THS OUT LATER -kinjal
    %cross sectional area at angle of fall
    st2_cross_recovery = pi*ro^2/cos(deg2rad(reangle)); 
    st2_Sb_recovery = pi*ro*2*st2h/cos(deg2rad(reangle)); %total wetted area not sure which to use!!!!!!!!!!!!!!!!!!!!!!
    alt = 0:500:LEOalt; %full altitude of deorbit [m]
    st2tv = zeros(1,length(alt));
    Mst2 = zeros(1,length(alt));
    ust2 = zeros(1,length(alt));
    ust2(1) = 300; %assume a deorbit velocity of ~300 m/s from staging paper
    q_st2_rec = zeros(1,length(alt));
    
    for i = 2:(length(alt)) 
     [Tair,a,~, rho] = atmoscoesa(alt(end-i+1)); %start at altitude of separation not sure atmoscoesa's limits
        %delv = 2*g*500; %projectile motion NOT SURE IF THIS APPLIES fixeeeeessssssssssss
       if alt(end-i+1) > 84852
            [Tair,a,~, rho] = atmoscoesa(84852); %change this later
       end
        ust2(i) = ust2(i-1) + 2*(-g); %calculate velocity of rocket (downwards)

        if alt(end-i+1) <= 4572 %set speed of sound and mach number params
            v = (0.000157*exp(0.00002503*alt(end-i+1)))/3.28^2 ;%[m2/s]
        elseif alt(end-i+1)>4572 && alt(end-i+1) <= 9144
             v = (0.000157*exp(0.00002760*alt(end-i+1) -0.03417))/3.28^2 ;% [m2/s]
        else
             v = (0.000157*exp(0.00004664*alt(end-i+1) -0.6882))/3.28^2 ;%[m2/s]
        end
        
        Mst2(i) = ust2(i)/a; %get mach number
        %compressible reynold number
        Re = (a*Mst2(i)*st2h/v)*(1 + 0.0283*Mst2(i) - 0.043*Mst2(i)^2 + ...
            0.2107*Mst2(i)^3 -0.03829*Mst2(i)^4 + 0.002709*Mst2(i)^5); %

        cf_in = 0.037036*Re^(-0.155079); %incomp skin friction coeff
        %compr skin friction coeff
        cf = cf_in*(1 + 0.00798*Mst2(i) - 0.1813*Mst2(i)^2 + ...
            0.0632*Mst2(i)^3 -0.00933*Mst2(i)^4 + 0.000549*Mst2(i)^5); 
        K = 0.00003; %polished metal MAY CHANGE THISSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS
        cf_interm = 1/( 1.89 + 1.62*log10(st2h/K))^2.5; %with roughness
        cfterm = cf_interm/(1+0.2044*Mst2(i)^2); %with roughness

        if cf >= cfterm %get CF
            CF_final = cf;
        else
            CF_final = cfterm;
        end
        
        CD = CF_final*(1 + 60/(st2h/(ro*2))^3 + 0.0025*(st2h/(ro*2)) )*(4*st2_Sb_recovery/pi*(ro*2)^2) ; %NOT SURE IF I SHOULD INCLUDE DRAG FOR EXCRESCENCIES
        %body drag due to friction neglect fins and any protuberances 
       
        st2tv(i) = sqrt(2*st2mpb*g/rho*st2_cross_recovery*abs(CD)); %goes from high alt to end
        k = 1.74153e-4; %constant for heat t used for Earth
        qconv_st2_rec = k*((rho/ro)^0.5)*ust2(i)^3; %nose radius use - sutton graves
        qrad = e*sigma*Tair^4;
        q_st2_rec(i) = qconv_st2_rec + qrad; %heat flux for reentry
    end
      rocket.stage2.recovery_qdot = q_st2_rec;
      rocket.stage2.terminal_velocity = st2tv;
end
%CHECKS = [St1propcheck, St2propcheck, Vorbcheck];

end
