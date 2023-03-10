function reentry_alumina_kg_per_alt_map = compute_reentry_alumina_emission(second_stage_reentry_mass)
    %Assumed reentry stage is 70 aluminum 
    aluminum_mass = second_stage_reentry_mass * 0.7;
    rocket_body_ablation_profile = readtable("esa_rocket_body_ablation_profile.csv")
    reentry_alumina_kg_per_alt = rocket_body_ablation_profile['Al Mass Loss Fraction'] * aluminum_mass
    reentry_alumina_kg_per_alt(2,:) = rocket_body_ablation_profile.Altitude
    reentry_alumina_kg_per_alt_map = containers.Map({'Al2O3'}, {reentry_alumina_kg_per_alt})
    
end