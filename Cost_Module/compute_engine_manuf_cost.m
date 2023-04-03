function manuf_cost = compute_engine_manuf_cost(LH2_eng, eng_lc, eng_uc, total_units, eng_mass, total_duration)
    % Note that f4 includes a learning rate so there's no need to apply a
    % further learning rate to this

    f4 = compute_engine_f4(eng_mass, eng_lc, eng_uc, total_units, total_duration);

    if LH2_eng == true
        coeff = 3.15;
    else
        coeff = 1.9;
    end

    manuf_cost = coeff * (eng_uc - eng_lc +1) * eng_mass^0.535 * f4;
end




function f4 = compute_engine_f4(unit_mass, eng_lc, eng_uc, total_units, total_duration)

    units_per_year = total_units/total_duration;

    p = compute_engine_p_val(unit_mass, units_per_year);

    num_engines = eng_uc - eng_lc + 1;
    expo = log(p)/log(2);
    f4_sum_term = 0;

    for j = eng_lc:eng_uc
        f4_sum_term = f4_sum_term + j^expo;
    end
    
    f4 = f4_sum_term/num_engines;

end



function p = compute_engine_p_val(unit_mass, units_per_year)
    if (unit_mass <= 150)
        const = 1.0005;
        coeff = 0.055;
    elseif (unit_mass > 150) && (unit_mass <= 300)
        const = 1.0081;
        coeff = 0.054;
    elseif (unit_mass > 300) && (unit_mass <= 600)
        const = 1.019;
        coeff = 0.054;
    elseif (unit_mass > 600) && (unit_mass <= 1200)
       const = 1.0316;
       coeff = 0.054;
    elseif (unit_mass > 1200) && (unit_mass <= 2400)
        const = 1.0377;
        coeff = 0.054;
    elseif (unit_mass > 2400) && (unit_mass <= 4850)
        const = 1.0443;
        coeff = 0.053;
    else %defined for 4850 - 8250kg range
        const = 1.0495;
        coeff = 0.051;
    end
    
    p = -coeff*log(units_per_year) + const;
end