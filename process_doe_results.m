function effects_all = process_doe_results(doe_array)

    effects_all=zeros(10, 3);
    overall_mean_val= mean(doe_array(:, 12));
    overall_mean_comp_time = mean(doe_array(:, 13));
    effect_num = 0;

    unique_col_vals = unique(doe_array(:, 1));
    
    for j = 1:length(unique_col_vals)
        col_val = unique_col_vals(j);

        rows_to_compute = doe_array(doe_array(:, 1) == col_val, :);
        avg_val = mean(rows_to_compute(:, 12));
        avg_comp_time = mean(rows_to_compute(:,13));
        val_effect = avg_val - overall_mean_val;
        comp_time_effect = avg_comp_time - overall_mean_comp_time;
        
        effect_num = effect_num + 1;
        effects_all(effect_num,:) = [col_val, val_effect, comp_time_effect];
        
    end

    effects_all = effects_all(1:effect_num, :);
end