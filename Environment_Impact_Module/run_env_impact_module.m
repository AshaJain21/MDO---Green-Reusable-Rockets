function env_impact = run_env_impact_module(design_variables, rocket)
    second_stage_reentry_mass = rocket.stage2.mstruct;
    stage1_fuel =design_variables.stage1.engine_prop.Fuel;
    stage2_fuel = design_variables.stage2.engine_prop.Fuel;
    stage1_combustion_products = handle_stage_products(rocket.stage1.mprop.*rocket.stage1.prodValues, rocket.stage1.prodNames, rocket.stage1.mprop, stage1_fuel);
    stage2_combustion_products = handle_stage_products(rocket.stage2.mprop.*rocket.stage2.prodValues, rocket.stage2.prodNames, rocket.stage2.mprop, stage2_fuel);
    stage2_species_keys = stage2_combustion_products.keys();
    combined_emissions = stage1_combustion_products;
   
    for l = 1:max(size(stage2_species_keys))
        stage2_key = stage2_species_keys{l};
        if isKey(stage1_combustion_products, stage2_key) 
            combined_emissions(stage2_key) = combined_emissions(stage2_key) + stage2_combustion_products(stage2_key);

        else
            combined_emissions(stage2_key) = stage2_combustion_products(stage2_key);
        end
    end
  
    %Assumed that propellants are given in kg
    reentry_nox_emissions = compute_reentry_nox_emission(second_stage_reentry_mass);
    combined_emissions = combine_emissions(combined_emissions, reentry_nox_emissions);
    if design_variables.stage2.reusable == 0
        alumina_emissions = compute_reentry_alumina_emission(second_stage_reentry_mass);
        combined_emissions = combine_emissions(combined_emissions, alumina_emissions);
    end

    species_rf = compute_rf(combined_emissions);
    species_ozone_depletion = compute_ozone_depletion(combined_emissions);
    species_gwp100 = compute_gwp_100(combined_emissions);
    
    env_impact = compute_combined_environmental_impact(species_rf, species_ozone_depletion, species_gwp100);

end

function stage_emissions_kg = handle_stage_products(prodValues,prodNames, stage_propellant_mass, stage_fuel)
    stage_emissions_kg = containers.Map;
    list_of_species = {'COx', 'NOx', 'H2O'};
    for l =1:max(size(list_of_species))
        species = list_of_species{l};
        emission = 0;
        if strcmp(species, 'COx') == 1
            sub_species = {'CO2', 'CO'};
            for s = 1:max(size(sub_species))
                sub_chem = sub_species{s};
                if isempty(prodValues(strmatch(sub_chem, prodNames, 'exact'))) == 0
                    emission = emission + prodValues(strmatch(sub_chem, prodNames, 'exact'));
                end
            end


        elseif strcmp(species, 'NOx') == 1
            sub_species = {'NO2', 'NO'};
            for s = 1:max(size(sub_species))
                sub_chem = sub_species{s};
                  if isempty(prodValues(strmatch(sub_chem, prodNames, 'exact'))) == 0
                    emission = emission + prodValues(strmatch(sub_chem, prodNames, 'exact'));
                  end
            end

        elseif strcmp(species, 'H2O') == 1
             sub_species = {'H2O', 'HO', 'HO2'};
            for s = 1:max(size(sub_species))
                sub_chem = sub_species{s};
                if isempty(prodValues(strmatch(sub_chem, prodNames, 'exact'))) == 0
                    emission = emission + prodValues(strmatch(sub_chem, prodNames, 'exact'));
                end
            end

         end
        stage_emissions_kg(species) = emission;
    end
   if strcmp(stage_fuel, 'UDMH') == 1 || strcmp(stage_fuel, 'RP-1') == 1 || strcmp(stage_fuel, 'A-50') == 1 || strcmp(stage_fuel, 'CH4') == 1
        stage_emissions_kg('BC') =  (40 * stage_propellant_mass) / 1000; % kg
        %40g/kg comes from https://agupubs-onlinelibrary-wiley-com.libproxy.mit.edu/doi/full/10.1029/2021JD036373
   end
end

%Source for propellant byproduct mass fractions = https://www.tandfonline.com/doi/epdf/10.1080/14777620902768867?needAccess=true&role=button

function ei_score = compute_combined_environmental_impact(species_rf, species_ozone_depletion, species_gwp100)
    rf_species_keys = species_rf.keys;
    size_of_rf_keys = size(rf_species_keys);
    total_rf  = 0;
    total_od = 0;
    total_gwp = 0;
    for i = 1:size_of_rf_keys(2)
        data = species_rf(rf_species_keys{i});
        total_rf = total_rf + data(2); %in mW^2
     
    
    end 
    od_species_keys = species_ozone_depletion.keys;
    size_of_od_keys = size(od_species_keys);
    for j = 1:size_of_od_keys(2)
        data = species_ozone_depletion(od_species_keys{j});
        total_od = total_od+ data(2); %percent loss 
        
    end

    gwp_100_species_keys = species_gwp100.keys;
    size_of_gwp100_keys = size(gwp_100_species_keys);
    for l = 1:size_of_gwp100_keys(2)
        data = species_gwp100(gwp_100_species_keys{l});
        total_gwp = total_gwp+ data(2); %kgCO2_eq 
    end

    ei_score = [total_rf, total_od, total_gwp]; 

       
end