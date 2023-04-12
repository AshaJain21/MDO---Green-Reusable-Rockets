function [c, ceq] = calculate_nonpenalty_constraints_derivative(x)
  
    num_launches = 100;
    stage1_boolean = 0;
    stage2_boolean = 0;
    engine_prop_1_row = 8;
    engine_prop_2_row = 4;
    engine_prop_db = readtable("engine-prop-combinations.csv");
    reentry_shield_material_row = 9;
    reentry_shield_material_db = readtable("reentry_shield_materials.csv");

    design_variables = setup_designvariables(num_launches, stage1_boolean,stage2_boolean, engine_prop_db(engine_prop_1_row, :), engine_prop_db(engine_prop_2_row, :), reentry_shield_material_db(reentry_shield_material_row, :), x(1), x(2), x(3));
    parameters = setup_parameters();
    [launch_cadence, ~, ~, ~, cost, ~, rocket] = run_model(design_variables, parameters);
   
    c =[];
    ceq = [];

   %Constraint on Launch Cadence 
   total_time = sum(launch_cadence(1,:));
   c(end+1) =  total_time - (parameters.delivery_time * 12); %months 

  %Constraint on Cost 
  budget_per_year = zeros(1, (ceil(total_time/12)));
  [~, num_columns] = size(cost);
  curr_year = 1;
  current_year_budget = 0;
  
  for col = 1:num_columns
      curr_month = cost(2, col);

      if curr_month < (curr_year * 12)
          current_year_budget = current_year_budget + cost(1,col);
      else
          budget_per_year(curr_year) = current_year_budget;    
          current_year_budget = cost(1, col);
          curr_year = curr_year + 1;
      end
  end
  budget_per_year(curr_year) = current_year_budget;

  max_cost_per_year = max(budget_per_year);
  c(end+1) = max_cost_per_year - parameters.max_cost_per_year;

   %Constraint on rocket height 
   total_rocket_height = rocket.stage1.height + rocket.stage2.height;
   c(end+1) = total_rocket_height - parameters.max_rocket_height; 

   %Constraint on payload height in relation to rocket height
   c(end+1) = rocket.payload_height - (parameters.max_payload_height_fraction*total_rocket_height);

   %Constraint on mprop1 and mprop1_guess
   ceq(end+1) = rocket.stage1.mprop - design_variables.mprop1_guess;
   ceq(end+1) = rocket.stage2.mprop - design_variables.mprop2_guess;

   %Constraint num_engines
   c(end+1) = parameters.min_num_engines - rocket.stage1.nEng;
   c(end+1) = rocket.stage1.nEng - parameters.max_num_engines;

   %Constraint on engine size relative to rocket radius
   c(end+1) = design_variables.stage1.engine_prop{1,8} - design_variables.rocket_ri;
   c(end+1) = design_variables.stage2.engine_prop{1,8} - design_variables.rocket_ri;


end