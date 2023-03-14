function parameters = setup_parameters()
    parameters.mass_per_satellite = tbd;
    parameters.num_of_satellites = tbd;
    parameters.rocket_fleet_size = tbd;
    parameters.structural_material = tbd;
    parameters.struc_to_propellant_mass_ratio = tbd;

    material.density = tbd;
    material.emissivity = tbd;
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


    
end