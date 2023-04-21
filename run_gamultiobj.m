clc;clear;
addpath(genpath(pwd))
problem.fitnessfcn = @run_model_gamutliobj;
problem.nvars = 9;
%           [# launch,reuse1,reuse2,engine1,engine2,re-entry mat, ri ,  mprop1, mprop2]
problem.lb =[12,       0,      0,      1,      1,         1,      0.8,  7000,    1000]; 
problem.ub =[750,     1,      1,      16,     16,        11,     4.5,  4e6,     1.5e6];
problem.solver = 'gamultiobj';

problem.nonlcon = @calculate_nonpenalty_constraints;
problem.intcon = [1,2,3,4,5,6];

pop_size_opts = [100, 300, 500];%[50, 75, 100];
num_trials = 1;
total_trials = length(pop_size_opts) * num_trials;

doe_res = [];

%Initialize arrays for results
% doe_res = zeros(total_trials, (2+problem.nvars+3));
exp_num = 1;

for i = 1:length(pop_size_opts)
    for j = 1:num_trials
        pop_size = pop_size_opts(i);

        options = optimoptions('gamultiobj', 'PopulationSize', pop_size, 'UseParallel', true, 'UseVectorized', false, 'PlotFcn',{@gaplotstopping, @gaplotscores});%  'MutationFcn', mutation_settings, 'ConstraintTolerance', 1e-1);
        problem.options = options;

        fprintf('======= Current Trial: Population size: %d, Trial: %d ============\n', pop_size, j);

        tstart = tic;
        [x_opt,fval,exitflag,output,population,scores]  = gamultiobj(problem);
        comp_time = toc(tstart);

        % Store Values
        doe_res = [doe_res, struct(x_opt=x_opt, fval = fval, exitflag=exitflag, output=output, population=population, scores=scores)];
        exp_num = exp_num + 1;
    end
end

