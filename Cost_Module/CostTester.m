clear
addpath(genpath(pwd))

load('doe_exp5_vars.mat')

total_cost = run_cost_module(design_variables, parameters, rocket, launch_cadence);


%Reference numbers for output validation:
% 1. https://www.nasa.gov/pdf/586023main_8-3-11_NAFCOM.pdf shows that NASA
% estimated between $1.7B and $4B in development cost initially. Spacex's
% unconventional development methods and the our model not accounting for
% different types of pricing contracts might account for differences
% between our numbers and that presentation 