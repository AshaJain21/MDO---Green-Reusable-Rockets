function combined_emission = combine_emissions(propellant_mass_burned_per_altitude, added_emissions_over_altitude)
    added_emissions_keys = added_emissions_over_altitude.keys;

    for i = 1:size(added_emissions_keys)
        if isKey(propellant_mass_burned_per_altitude, added_emissions_keys{i})
            existing_emission = propellant_mass_burned_per_altitude(added_emissions_keys{i});
            new_emission = [existing_emission, added_emissions_over_altitude(added_emissions_keys{i})];
            [~, order] = sort(new_emission(1,:));
            new_emission = new_emission(:,order);
            propellant_mass_burned_per_altitude(added_emissions_keys{i}) =new_emission;
        else
            propellant_mass_burned_per_altitude(added_emissions_keys{i}) = added_emissions_over_altitude(added_emissions_keys{i});
        end
    end
    combined_emission  = propellant_mass_burned_per_altitude;
end