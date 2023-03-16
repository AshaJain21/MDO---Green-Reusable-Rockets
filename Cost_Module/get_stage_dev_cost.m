function stage_dev_cost = get_stage_dev_cost(reuse, total_mass, prop_mass, parameters)
    % Assumptions
    % 1. Assume launcher is mature (f1 of 0.6)
    % 2. Assume team is somewhat experienced (f3 of 1.0)
    K_eff = total_mass/prop_mass;

    if reuse == true
        coeff = 4080;
        K_ref = -0.022* log(prop_mass) + 0.4224; %Empirically derived from chart in Koelle paper
    else
        coeff = 3140;
        K_ref = -0.009 * log(prop_mass) + 0.1865; %Empirically derived from chart in Koelle paper
    end
    
    f2 = K_ref / K_eff;

    stage_dev_cost = coeff * total_mass ^0.21 * parameters.f1 * f2 * parameters.f3;
end