function reentry_nox_kg_per_alt_map = compute_reentry_nox_emission(second_stage_reentry_mass)
    shuttle_data = [5.87e17, 4.09e18, 3.73e19, 2.8e20, 5.77e20, 6.28e20, 7.27e20, 8.22e20, 6.36e20, 4.62e20, 1.25e20, 6.93e16]
    shuttle_alts = [121.9, 106.6, 93, 81.4, 76.2, 73.2, 70.7, 67.1, 63.4, 61. 57.3, 54.3];
    shuttle_data = shuttle_data / sum(shuttle_data)
    reentry_nox_kg_per_alt = second_stage_reentry_mass .* shuttle_data
    reentry_nox_kg_per_alt(2, :) = shuttle_alts;

    reentry_nox_kg_per_alt_map = containers.Map({"NOx"}, {reentry_nox_kg_per_alt});

    %Source = Park, C., & Rakich, J. V. (1980). Equivalent-cone calculation of nitric oxide production rate during space shuttle re-entry. Atmospheric Environment (1967), 14(8), 971–972. doi:10.1016/0004-6981(80)90011-6 
end 