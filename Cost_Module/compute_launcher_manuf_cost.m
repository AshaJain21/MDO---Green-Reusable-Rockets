function launcher_manuf_cost = compute_launcher_manuf_cost(design_variables, rocket, launch_cadence, parameters)
    % Assumptions
    % 1. Always only 2 stages (N=2)
    % 2. Always liquid propellants (solid propellants require a different
    % engine equation

    total_duration = sum(launch_cadence(1,:));
    
    % Get basic information about the stages
    num_engines = [rocket.stage1.nEng, rocket.stage2.nEng];
    engine_types = [design_variables.stage1.engine_prop.Engine, design_variables.stage2.engine_prop.Engine];
    num_refurbished = [sum(launch_cadence(2,:)), sum(launch_cadence(3,:))];

    stage1_masses = struct(mstruct=rocket.stage1.mstruct, meng=design_variables.stage1.engine_prop.EngineMass_kg_);
    stage2_masses = struct(mstruct=rocket.stage2.mstruct, meng=design_variables.stage2.engine_prop.EngineMass_kg_);
    masses = [stage1_masses, stage2_masses];
    
    %Determine how many of each engine and stage need to be produced
    production_totals = consolidate_production_totals(design_variables, rocket, num_refurbished, parameters);

    %Calculate manufacturing cost curves for each stage
    stage1_cost_curve = compute_stage_manuf_cost(production_totals.stages_cryo(1), masses(1).mstruct, production_totals.stages_produced(1), total_duration);
    stage2_cost_curve = compute_stage_manuf_cost(production_totals.stages_cryo(2), masses(2).mstruct, production_totals.stages_produced(2), total_duration);
    
    launcher_manuf_cost_wy = combined_launcher_costs_wy(stage1_cost_curve, stage2_cost_curve, num_engines, engine_types, masses, launch_cadence, production_totals, total_duration);
    launcher_manuf_cost = launcher_manuf_cost_wy * parameters.MY_value;
end

function launcher_manuf_cost_wy = combined_launcher_costs_wy(stage1_cost_curve, stage2_cost_curve, num_engines, engine_types, masses, launch_cadence, production_totals, total_duration)
    num_launches = width(launch_cadence);
    launcher_manuf_cost_wy = zeros(2, num_launches);
    engine_counts = zeros(1, length(production_totals.engine_types));
    engine_counts = engine_counts + 1;
    num_stages_consumed = [0,0];


    for i = 1:num_launches
        ith_launcher_cost = 0;
        
        % Add cost to manufacture first stage if one was manufactured
        if launch_cadence(2,i) == 0
            engine_prod_index = find(strcmp(production_totals.engine_types, engine_types{1}));
            engine_lc = engine_counts(engine_prod_index);
            engine_uc = engine_lc + num_engines(1);
            num_stages_consumed(1) = num_stages_consumed(1) + 1;
            stage1_engine_cost = compute_engine_manuf_cost(production_totals.stages_cryo(1), engine_lc, engine_uc, production_totals.engine_counts(engine_prod_index), masses(1).meng, total_duration);  
            launcher_manuf_cost_wy(1, i) = ith_launcher_cost + stage1_cost_curve(num_stages_consumed(1)) + stage1_engine_cost;
            engine_counts(engine_prod_index) = engine_counts(engine_prod_index) + num_engines(1);
        else
            launcher_manuf_cost_wy(1,i) = 0;
        end
        
        % Add cost to manufacture second stage if one was manufactured
        if launch_cadence(3,i) == 0
            engine_prod_index = find(strcmp(production_totals.engine_types, engine_types{2}));
            engine_lc = engine_counts(engine_prod_index);
            engine_uc = engine_lc + num_engines(2);
            num_stages_consumed(2) = num_stages_consumed(2) + 1;
            stage2_engine_cost = compute_engine_manuf_cost(production_totals.stages_cryo(2), engine_lc, engine_uc, production_totals.engine_counts(engine_prod_index), masses(2).meng, total_duration);  
            launcher_manuf_cost_wy(2, i) = ith_launcher_cost + stage2_cost_curve(num_stages_consumed(2)) + stage2_engine_cost;
            engine_counts(engine_prod_index) = engine_counts(engine_prod_index) + num_engines(2);
        else
            launcher_manuf_cost_wy(2,i) = 0;
        end
    end
end

function production_totals = consolidate_production_totals(design_variables, rocket, num_refurbished, parameters)
    
    LH2_stage_boolean = [(design_variables.stage1.engine_prop.Fuel=='LH2'), (design_variables.stage2.engine_prop.Fuel=='LH2')];

    % Determine how many of each stage needs to be produced
    num_stages_produced = design_variables.num_of_launches - num_refurbished;
    
    for i = 1:length(num_stages_produced)
        if num_stages_produced(i) <= 0
            num_stages_produced(i) = 0;
        end
    end

    production_totals.stages_produced = num_stages_produced;
    production_totals.stages_cryo = LH2_stage_boolean;
    production_totals.num_engines = [rocket.stage1.nEng, rocket.stage2.nEng];

    % Determine how many of each engine needs to be produced
    num_engines = [rocket.stage1.nEng, rocket.stage2.nEng];

    engine_types = [design_variables.stage1.engine_prop.Engine, design_variables.stage2.engine_prop.Engine];
    
    

    if engine_types(1) == engine_types(2)
        production_totals.engine_types = [engine_types(1)];
        production_totals.engine_cryo = [LH2_stage_boolean(1)];
        production_totals.engine_counts = [sum(num_engines .* num_stages_produced)];
    else
        production_totals.engine_types = [engine_types(1),engine_types(2)];
        production_totals.engine_cryo = LH2_stage_boolean;
        production_totals.engine_counts = num_engines .* num_stages_produced;
    end
end