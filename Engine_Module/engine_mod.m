function [rocket] = engine_mod(rocket, design_variables, parameters)

stage1 = rocket.stage1;
stage2 = rocket.stage2;


%Reading in engine prop variables and computing engine thrust, velocity...
rocketProp_stg2 = getRocketProperties(design_variables.stage2.engine_prop);
rocketProp_stg1 = getRocketProperties(design_variables.stage1.engine_prop);
[thrust2, ue2, mdot2, engine2] = combustion_mod(rocketProp_stg2);
[thrust1, ue1, mdot1, engine1] = combustion_mod(rocketProp_stg1);

%Decision tree for resuable stage 1 to compute boost back propellant mass
if design_variables.stage1.reusable == 1
    vterm1 = stage1.vTerm;
    mbb1 = stage1.mstruct * (exp( vterm1 / (rocketProp_stg1.Isp * 9.81)) - 1);
    separation_velocity = parameters.vSepReusable;
    delV_stg1 = separation_velocity + parameters.drag_deltaV ; % m/s 
else
    separation_velocity = parameters.vSepNonReusable;
    delV_stg1 = separation_velocity + parameters.drag_deltaV ; % m/s
    mbb1 =0;
end

%Decision tree for resuable stage 2 to compute boost back propellant mass
if design_variables.stage2.resuable == 2
    vterm2 = stage2.vTerm;
    mbb2 = stage2.mstruct * (exp( vterm2 / (rocketProp_stg2.Isp * 9.81)) - 1);
else
    mbb2 = 0;
end

%Final Computation for Stage 2 
stage2.nEng         = floor(design_variables.rocket_ri^2/(rocketProp_stg2.De^2/4)*.83);
stage2.thrust       = thrust2*stage2.nEng;
stage2.ue           = ue2    *stage2.nEng;
stage2.mdot         = mdot2  *stage2.nEng;
stage2.mf           = stage2.mstruct + rocket.payload + mbb2;
stage2.mprop        = (stage2.mf)* ( exp( (parameters.orbitalVelocity-separation_velocity) / (rocketProp_stg2.Isp * 9.81)) - 1 );
stage2.mbb          = mbb2;
stage2.prodNames    = engine2.name;
stage2.prodValues   = engine2.massFraction;

%Final Computation for Stage 1
stage1.nEng         = floor(design_variables.rocket_ri^2/(rocketProp_stg1.De^2/4)*.83);
stage1.thrust       = thrust1*stage1.nEng;
stage1.ue           = ue1 *stage1.nEng;
stage1.mdot         = mdot1 *stage1.nEng;
stage1.mf           = stage1.mstruct + stage2.mf + stage2.mprop + mbb1;
stage1.mprop        = stage1.mf* ( exp(delV_stg1/ (rocketProp_stg1.Isp * 9.81)) - 1);
stage1.mbb          = mbb1;
stage1.prodNames    = engine1.name;
stage1.prodValues   = engine1.massFraction;

%Saving computed values into rocket variable
rocket.stage1 = stage1;
rocket.stage2 = stage2;

end
