function [rocket] = engine_mod(rocket, design_variables)

stage1 = rocket.stage1;
stage2 = rocket.stage2;

if design_variables.stage1.reusable == 1
    delV_stg1 = 4500; % m/s
    delV_stg2 = 7600; % m/s
else
    delV_stg1 = 5600; % m/s
    delV_stg2 = 7600; % m/s
end

rocketProp = getRocketProperties(design_variables.stage2.engine_prop);
[thrust, ue, mdot, engine] = combustion_mod(rocketProp);
stage2.nEng         = floor(design_variables.rocket_ri^2/(rocketProp.De^2/4)*.83);
stage2.thrust       = thrust*stage2.nEng;
stage2.ue           = ue    *stage2.nEng;
stage2.mdot         = mdot  *stage2.nEng;

B                   = exp((delV_stg2 - delV_stg1)/stage2.ue);
stage2.alpha        = 0.1; % 10% of payload mass is structure mass
stage2.mprop        = (B - 1)*rocket.payload/(1 + (1 - B)*stage2.alpha);

stage2.prodNames    = engine.name;
stage2.prodValues   = engine.massFraction;

rocketProp = getRocketProperties(design_variables.stage1.engine_prop);
[thrust, ue, mdot, engine] = combustion_mod(rocketProp);
stage1.nEng         = floor(design_variables.rocket_ri^2/(rocketProp.De^2/4)*.83);
stage1.thrust       = thrust*stage1.nEng;
stage1.ue           = ue    *stage1.nEng;
stage1.mdot         = mdot  *stage1.nEng;

B                   = exp(delV_stg1/stage1.ue);
stage1.alpha        = 0.1; % 10% of payload mass is structure mass
stage1.mprop        = (1 - B)*(1 + stage1.alpha)*stage2.mprop/(1 - stage1.alpha);

stage1.prodNames    = engine.name;
stage1.prodValues   = engine.massFraction;

rocket.stage1 = stage1;
rocket.stage2 = stage2;

end
