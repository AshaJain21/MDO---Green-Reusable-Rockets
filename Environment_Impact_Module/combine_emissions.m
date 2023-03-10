function combined_emission = combine_emissions(propellant_mass_burned_per_altitude, added_emissions_over_altitude)
    added_emissions_keys = added_emissions_over_altitude.keys

    for i = 1:len(added_emissions_keys)
        if isKey(propellant_mass_burned_per_altitude, added_emissions_keys(i))
            existing_emission = propellant_mass_burned_per_altitude(added_emissions_keys(i));
            new_emission = [existing_emission, added_emissions_over_altitude(added_emissions_keys(i))];
            propellant_mass_burned_per_altitude(added_emissions_keys(i)) =new_emission;
        else
            propellant_mass_burned_per_altitude(added_emissions_keys(i)) = added_emissions_over_altitude(added_emissions_keys(i));
        end
    end
    combined_emission  = propellant_mass_burned_per_altitude;
end