function parameters = setup_parameters()
    parameters.mass_per_satellite = 600; %kg
    parameters.num_of_satellites = 8000; %kg
    parameters.rocket_fleet_size = 15;
    parameters.structural_material = 'Al 6061';
    parameters.struc_to_propellant_mass_ratio = 0.1;
    parameters.prop_unit_costs = readtable('propellant_costs.csv');

    material.density = 2700; %kg/m3
    material.emissivity = 0.05 ; %source : https://www.engineeringtoolbox.com/radiation-heat-emissivity-aluminum-d_433.html
    material.unit_cost = 2.85; %per kg source: https://www.navstarsteel.com/6061-t6-aluminium-plate.html
    parameters.structural_material = material;

    parameters.orbital_altitude = 500; %km 
    parameters.reentry_angle = 2; %deg
    %kuiper plans 83 launches to meet 5 yr goal of 3300 sats: https://www.thestreet.com/amazon/news/project-kuiper-what-investors-should-know
    parameters.delivery_time = 5; %yrs 

    parameters.refurb_learning_rate= 0.9;
    parameters.manuf_learning_rate= 0.9;
    parameters.sat_prod_learning_rate = 0.9;

    parameters.launcher_refurb_time = 252; %shuttle avg, but space x ar 27 to 21 days. source: https://ark-invest.com/newsletters/issue-335/
    parameters.launcher_prod_time_bins = [3,6,9; 0.5,0.5, 36];
    %one web is manufc 2 sats per day: https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwiaycuK89v9AhX7j4kEHbKxBusQFnoECBAQAw&url=https%3A%2F%2Fwww.floridatoday.com%2Fstory%2Ftech%2Fscience%2Fspace%2F2022%2F01%2F21%2Foneweb-satellites-look-inside-sci-fi-factory-kennedy-space-center-florida%2F6172817001%2F&usg=AOvVaw3NnmyaKJKqShZW8TTM5QS4
    %new record speed at 120 starlinks per month. source: https://www.cnbc.com/2020/08/10/spacex-starlink-satellte-production-now-120-per-month.html
    parameters.init_sat_prod_time = 30; %days, lets try this value and see if the learning rate drops fast enough to realistic values  
    parameters.init_refurb_cost_percentage = 0.7;

    parameters.MY_value = 350000; %USD, inflation adjusted (and rounded up) from the 1984 number provided in the Koelle paper
    parameters.num_engines_per_stage = tbd;
    parameters.f1 = 0.6; %from koeller paper
    parameters.f3 = 1.0; %from koeller paper
    parameters.f4 = tbd;


    
end