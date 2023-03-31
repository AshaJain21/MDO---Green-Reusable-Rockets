function parameters = setup_parameters()
    parameters.mass_per_satellite = 600; %kg
    parameters.num_of_satellites = 5000; %kg
    parameters.rocket_fleet_size = 15;
    parameters.structural_material = 'Al 6061';
    parameters.struc_to_propellant_mass_ratio = 0.1;
    parameters.initial_struct_masses = [25600, 3900]; % Based on falcon 9's structural masses for stage 1 and 2
    parameters.propellant_properties = readtable('propellant_costs.csv');

    parameters.vTerm1 = 310;
    parameters.vTerm2 = 90;

    material.density = 2700; %kg/m3
    material.emissivity = 0.05 ; %source : https://www.engineeringtoolbox.com/radiation-heat-emissivity-aluminum-d_433.html
    material.unit_cost = 2.85; %per kg source: https://www.navstarsteel.com/6061-t6-aluminium-plate.html
    material.fatigue_stress = 9.65e+7; %Pa source: https://www.thomasnet.com/articles/metals-metal-products/6061-aluminum/
    parameters.structural_material = material;

    parameters.orbital_altitude = 500; %km 
    parameters.reentry_angle = 2; %deg
    %kuiper plans 83 launches to meet 5 yr goal of 3300 sats: https://www.thestreet.com/amazon/news/project-kuiper-what-investors-should-know
    parameters.delivery_time = 5; %yrs 

    parameters.refurb_learning_rate= 0.9;
    parameters.manuf_learning_rate= 0.9;
    parameters.sat_prod_learning_rate = 0.6;

    parameters.launcher_refurb_times = [60, 30]; %Need to set stage 2 refurb time. shuttle avg, but space x ar 27 to 21 days. source: https://ark-invest.com/newsletters/issue-335/
    parameters.launcher_prod_time_bins = [1.5,3,4.5; 0.5,0.5, 36]; %Small based on electron, medium based on falcon9, large based on SLS
    %one web is manufc 2 sats per day: https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwiaycuK89v9AhX7j4kEHbKxBusQFnoECBAQAw&url=https%3A%2F%2Fwww.floridatoday.com%2Fstory%2Ftech%2Fscience%2Fspace%2F2022%2F01%2F21%2Foneweb-satellites-look-inside-sci-fi-factory-kennedy-space-center-florida%2F6172817001%2F&usg=AOvVaw3NnmyaKJKqShZW8TTM5QS4
    %new record speed at 120 starlinks per month. source: https://www.cnbc.com/2020/08/10/spacex-starlink-satellte-production-now-120-per-month.html
    parameters.init_sat_prod_time = 30; %days, lets try this value and see if the learning rate drops fast enough to realistic values  
    parameters.init_refurb_cost_percentage = 0.7;
    parameters.first_stage_prod_percentage = 0.7; %Random number for now. Need to decide if this is reasonable

    parameters.MY_value = 350000; %USD, inflation adjusted (and rounded up) from the 1984 number provided in the Koelle paper
    parameters.f1 = 0.6; %from koeller paper
    parameters.f3 = 1.0; %from koeller paper
    parameters.f4 = 0.8; %Random number for now. Need to confirm this
    parameters.max_cost_per_year = 1e12;

    parameters.loop_termination_threshold = 0.05; %Threshold to terminate the engine-structures-aero iterative loop
    parameters.max_loop_iterations = 30; %Maximum number of loop iterations before termination

    parameters.vSepReusable = 2300; %m/s
    parameters.vSepNonReusable = 3400; %m/s
    parameters.orbitalVelocity = 7600; %m/s
    parameters.drag_deltaV = 2000; %m/s

    parameters.max_rocket_height = 100; %m
    parameters.min_num_engines = 1;
    parameters.max_num_engines = 30;
    
end