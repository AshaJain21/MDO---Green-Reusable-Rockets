function constraints = run_constraint_module(design_variables, parameters, rocket, launch_cadence, cost)
   %Constraint on Launch Cadence 
   total_time = sum(launch_cadence(1,:));
   constraints.launch_cadence =  total_time - (parameters.delivery_time * 12); %months 


  %Constraint on Cost 
  budget_per_year = zeros(1, (ceil(total_time/12)));
  [~, cols] = size(cost);
  curr_year = 1;
  current_year_budget = 0;
  
  for c = 1:cols
      curr_month = cost(2, c);

      if curr_month < (curr_year * 12)
          current_year_budget = current_year_budget + cost(1,c);
      else
          budget_per_year(curr_year) = current_year_budget;    
          current_year_budget = cost(1, c);
          curr_year = curr_year + 1;
      end
  end
  budget_per_year(curr_year) = current_year_budget;

  max_cost_per_year = max(budget_per_year);
  constraints.max_cost_year = max_cost_per_year - parameters.max_cost_per_year;


   %Constraint on rocket height 
   total_rocket_height = rocket.stage1.height + rocket.stage2.height;
   constraints.rocket_height = total_rocket_height - parameters.max_rocket_height; 

   %Constraint on payload height in relation to rocket height
   constraints.payload_height = rocket.payload_height - (parameters.max_payload_height_fraction*total_rocket_height);

   %Constraint on mprop1 and mprop1_guess 
   constraints.mprop1 = rocket.stage1.mprop - design_variables.mprop1_guess;
   constraints.mprop2 = rocket.stage2.mprop - design_variables.mprop2_guess;

   %Constraint num_engines
   constraints.min_stg1_num_engines = parameters.min_num_engines - rocket.stage1.nEng;
   constraints.max_stg1_num_engines = rocket.stage1.nEng - parameters.max_num_engines;


end