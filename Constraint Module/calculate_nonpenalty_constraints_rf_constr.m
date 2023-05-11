function [c, ceq] = calculate_nonpenalty_constraints_rf_constr(x, rf_constraint)

%     global rf_constraint
  
    engine_prop_1_row = round(x(4));
    engine_prop_2_row = round(x(5));
    engine_prop_db = readtable("engine-prop-combinations.csv");
    reentry_shield_material_row = round(x(6));
    reentry_shield_material_db = readtable("reentry_shield_materials.csv");

    design_variables = setup_designvariables(round(x(1)), round(x(2)), round(x(3)), engine_prop_db(engine_prop_1_row, :), engine_prop_db(engine_prop_2_row, :), reentry_shield_material_db(reentry_shield_material_row, :), x(7), x(8), x(9));
    parameters = setup_parameters();

    [launch_cadence, total_rf, ~, ~, cost, ~, rocket] = run_model(design_variables, parameters);
   
    c =[];
    ceq = [];

   %Constraint on Launch Cadence 
   total_time = sum(launch_cadence(1,:));
   c(end+1) =  total_time - (parameters.delivery_time * 12); %months 


  %Constraint on Cost
  num_years = ceil(total_time/12);
  budget_per_year = zeros(1, num_years);
  
  for curr_year = 1:num_years
      curr_year_costs = cost(:, (cost(2,:)<=(curr_year*12) & cost(2,:)>((curr_year-1)*12)) );
      budget_per_year(curr_year) = sum(curr_year_costs(1,:));
  end

  max_cost_per_year = max(budget_per_year);
  c(end+1) = max_cost_per_year - parameters.max_cost_per_year;


   %Constraint on rocket height 
   total_rocket_height = rocket.stage1.height + rocket.stage2.height;
   c(end+1) = total_rocket_height - parameters.max_rocket_height; 

   %Constraint on payload height in relation to rocket height
   c(end+1) = rocket.payload_height - (parameters.max_payload_height_fraction*total_rocket_height);

   %Constraint on mprop1 and mprop1_guess
   c(end+1) = rocket.stage1.mprop - design_variables.mprop1_guess;
   c(end+1) = rocket.stage2.mprop - design_variables.mprop2_guess;

   %Constraint num_engines
   c(end+1) = parameters.min_num_engines - rocket.stage1.nEng;
   c(end+1) = rocket.stage1.nEng - parameters.max_num_engines;

   %Constraint on engine size relative to rocket radius
   c(end+1) = design_variables.stage1.engine_prop{1,8} - design_variables.rocket_ri;
   c(end+1) = design_variables.stage2.engine_prop{1,8} - design_variables.rocket_ri;

   %Calculate the constraint on rf
   c(end+1) = rf_constraint - total_rf;

end