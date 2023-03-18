function rf_per_species = compute_rf(combined_emissions)
rf_per_species_perMg_map = containers.Map({'COx','H2O','Al2O3','BC'},{1.7e-8,3.2e-5,6e-3,3.4e-2}); %taken from https://strathprints.strath.ac.uk/82291/1/Calabuig_etal_EUCASS_2022_Eco_design_of_future_reusable_launchers.pdf
species_keys = combined_emissions.keys();
rf_per_species = containers.Map;
size_of_keys = size(species_keys);
for i = 1:size_of_keys(2)
    key = species_keys{i};
    if rf_per_species_perMg_map.isKey(key)
          data = combined_emissions(key) ; 
          modifed_data = zeros(2,1);
          modifed_data(1, :) = data;
          modifed_data(2,:) = data* rf_per_species_perMg_map(key) / 1000 ; %conversion factor from Mg to kg 
          rf_per_species(key)  = modifed_data;
    end
    
end