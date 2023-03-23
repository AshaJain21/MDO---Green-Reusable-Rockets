function launcher_manuf_cost = compute_launcher_manuf_cost(parameters, design_variables, num_stages, rocket, launch_cadence)
    % Assumptions
    % 1. Always only 2 stages (N=2)
    % 2. Always liquid propellants (solid propellants require a different
    % engine equation

    N = num_stages;
    total_duration = sum(launch_cadence(1,:));
    num_refurbished = [sum(launch_cadence(2,:)), sum(launch_cadence(3,:))];
    num_stages_produced = design_variables.num_of_launches - num_refurbished - parameters.rocket_fleet_size;
    if num_stages_produced <= 0
        num_stages_produced = 0;
    end
    num_engines = [rocket.stage1.nEng, rocket.stage2.nEng];

    stage1_masses = struct(mstruct=rocket.stage1.mstruct, meng=design_variables.stage1.engine_prop.EngineMass_kg_);
    stage2_masses = struct(mstruct=rocket.stage2.mstruct, meng=design_variables.stage2.engine_prop.EngineMass_kg_);
    masses = [stage1_masses, stage2_masses];

    LH2_stage_boolean = [(rocket.stage1.engine_prop.Fuel=='LH2'), (rocket.stage2.engine_prop.Fuel=='LH2')];
    
    for i = 1:num_stages
        stage_manuf_cost = compute_stage_manuf_cost(LH2_stage_boolean(i), num_engines(i), masses(i), num_stages_produced(i), total_duration);
    
        launcher_manuf_cost = 1.02^N * stage_costs * parameters.MY_value;
    end

end

function total_stage_manuf_cost = compute_stage_manuf_cost(LH2_stage, num_engines, masses, num_stages_produced, total_duration)
    %Calculate manufacturing cost of the engines
    engine_manuf_cost = compute_manuf_cost(0, LH2_stage, num_engines, masses.meng, (num_engines*num_stages_produced), total_duration);

    %Calculate manufacturing cost of the stage itself
    stage_manuf_cost = compute_manuf_cost(1, LH2_stage, num_engines, masses.meng, num_stages_produced, total_duration);

    %Combine them
    total_stage_manuf_cost = stage_manuf_cost + engine_manuf_cost;
end

function manuf_cost = compute_manuf_cost(equip_type, LH2_stage, n, mass, num_units, total_duration)
    f4 = compute_f4_vector(equip_type, mass, num_units, total_duration);

    if equip_type == 0 % 0 indicates we're estimating manuf cost of an engine
        if LH2_stage == true
            coeff = 3.15;
        else
            coeff = 1.9;
        end
        M_exp = 0.535;
    else % otherwise a 1 would indicate we're estimating manuf cost of a stage
        if LH2_stage == true
            coeff = 1.418;
            M_exp = 0.646;
        else
            coeff = 1.439;
            M_exp = 0.593;
        end
    end

    manuf_cost = coeff * n * mass^M_exp * f4;

end

function f4 = compute_f4_vector(equip_type, unit_mass, num_units, total_duration)
    n_vec = 1:num_units;
    units_per_year = num_units/total_duration;

    if equip_type == 0 %indicates this f4 calculation is for an engine
        p = compute_engine_p_val(unit_mass, units_per_year);
    else %otherwise we're computing the f4 for a stage
        p = compute_stage_p_val(unit_mass, units_per_year);
    end
    f4 = n_vec .^(log(p)/log(2));
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