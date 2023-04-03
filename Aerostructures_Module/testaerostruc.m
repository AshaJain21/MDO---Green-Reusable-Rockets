%Test Script Aerodynamics and Structures
%One time setup
parameters = setup_parameters();
%Load data describing each design experiment 
doe_bins = readtable("doe_bins.csv");
othrogonal_array = readtable("design_of_experiments.csv");
num_othrogonal_array = size(othrogonal_array.Experiment); 
%Create experiments table 
experiments = format_final_doe_array(num_othrogonal_array(1), othrogonal_array, doe_bins);
num_experiments = size(experiments.num_of_launches);

%Loading database data
engine_prop_db = readtable("engine-prop-combinations.csv");
reentry_shield_material_db = readtable("reentry_shield_materials.csv");

    %Engine Prop data 
    engine_prop_1 = engine_prop_db(experiments{1, 2}, :);
    engine_prop_1.Fuel= string(engine_prop_1.Fuel);
    engine_prop_1.Engine = string(engine_prop_1.Engine);
    engine_prop_1.Oxidizer = string(engine_prop_1.Oxidizer);
    
    engine_prop_2 = engine_prop_db(experiments{1, 3}, :);
    engine_prop_2.Fuel= string(engine_prop_2.Fuel);
    engine_prop_2.Engine = string(engine_prop_2.Engine);
    engine_prop_2.Oxidizer = string(engine_prop_2.Oxidizer);

    reentry_shield_material = reentry_shield_material_db(1, :);
    
    
design_variables = setup_designvariables(engine_prop_1, engine_prop_2, reentry_shield_material);


%1kgf = 9.81 kgm/s^2
%run modules
[rocket] = setup_rocket();
%addpath(genpath([pwd '/combustion_toolbox/']))
[rocket] = aerostructures(design_variables, parameters, rocket);


function experiments = format_final_doe_array(num_experiments, orthogonal_array, doe_bins)
   num_factors = 5;
   experiments = array2table(zeros(64,8), 'VariableNames',{'num_of_launches', 'engine_prop_1', 'engine_prop_2', 'reentry_shield_material', 'rocket_radius', 'reusable_stage1', 'reusable_stage2', 'output_cost'});
   for exp = 1:num_experiments
       for factor = 2:num_factors+1
           experiments(exp*4-3, factor-1) = doe_bins(orthogonal_array{exp, factor}, factor);
           experiments(exp*4-2, factor-1) = doe_bins(orthogonal_array{exp, factor}, factor);
           experiments(exp*4-1, factor-1) = doe_bins(orthogonal_array{exp, factor}, factor);
           experiments(exp*4, factor-1) = doe_bins(orthogonal_array{exp, factor}, factor);
       end
       experiments{exp*4-3, 6} = 1;
       experiments{exp*4-3, 7} = 1;
       experiments{exp*4-3, 8} = 0;
       experiments{exp*4-2, 6} = 1;
       experiments{exp*4-2, 7} = 0;
       experiments{exp*4-2, 8} = 0;
       experiments{exp*4-1, 6} = 0;
       experiments{exp*4-1, 7} = 1;
       experiments{exp*4-1, 8} = 0;
       experiments{exp*4, 6} = 0;
       experiments{exp*4, 7} = 0;
       experiments{exp*4, 8} = 0;

   end
end
%functions
function parameters = setup_parameters()   
    parameters.structural_material = 'Al 6061';
    parameters.initial_struct_masses = [395700, 92670];
    %parameters.prop_unit_costs = readtable('propellant_costs.csv');
    material.density = 2700; %kg/m3
    material.emissivity = 0.05 ; %source : https://www.engineeringtoolbox.com/radiation-heat-emissivity-aluminum-d_433.html
    material.unit_cost = 2.85; %per kg source: https://www.navstarsteel.com/6061-t6-aluminium-plate.html
    material.fatigue_stress = 9.65e+7; %Pa source: https://www.thomasnet.com/articles/metals-metal-products/6061-aluminum/
    parameters.structural_material = material;
    parameters.orbital_altitude = 500; %km 
    parameters.reentry_angle = 2; %deg 
    parameters.propellant_properties = readtable('propellant_properties.csv');
    
end

function design_variables = setup_designvariables(engine_prop_1, engine_prop_2, reentry_shield_material)
    design_variables.stage1.reusable =1;
    design_variables.stage2.reusable = 1;
    %db = readtable("reentry_shield_materials.csv");
    design_variables.stage2.reentry_shield_material.Density = 802; %kg/m3
    design_variables.rocket_ri = 4.5; %m
    design_variables.stage1.engine_prop = engine_prop_1;
    design_variables.stage2.engine_prop = engine_prop_2;  
    design_variables.stage2.reentry_shield_material = reentry_shield_material;
    design_variables.mprop1_guess = 395700/0.1; %mprop1_guess;
    design_variables.mprop2_guess =92670/0.1;% mprop2_guess;
end

function rocket = setup_rocket()
    rocket.stage1.thrust = 7590000; %kgf
    rocket.stage2.thrust = 1500000;
    rocket.stage1.mdot =  1.40e4; %10^4 kg/s; %mass flow rate of exhaust 
    rocket.stage2.mdot = 1.40e4;
    rocket.payload_height = 50; %huge
    rocket.payload_mass = 300000; %kg
    
end