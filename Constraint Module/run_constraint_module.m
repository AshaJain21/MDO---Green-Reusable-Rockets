function constraints = run_constraint_module(design_variables, parameters, rocket, launch_cadence, cost)
  %Constraint on Launch Cadence 
   constraints.launch_cadence = sum(launch_cadence(2,:)) - (parameters.delivery_time * 12); %months 

  %Constraint on Cost 
  budget_per_year = [];
  [~, cols] = size(cost);
  months_counter = 0;
  current_year_budget = 0;
  for c = 1:cols
      if months_counter < 12
          current_year_budget = current_year_budget + cost(1,c);
      else
          budget_per_year(end + 1) = current_year_budget;    
          current_year_budget = cost(1, c);
      end
      months_counter = cost(2, c);

  end
  max_cost_per_year = max(budget_per_year);
  constraints.max_cost_year = max_cost_per_year - parameters.max_cost_per_year;

  %Constraint on rocket height 
   constraints.rocket_height = rocket.stage1.height + rocket.stage2.height - parameters.max_rocket_height; 

   %Constraint on mprop1 and mprop1_guess 
   constraints.mprop1 = rocket.stage1.mprop - design_variables.mprop1_guess;
   constraints.mprop2 = rocket.stage2.mprop - design_variables.mprop2_guess;

   %Constraint num_engines
   constraints.min_stg1_num_engines = parameters.min_num_engines - rocket.stage1.nEng;
   constraints.max_stg1_num_engines = rocket.stage1.nEng - parameters.max_num_engines;


end