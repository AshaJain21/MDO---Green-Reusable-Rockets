function [rocket] = engine_mod(rocket, design_variables)

stage1 = rocket.stage1;
stage2 = rocket.stage2;

if design_variables.stage1.reusable == 1
    delV_stg1 = 2300; % m/s
    delV_stg2 = 7600; % m/s
else
    delV_stg1 = 3400; % m/s
    delV_stg2 = 7600; % m/s
end

rocketProp = getRocketProperties(design_variables.stage2.engine_prop);
[thrust, ue, mdot, engine] = combustion_mod(rocketProp);
stage2.nEng         = floor(design_variables.rocket_ri^2/(rocketProp.De^2/4)*.83);
stage2.thrust       = thrust*stage2.nEng;
stage2.ue           = ue    *stage2.nEng;
stage2.mdot         = mdot  *stage2.nEng;
stage2.mf           = stage2.mstruct + rocket.payload;
% stage2.mi           = stage2.mf*exp((delV_stg2 - delV_stg1)/stage2.ue);
% stage2.mprop        = stage2.mi - stage2.mf;
stage2.mprop        = stage2.mf * 1.1;
stage2.prodNames    = engine.name;
stage2.prodValues   = engine.massFraction;

rocketProp = getRocketProperties(design_variables.stage1.engine_prop);
[thrust, ue, mdot, engine] = combustion_mod(rocketProp);
stage1.nEng         = floor(design_variables.rocket_ri^2/(rocketProp.De^2/4)*.83);
stage1.thrust       = thrust*stage1.nEng;
stage1.ue           = ue    *stage1.nEng;
stage1.mdot         = mdot  *stage1.nEng;
stage1.mf           = stage1.mstruct + stage2.mf + stage2.mprop;
% stage1.mi           = stage1.mf*exp(delV_stg1/stage1.ue);
stage1.mprop        = stage1.mf * 1.1;
% stage1.mprop        = stage1.mi - stage1.mf;
stage1.prodNames    = engine.name;
stage1.prodValues   = engine.massFraction;

rocket.stage1 = stage1;
rocket.stage2 = stage2;

end
