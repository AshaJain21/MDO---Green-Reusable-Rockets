function num_sat_stacks = calculate_num_stacks(rocket_ri, sat_ri, circle_packing_densities)
    for i = 1:length(circle_packing_densities)
        density = (i*pi*sat_ri^2)/(pi*rocket_ri^2);
        if density > circle_packing_densities(i)
            num_sat_stacks = i-1;
            break
        end
    end
end