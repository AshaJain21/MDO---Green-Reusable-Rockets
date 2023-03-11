function species_ozone_depletion = compute_ozone_depletion(combined_emissions)
%     odps = containers.Map({'Al2O3', 'NOx', 'ClOx', 'BC', 'H2O'}, {0.055})
%     sources_odps = ['Danilin 2001 https://doi.org/10.1029/2001JD900022', ]

   ss_ozone_loss_per_kg = containers.Map({'Al2O3', 'NOx', 'ClOx', 'BC', 'H2O'}, {2.5e-9 / 4,7.968e-10 / 4, 1.634e-8 /4 , 5.83e-6/4, 1.78e-13/4})
   %yealry injection rate is divided by 4 to estimate the steady state
   %burden from the yearly influx based on Ross - https://agupubs.onlinelibrary.wiley.com/doi/10.1002/2013EF000160
   sources_ss_ozone_loss  = ['Danilin 2001 https://doi.org/10.1029/2001JD900022', "Ross 2004 - https://doi.org/10.1029/2003JD004370", "Prather 1990 -  10.1029/JD095iD11p18583", x, "Ross 2010 - https://agupubs.onlinelibrary.wiley.com/doi/full/10.1029/2010GL044548", x, "Ross 2004 - https://doi.org/10.1029/2003JD004370"]
   species_ozone_depletion = containers.Map 

   ss_keys = ss_ozone_loss_per_kg.keys
   for i = 1:len(ss_keys)
       if combined_emissions.isKey(ss_keys(i)) == True
           species_ozone_depletion(ss_keys(i)) = ss_ozone_loss_per_kg(ss_keys(i)) * combined_emissions(ss_keys(i));
       end
   end

end