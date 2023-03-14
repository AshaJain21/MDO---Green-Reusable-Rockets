function refurb_cost = compute_refurb_cost(stage_manuf_cost, launch_schedule, learning_rate)
    %One option appears to take 30% of the stage cost as the
    %refurbinshemnt cost - https://ojs.cvut.cz/ojs/index.php/mad/article/view/4855
    %News article confirms that Space X stage 1 refurb cost is less
    %than half of stage 1 manuf cost - https://spacenews.com/spacex-gaining-substantial-cost-savings-from-reused-falcon-9/
    %Assumed that the first refurb cost would be 50% of stage cost
    starting_percentage = 0.7;
    num_launches = size(launch_schedule);
    refurb_cost = zeros([1, num_launches(2)]);
    refurbish_launch_count = 0;
    for i = 1:num_launches
        if launch_schedule(i, 2) == 1
            stage_cost = stage_manuf_cost(i); 
            refurbish_launch_count = refurbish_launch_count + 1;
            learned_percentage = starting_percentage * refurbish_launch_count^learning_rate;
            refurb_cost_for_stage = stage_cost * learned_percentage;
            refurb_cost(i) = refurb_cost_for_stage;
        end 

    end


end