function rf_per_species = compute_rf(combined_emissions)
%Need to adjust with particle lifetime
rf_per_species_perMg_map = containers.Map({'COx','H2O','Al2O3','BC'},{1.7e-8,3.2e-5,6e-3,3.4e-2}); %taken from https://strathprints.strath.ac.uk/82291/1/Calabuig_etal_EUCASS_2022_Eco_design_of_future_reusable_launchers.pdf
species_keys = combined_emissions.keys();
rf_per_species = containers.Map;

for i = 1:size(species_keys)
    key = species_keys(i);
    if rf_per_species_perMg_map.isKey(key)
          rf_per_species(key) = combined_emissions(key) * rf_per_species_perMg_map(key) * 1000 ; %conversion factor from Mg to kg 
    end
    
end