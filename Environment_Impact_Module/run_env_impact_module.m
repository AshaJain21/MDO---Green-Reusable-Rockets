function env_impact = run_env_impact_module(propellant_mass_burned_per_altitude, second_stage_reentry_mass, parameters)
    %Assumed that propellants are given in kg
    reentry_nox_emissions = compute_reentry_nox_emission(second_stage_reentry_mass);
    combined_emissions = combine_emissions(propellant_mass_burned_per_altitude, reentry_nox_emissions);
    if parameters.reusable_stage(2) == 0
        alumina_emissions = compute_reentry_alumina_emission(second_stage_reentry_mass);
        combined_emissions = combine_emissions(combined_emissions, alumina_emissions);
    end

    species_rf = compute_rf(combined_emissions);
    species_ozone_depletion = compute_ozone_depletion(combined_emissions);
    
    env_impact = compute_combined_environmental_impact(species_rf, species_ozone_depletion);

end


%Source for propellant byproduct mass fractions = https://www.tandfonline.com/doi/epdf/10.1080/14777620902768867?needAccess=true&role=button

function ei_score = compute_combined_environmental_impact(species_rf, species_ozone_depletion)
    rf_species_keys = species_rf.keys;
    size_of_rf_keys = size(rf_species_keys);
    total_rf  = 0;
    total_od = 0;
    for i = 1:size_of_rf_keys(2)
        data = species_rf(rf_species_keys{i});
        integrated_effect_over_all_altitudes = trapz(data(1,:), data(2, :));
        total_rf = total_rf + integrated_effect_over_all_altitudes; %in mW^2
    
    end 
    od_species_keys = species_ozone_depletion.keys;
    size_of_od_keys = size(od_species_keys);
    for j = 1:size_of_od_keys(2)
        data = species_ozone_depletion(od_species_keys{i});
        integrated_effect_over_all_altitudes = trapz(data(1,:), data(2, :));
        total_od = total_od+ integrated_effect_over_all_altitudes; %percent loss 
    end
    ei_score = [total_rf, total_od];

       
end