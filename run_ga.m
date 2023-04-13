clc;clear;
addpath(genpath(pwd))
delete rocket_results_ga.mat
problem.fitnessfcn = @run_model_ga;
problem.nvars = 9;
%           [# launch,reuse1,reuse2,engine1,engine2,re-entry mat, ri ,  mprop1, mprop2]
problem.lb =[12,       0,      0,      1,      1,         1,      0.8,  7000,    1000]; 
problem.ub =[1500,     1,      1,      15,     15,        11,     4.5,  4e6,     1.5e6];
problem.solver = 'ga';

problem.nonlcon = @calculate_nonpenalty_constraints;

pop_size_opts = [50];%, 100, 300];
mutation_rate_opts = [0.01];%, 0.05, 0.1];

% pop_size = 200; %default is 50 when less than 5 design variables and 200 when more than 5 design variables
% max_gen = problem.nvars * 100; %This is the same calculation as default value
% mutation_settings = {@mutationuniform, 0.1}; %default for uniform is 0.01
%mutation_settings = {@mutationgaussian, 1, 1}; %for gaussian, first parameter is scale, second parameter is shrink

num_trials = length(pop_size_opts) * length(mutation_rate_opts);

%Initialize arrays for results
doe_res = zeros(num_trials, (2+problem.nvars+3));
exp_num = 1;
output_full = struct(problemtype='', rngstate=struct(), generations=0, funccount=0, message='', maxconstraint=0, hybridflag=[]);
population_data_full = zeros(1, (problem.nvars+1));


for i = 1:length(pop_size_opts)
    for j = 1:length(mutation_rate_opts)
        pop_size = pop_size_opts(i);
        mutation_rate = mutation_rate_opts(j);
        mutation_settings = {@mutationuniform, mutation_rate};

        options = optimoptions('ga');%, 'PopulationSize', pop_size, 'MutationFcn', mutation_settings, 'ConstraintTolerance', 1e-1);
        problem.options = options;

        fprintf('======= Current Trial: Population size: %d, Mutation rate: %d ============\n', pop_size, mutation_rate);

        tstart = tic;
        [x_opt,fval,exitflag,output,population,scores]  = ga(problem);
        comp_time = toc(tstart);

        % Store Values
        doe_res(exp_num, :) = [pop_size, mutation_rate, x_opt, exitflag, fval, comp_time];
        marker_row = ones(1, (problem.nvars+1))*exp_num;
        population_data_full = [population_data_full; marker_row;[population, scores]];
        output_full = [output_full, output];
        exp_num = exp_num + 1;
%         end
    end
end

