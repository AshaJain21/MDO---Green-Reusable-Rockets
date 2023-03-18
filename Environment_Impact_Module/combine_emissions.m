function combined_emission = combine_emissions(propellant_mass_burned_per_altitude, added_emissions)
    added_emissions_keys = added_emissions.keys;

    for i = 1:size(added_emissions_keys)
        if isKey(propellant_mass_burned_per_altitude, added_emissions_keys{i})
            existing_emission = propellant_mass_burned_per_altitude(added_emissions_keys{i});
            propellant_mass_burned_per_altitude(added_emissions_keys{i}) = existing_emission + added_emissions(added_emissions_keys{i});
        else
            new_emission = added_emissions_over_altitude(added_emissions_keys{i});
            propellant_mass_burned_per_altitude(added_emissions_keys{i}) = new_emission;
        end
    end
    combined_emission  = propellant_mass_burned_per_altitude;
end