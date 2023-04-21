clc;clear;
addpath(genpath(pwd))
delete rocket_results_ga.mat
problem.fitnessfcn = @run_model_gamutliobj;
problem.nvars = 9;
%           [# launch,reuse1,reuse2,engine1,engine2,re-entry mat, ri ,  mprop1, mprop2]
problem.lb =[12,       0,      0,      1,      1,         1,      0.8,  7000,    1000]; 
problem.ub =[1500,     1,      1,      16,     16,        11,     4.5,  4e6,     1.5e6];
problem.solver = 'gamultiobj';

problem.nonlcon = @calculate_nonpenalty_constraints;
problem.intcon = [1,2,3,4,5,6];

pop_size_opts = [50, 75, 100];
num_trials = 1;
total_trials = length(pop_size_opts) * num_trials;

doe_res = [];

%Initialize arrays for results
% doe_res = zeros(total_trials, (2+problem.nvars+3));
exp_num = 1;
output_full = struct(problemtype='', rngstate=struct(), generations=0, funccount=0, message='', maxconstraint=0, hybridflag=[]);
population_data_full = zeros(1, (problem.nvars+1));


for i = 1:length(pop_size_opts)
    for j = 1:num_trials
        pop_size = pop_size_opts(i);

        options = optimoptions('gamultiobj', 'PopulationSize', pop_size, 'UseParallel', true, 'UseVectorized', false, 'PlotFcn',{@gaplotbestf,@gaplotstopping, @gaplotscores, @gaplotrange});%  'MutationFcn', mutation_settings, 'ConstraintTolerance', 1e-1);
        problem.options = options;

        fprintf('======= Current Trial: Population size: %d, Trial: %d ============\n', pop_size, j);

        tstart = tic;
        [x_opt,fval,exitflag,output,population,scores]  = gamultiobj(problem);
        comp_time = toc(tstart);

        % Store Values
        doe_res(end+1) = struct(x_opt=x_opt, fval = fval, exitflag=exitflag, output=output, population=population, scores=scores);
        exp_num = exp_num + 1;
    end
end

