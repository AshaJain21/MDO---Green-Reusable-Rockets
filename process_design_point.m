function all_results = process_design_point(design_points, plot_on)

    % design_points should be a n x 9 array where n is the number of design points to be processed
    % Each row of the array should have the design variables for that design point arranged in 
    % the following order: [# launch,reuse1,reuse2,engine1,engine2,re-entry mat, ri ,  mprop1, mprop2]
    
    parameters = setup_parameters();
    all_results = [];
    engine_prop_db = readtable("engine-prop-combinations.csv");
    reentry_shield_material_db = readtable("reentry_shield_materials.csv");
    
    for i = 1:height(design_points)
        design_variables = setup_designvariables(design_points(i, 1), design_points(i, 2), design_points(i, 3), engine_prop_db(design_points(i, 4), :), engine_prop_db(design_points(i, 5), :), reentry_shield_material_db(design_points(i, 6), :), design_points(i, 7), design_points(i, 8), design_points(i, 9));
        [launch_cadence, ~, ~, ~, cost, constraints, rocket] = run_model(design_variables, parameters);
        avg_cost = sum(cost(1,:))/width(cost);
        res_struct = struct(launch_cadence=launch_cadence, rocket=rocket, constraints=constraints, avg_cost=avg_cost);
        all_results = [all_results, res_struct];
    end

    if plot_on == 1
        % Plotting code
        colors = ['r', 'b', 'k', 'g', 'c', 'm', 'y', "#7E2F8E", "#a3957e"];
        markers = ['.', 'o', '*', '^'];
        figure()
        for j = 1:length(all_results)
            launch_cadence = all_results(j).launch_cadence;
            cumulative_launch_cadence = cumsum(launch_cadence(1,:));
            loglog(cumulative_launch_cadence, markers(j), "MarkerSize",15, "MarkerEdgeColor", colors(j))
            hold on
        end
        legend_labels = append('Exp. #', string(1:length(all_results)));
        legend(legend_labels, 'FontSize', 16)
        xlabel('Launch ID', 'FontSize', 16)
        ylabel('Number of months since start when launch occurrs', 'FontSize', 16)
        title('Launch Cadences for Each Trial', 'FontSize', 16)
        ax=gca;
        ax.FontSize = 20;
        grid on
        hold off
    end
end

