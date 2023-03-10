function env_impact = run_env_impact_module(propellant_mass_burned_per_altitude, second_stage_reentry_mass, design_variables, parameters)
    %Assumed that propellants are given in kg
    reentry_nox_emissions = compute_reentry_nox_emission(second_stage_reentry_mass);
    combined_emissions = combine_emissions(propellant_mass_burned_per_altitude, reentry_nox_emissions);
    if parameters.reusable_stage(2) == False
        alumina_emissions = compute_reentry_alumina_emission(second_stage_reentry_mass);
        combined_emissions = combine_emissions(combined_emissions, alumina_emissions);
    end

    species_lifetimes = compute_lifetimes(combined_emissions)
    species_rf = compute_rf(combined_emissions);
    species_ozone_depletion = compute_ozone_depletion(combined_emissions);

    launch_schedule = design_variables.launch_schedule;
    
    env_impact = compute_combined_environmental_impact(species_lifetimes, species_rf, species_ozone_depletion, launch_schedule);

end


%Source for propellant byproduct mass fractions = https://www.tandfonline.com/doi/epdf/10.1080/14777620902768867?needAccess=true&role=button

function ei_score = compute_combined_environmental_impact(species_lifetimes, species_rf, species_ozone_depletion, launch_schedule)

end