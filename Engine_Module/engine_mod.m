function [rocket] = engine_mod(rocket, design_variables)
stage1 = rocket.stage1;
stage2 = rocket.stage2;

if design_variables.stage1.reusable == 1
    delV_stg1 = 2000; % m/s
    delV_stg2 = 9800; % m/s
else
    delV_stg1 = 3400; % m/s
    delV_stg2 = 9800; % m/s
end

rocketProp = getRocketProperties(design_variables.stage2.engine_prop);
[thrust, ue, mdot, engine] = combustion_mod(rocketProp);
stage2.nEng         = floor((design_variables.ri^2*pi)/rocketProp.Ae);
stage2.thrust       = thrust*stage2.nEng;
stage2.ue           = ue    *stage2.nEng;
stage2.mdot         = mdot  *stage2.nEng;
stage2.mi           = stage2.mf/exp(delV_stg2/stage2.ue);
stage2.mprop        = stage2.mi - stage2.mf;
stage2.prodNames    = engine.S.LS;
stage2.prodValues   = engine.PS.mix2_c{1, 1}.Yi;

rocketProp = getRocketProperties(design_variables.stage1.engine_prop);
[thrust, ue, mdot, engine] = combustion_mod(rocketProp);
stage1.nEng         = floor((design_variables.ri^2*pi)/rocketProp.Ae);
stage1.thrust       = thrust*stage1.nEng;
stage1.ue           = ue    *stage1.nEng;
stage1.mdot         = mdot  *stage1.nEng;
stage1.mi           = (stage1.mf + stage2.mi)/exp(delV_stg1/stage1.ue);
stage1.mprop        = mi - (stage1.mf + stage2.mi);
stage1.prodNames    = engine.S.LS;
stage1.prodValues   = engine.PS.mix2_c{1, 1}.Yi;

rocket.stage1 = stage1;
rocket.stage2 = stage2;

end