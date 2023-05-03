function all_results = reprocess_optimal_designs(doe_res)
    
    parameters = setup_parameters();
    doe_res(:, 3:8) = round(doe_res(:, 3:8));
    all_results = [];
    engine_prop_db = readtable("engine-prop-combinations.csv");
    reentry_shield_material_db = readtable("reentry_shield_materials.csv");
    
    for i = 1:height(doe_res)
        design_variables = setup_designvariables(doe_res(i, 3), doe_res(i, 4), doe_res(i, 5), engine_prop_db(doe_res(i, 6), :), engine_prop_db(doe_res(i, 7), :), reentry_shield_material_db(doe_res(i, 8), :), doe_res(i, 9), doe_res(i, 10), doe_res(i, 11));
        [launch_cadence, ~, ~, ~, ~, constraints, rocket] = run_model(design_variables, parameters);
        res_struct = struct(launch_cadence=launch_cadence, rocket=rocket, constraints=constraints);
        all_results = [all_results, res_struct];
    end

    % Plotting code
    
%     launch_cadence_all = all_results(1);
    colors = ['r', 'b', 'k', 'g', 'c', 'm', 'y', "#7E2F8E", "#a3957e"];
    marker = ['o', 'x'];
    marker_size = [10, 15];
    figure()
    launch_cadence = all_results(1).launch_cadence;
    cumulative_launch_cadence = cumsum(launch_cadence(1,:));
    semilogy(cumulative_launch_cadence, 'o', "MarkerSize", 15, "MarkerEdgeColor", colors(1))
    hold on;
    launch_cadence = all_results(2).launch_cadence;
    cumulative_launch_cadence = cumsum(launch_cadence(1,:));
    semilogy(cumulative_launch_cadence, '.', "MarkerSize", 15, "MarkerEdgeColor", colors(2))
    hold off;
   
    legend_labels = append('Trial. #', string(1:length(all_results)));
    legend(legend_labels, 'FontSize', 16)
    xlabel('Launch ID', 'FontSize', 16)
    ylabel('Number of Months until Launch', 'FontSize', 16)
    title('Launch Cadences for Each Trial', 'FontSize', 16)
    ax=gca;
    ax.FontSize = 20;
    grid on
    hold off

end

