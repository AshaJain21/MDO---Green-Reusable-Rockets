clc;clear;
addpath(genpath(pwd))
problem.fitnessfcn = @run_model_ga;
problem.nvars = 9;
problem.lb = [12, 0, 0, 1,1,1,0.8,7000, 1000]; 
problem.ub = [1000, 1, 1, 17,17,11,4.5,4e6, 1.5e6];
problem.solver = 'ga';
options = optimoptions('ga');
problem.options = options;
[xopt,stats,options,bestf,fgen,lgen]  = ga(problem);
