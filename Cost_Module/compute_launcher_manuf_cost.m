function launcher_manuf_cost = compute_launcher_manuf_cost(parameters, design_variables, num_stages, total_masses, rocket)
    % Assumptions
    % 1. Always only 2 stages (N=2)
    % 2. Always liquid propellants (solid propellants require a different
    % engine equation

    N = num_stages;

    stg1_manuf_cost = compute_manuf_cost(1, design_variables.stage1.reusable, parameters, rocket.stage1.mstruct)
    stg1_engine_manuf_costs = compute_manuf_cost(0, design_variables.stage1.reusable, parameters, design_variables.stage1.engine_prop{9})
    
    stg2_manuf_cost = compute_manuf_cost(1, design_variables.stage2.reusable, parameters, rocket.stage2.mstruct)
    stg2_engine_manuf_costs = compute_manuf_cost(0, design_variables.stage2.reusable, parameters, design_variables.stage2.engine_prop{9})

    stage_costs = [(stg1_manuf_cost + stg1_engine_manuf_costs); (stg2_manuf_cost + stg2_engine_manuf_costs)];

    launcher_manuf_cost = 1.02^N * stage_costs * parameters.MY_value;

end

function manuf_cost = compute_manuf_cost(equip_type, reuse, parameters, mass)
    n = parameters.num_engines_per_stage;

    if equip_type == 0 % 0 indicates we're estimating manuf cost of an engine
        if reuse == 1
            coeff = 5.0;
        else
            coeff = 4.0;
        end
    else % otherwise a 1 would indicate we're estimating manuf cost of a stage
        
        coeff = 5.0;
    end

    manuf_cost = n * coeff * mass^0.46 * parameters.f4;

end