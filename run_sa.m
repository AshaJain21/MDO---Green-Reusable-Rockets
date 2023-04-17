clear;clc;

addpath(genpath(pwd))
warning('OFF', 'MATLAB:table:ModifiedVarnames');

%           [# launch,reuse1,reuse2,engine1,engine2,re-entry mat, ri ,  mprop1, mprop2]
problem.lb =[12,       0,      0,      1,      1,         1,      0.8,  7000,    1000]; 
problem.ub =[1500,     1,      1,      15,     15,        11,     4.5,  10e6,     5e6];
problem.x0 = [300, 1,1, 10, 11, 2, 3, 3.5e6, 1.2e6];
problem.solver = 'simulannealbnd';

options = optimoptions(@simulannealbnd,'MaxIterations',1000);
problem.options = options;

problem.objective = @run_model_sa;

[x,fval,exitflag,output] = simulannealbnd(problem);