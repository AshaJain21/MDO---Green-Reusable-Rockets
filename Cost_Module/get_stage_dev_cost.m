function stage_dev_cost = get_stage_dev_cost(reuse, total_mass, prop_mass, parameters)
    % Assumptions
    % 1. Assume launcher is mature (f1 of 0.6)
    % 2. Assume team is somewhat experienced (f3 of 1.0)

    K_eff = total_mass/prop_mass;
    Kref = -0.037ln(prop_mass) + 0.1016 %Empirically derived from chart in Koelle paper
    f2 = Kref / Keff;

    
    if reuse == true
        coeff = 4080;
    else
        coeff = 3140;
    end

    stage_dev_cost = coeff * total_mass ^0.21 * parameters.f1 * f2 * parameters.f3;
end