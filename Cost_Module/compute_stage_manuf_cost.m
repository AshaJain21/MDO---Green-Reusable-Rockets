function manuf_cost = compute_stage_manuf_cost(LH2_stage, stage_mass, num_stages, total_duration)
    % Note that f4 includes a learning rate so there's no need to apply a
    % further learning rate to this

    f4 = compute_stage_f4(stage_mass, num_stages, total_duration);

    if LH2_stage == true
        coeff = 1.418;
        M_exp = 0.646;
    else
        coeff = 1.439;
        M_exp = 0.593;
    end

    manuf_cost = coeff * stage_mass^M_exp * f4;
end



function f4 = compute_stage_f4(unit_mass, num_units, total_duration)
    n_vec = 1:num_units;
    units_per_year = num_units/total_duration*12;
    p = compute_stage_p_val(unit_mass, units_per_year);
    f4 = n_vec .^(log(p)/log(2)); 
end



function p = compute_stage_p_val(unit_mass, units_per_year)
    if (unit_mass <= 50)
        const = 0.8937;
        coeff = 0.027;
    elseif (unit_mass > 50) && (unit_mass <= 500)
        const = 0.9209;
        coeff = 0.027;
    elseif (unit_mass > 500) && (unit_mass <= 5000)
        const = 0.9476;
        coeff = 0.025;
    elseif (unit_mass > 5000) && (unit_mass <= 50000)
       const = 0.9695;
       coeff = 0.022;
    else
        const = 0.9988;
        coeff = 0.022;
    end
    
    p = -coeff*log(units_per_year) + const;
end