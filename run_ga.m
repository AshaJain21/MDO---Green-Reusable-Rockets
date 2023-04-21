clc;clear;
addpath(genpath(pwd))
problem.fitnessfcn = @run_model_ga;
problem.nvars = 9;
%           [# launch,reuse1,reuse2,engine1,engine2,re-entry mat, ri ,  mprop1, mprop2]
problem.lb =[12,       0,      0,      1,      1,         1,      0.8,  7000,    1000]; 
problem.ub =[1500,     1,      1,      16,     16,        11,     4.5,  4e6,     1.5e6];
problem.solver = 'ga';

problem.nonlcon = @calculate_nonpenalty_constraints;
problem.intcon = [1,2,3,4,5,6];

pop_size_opts = [100, 300, 500];
num_trials = 3;
total_trials = length(pop_size_opts) * num_trials;

%Initialize arrays for results
doe_res = zeros(total_trials, (2+problem.nvars+3));
exp_num = 1;
output_full = struct(problemtype='', rngstate=struct(), generations=0, funccount=0, message='', maxconstraint=0, hybridflag=[]);
population_data_full = zeros(1, (problem.nvars+1));


for i = 1:length(pop_size_opts)
    for j = 1:num_trials
        pop_size = pop_size_opts(i);

        options = optimoptions('ga', 'PopulationSize', pop_size, 'UseParallel', true, 'UseVectorized', false, 'PlotFcn',{@gaplotbestf,@gaplotstopping, @gaplotscores, @gaplotrange});%  'MutationFcn', mutation_settings, 'ConstraintTolerance', 1e-1);
        problem.options = options;

        fprintf('======= Current Trial: Population size: %d, Trial: %d ============\n', pop_size, j);

        tstart = tic;
        [x_opt,fval,exitflag,output,population,scores]  = ga(problem);
        comp_time = toc(tstart);

        % Store Values
        doe_res(exp_num, :) = [pop_size, j, x_opt, exitflag, fval, comp_time];
        marker_row = ones(1, (problem.nvars+1))*exp_num;
        population_data_full = [population_data_full; marker_row;[population, scores]];
        output_full = [output_full, output];
        exp_num = exp_num + 1;
    end
end

%Filter any rows with exit val of -2
filtered_doe_res = doe_res(doe_res(:,12)>=0,:);

