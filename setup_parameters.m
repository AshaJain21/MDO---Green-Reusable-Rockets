function parameters = setup_parameters()
    parameters.mass_per_satellite = tbd;
    parameters.num_of_satellites = tbd;
    parameters.rocket_fleet_size = tbd;
    parameters.structural_material = tbd;
    parameters.struc_to_propellant_mass_ratio = tbd;
    parameters.prop_unit_costs = tbd;

    material.density = tbd;
    material.emissivity = tbd;
    material.unit_cost = tbd;
    parameters.structural_material = material;

    parameters.orbital_altitude = 500; %km 
    parameters.reentry_angle = 2; %deg
    parameters.delivery_time = 5; %yrs 

    parameters.refurb_learning_rate= 0.9;
    parameters.manuf_learning_rate= 0.9;
    parameters.sat_prod_learning_rate = 0.9;

    parameters.launcher_refurb_time = tbd;
    parameters.launcher_prod_time_bins = [3,6,9; 0.5,0.5, 36];
    parameters.init_sat_prod_time = tbd;
    parameters.init_refurb_cost_percentage = 0.7;

    parameters.MY_value = 120000; %USD
    parameters.num_engines_per_stage = tbd;
    parameters.f1 = 0.6; %from koeller paper
    parameters.f3 = 1.0; %from koeller paper
    parameters.f4 = tbd;


    
end