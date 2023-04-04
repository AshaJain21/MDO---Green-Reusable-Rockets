function [rocket] = engine_mod(rocket, design_variables, parameters)

stage1 = rocket.stage1;
stage2 = rocket.stage2;

%Reading in engine prop variables and computing engine thrust, velocity...
rocketProp_stg2 = getRocketProperties(design_variables.stage2.engine_prop);
rocketProp_stg1 = getRocketProperties(design_variables.stage1.engine_prop);


%Decision tree for resuable stage 1 to compute boost back propellant mass
if design_variables.stage1.reusable == 1
    vterm1 = stage1.terminal_velocity;
    mbb1 = stage1.mstruct * (exp( vterm1 / (rocketProp_stg1.Isp * 9.81)) - 1);
    separation_velocity = parameters.vSepReusable;
    delV_stg1 = separation_velocity + parameters.drag_deltaV ; % m/s 
else
    separation_velocity = parameters.vSepNonReusable;
    delV_stg1 = separation_velocity + parameters.drag_deltaV ; % m/s
    mbb1 =0;
end

%Decision tree for resuable stage 2 to compute boost back propellant mass
if design_variables.stage2.reusable == 2
    vterm2 = stage2.terminal_velocity;
    mbb2 = stage2.mstruct * (exp( vterm2 / (rocketProp_stg2.Isp * 9.81)) - 1);
else
    mbb2 = 0;
end

%Final Computation for Stage 2 
stage2.mf           = stage2.mstruct + rocket.payload + mbb2;
stage2.mprop        = (stage2.mf)* ( exp( (parameters.orbitalVelocity-separation_velocity) / (rocketProp_stg2.Isp * 9.81)) - 1 );
stage2.mbb          = mbb2;

%Final Computation for Stage 1
stage1.mf           = stage1.mstruct + stage2.mf + stage2.mprop + mbb1;
stage1.mprop        = stage1.mf* ( exp(delV_stg1/ (rocketProp_stg1.Isp * 9.81)) - 1);
stage1.mbb          = mbb1;

%Saving computed values into rocket variable
rocket.stage1 = stage1;
rocket.stage2 = stage2;

end
