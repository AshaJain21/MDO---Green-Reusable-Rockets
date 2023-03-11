function species_lifetimes = compute_lifetimes(combined_emissions)
    %life times are in days 
    aerosols = ['BC', 'Al2O3']
    gases = ['H2O', 'NOx', 'ClOx', 'COx']
    aerosol_species   = combined_emissions{aerosols}
    gas_species = combined_emissions{gases}
    %Compute aerosol lifetimes using sedimentation 

    aerosol_lifetimes = compute_aerosol_lifetimes(aerosol_species);
    gas_lifetimes = compute_gas_lifetimes(gas_species);
    species_lifetimes = containers.Map;
    for i=1:len(gas_species)
        species_lifetimes(gas_species(i)) = gas_lifetimes(i);
    end
    for i=1:len(aerosol_species)
        species_lifetimes(aerosol_species(i)) = aerosol_lifetimes(i);
    end

end

function aerosol_lifetimes = compute_aerosol_lifetimes(aerosol_species)
    %assuming mass-weighted average diameter for aerosols
    %alumina source =
    %https://www.eucass-proceedings.eu/articles/eucass/pdf/2013/01/eucass4p657.pdf
    %this mode represents over 99% of the mass
    %black carbon source =
    %https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6472719/ 
    %https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2021JD036373

    %assumed mesospheric lifetime is 4 yrs from 

    diameters = containers.Map({'Al2O3', 'BC'}, {2, 2.5}); %microns 
    stratosphere_lifetimes = readtable("stratosphere_lifetimes.csv");
    troposphere_lifetimes = readtable("troposphere_lifetimes.csv");
    aerosol_lifetimes = containers.Map;
    aerosols = aerosol_species.keys;
    for i = 1:size(aerosols)
        aerosol_data = aerosol_species(aerosols(i));
        diameter = diameters(aerosols(i));
        altitudes = aerosol_data(2,:);
        lifetimes = zeros(size(altitudes));
        troposphere_indices = altitudes < 10;
        stratosphere_indices = altitides > 10 && altitudes > 40 ;
        mesosphere_indices = altitudes > 40 ;
        lifetimes(troposphere_indices) = find_lifetime(troposphere_lifetimes, diameter);
        lifetimes(stratosphere_indices) = find_lifetime(stratosphere_lifetimes, diameter);
        lifetimes(mesosphere_indices) = 4 * 365;
        aerosol_lifetimes(aerosols(i)) = lifetimes;

    end
    
end
%TODO FINISH GAS LIFETIMES
function gas_lifetimes = compute_gas_lifetimes(gas_species)
    gases = gas_species.keys;
    gas_lifetimes = containers.Map;
    for i = 1:size(gases)
        gas_data = gas_species(gases(i));
        altitudes = gas_data(2,:);
        lifetimes = zeros(size(altitudes));
        stratosphre_indices = altitudes > 10 && altitudes < 40 ;
        lifetimes(stratosphre_indices) = 4*365;
        

        gas_lifetimes(gases(i)) = lifetimes;

    end
    

end

function lifetime = find_lifetime(lifetime_over_particle_size_data, diameter)
    diameters = lifetime_over_particle_size_data{:, 1};
    lifetimes = lifetime_over_particle_size_data{: ,2};
    [~, closest_diameter_index] = min(abs(diameters - diameter));
    lifetime = lifetimes(closest_diameter_index-1: closest_diameter_index+1);
end


