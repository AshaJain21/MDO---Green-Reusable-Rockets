clc;clear;
addpath(genpath(pwd))
problem.fitnessfcn = @run_model_ga;
problem.nvars = 9;
%           [# launch,reuse1,reuse2,engine1,engine2,re-entry mat, ri ,  mprop1, mprop2]
problem.lb =[12,       0,      0,      1,      1,         1,      0.8,  7000,    1000]; 
problem.ub =[1000,     1,      1,      15,     15,        11,     4.5,  4e6,     1.5e6];
problem.solver = 'ga';

pop_size_opts = linspace(100, 500, 5);
% max_gen_opts = linspace(100, 900, 5);
mutation_rate_opts = [0.01, 0.1, 0.2, 0.3, 0.4];

pop_size = 200; %default is 50 when less than 5 design variables and 200 when more than 5 design variables
max_gen = problem.nvars * 100; %This is the same calculation as default value
mutation_settings = {@mutationuniform, 0.1}; %default for uniform is 0.01
%mutation_settings = {@mutationgaussian, 1, 1}; %for gaussian, first parameter is scale, second parameter is shrink


options = optimoptions('ga');%, 'PopulationSize', pop_size, 'MaxGenerations', max_gen, 'MutationFcn', mutation_settings);
problem.options = options;
[x,fval,exitflag,output,population,scores]  = ga(problem);
