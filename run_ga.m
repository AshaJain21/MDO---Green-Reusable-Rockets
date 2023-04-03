clc;clear;
addpath(genpath(pwd))
problem.fitnessfcn = @run_model_ga;
problem.nvars = 9;
problem.lb = [1, 0, 0, 1,1,1,0.5,7000, 1000];
problem.up = [1000, 1, 1, 17,17,11,5,4e6, 1.5e6];
problem.solver = 'ga';
options = optimoptions('ga');
problem.options = options;
[xopt,stats,options,bestf,fgen,lgen]  = ga(problem);