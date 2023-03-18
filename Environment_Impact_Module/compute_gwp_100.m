function gwp_rf_per_species = compute_gwp_100(combined_emissions)
%taken from https://strathprints.strath.ac.uk/82291/1/Calabuig_etal_EUCASS_2022_Eco_design_of_future_reusable_launchers.pdf
%Assumed aviation GWP 100yr values
gwp_rf_per_species_perMg_map = containers.Map({'H2O','COx','BC','Al2O3', 'NOx'},{0.06, 2.57, 1116, 1.23, 114}); 

species_keys = combined_emissions.keys();
gwp_rf_per_species = containers.Map;
size_of_keys = size(species_keys);
for i = 1:size_of_keys(2)
    key = species_keys{i};
    if gwp_rf_per_species_perMg_map.isKey(key)
          data = combined_emissions(key) ; 
          data(2,:) = data(1, :) * gwp_rf_per_species_perMg_map(key) ; 
          gwp_rf_per_species(key)  = data;
    end
    
end