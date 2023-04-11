clc;clear;
warning('off', 'all');

addpath(genpath(pwd))
warning('OFF', 'MATLAB:table:ModifiedVarnames');
problem.nvars = 3;
%            [ri ,  mprop1, mprop2]
problem.lb = [0.8,   7000,  1000]; 
problem.ub = [4.5,   4e6,   1.5e6];
problem.solver = 'fmincon';
problem.nonlcon = @calculate_nonpenalty_constraints_derivative; %normalized constraints

%options = optimoptions('fmincon','OutputFcn',@savemilpsolutions,'Display',...
%    'iter','Algorithm','sqp', 'MaxFunctionEvaluations', 3000);
%problem.options = options;
%problem.objective = @run_model_derivative;
%problem.x0 = [1.561	1505000	755000 ];%[1.561, 1.0774e6, 1.6552e5];
%[x,fval,exitflag,output,lambda,grad,hessian]  = fmincon(problem);

%numlaunch = [20 45 410 800];
%engine1 = 1:1:15;
%engine2 = 1:1:15;
%reuse1 = [0 1];
%reuse2 = [0 1];
%rematmate = 1:1:9;

ri = [1.561, 3.0305, 4.5];
st1mprop = [1e4, 1505000, 3e6];
st2mprop = [1e4, 755000, 1.5e6];

num_trials = length(ri) * length(st1mprop)*length(st2mprop);
%Initialize arrays for results
doe_results = zeros(num_trials, 7);%(2+problem.nvars+3));
exp_num = 1;
%output_full = struct(problemtype='', rngstate=struct(), generations=0, funccount=0, message='', maxconstraint=0, hybridflag=[]);
%population_data_full = zeros(1, (problem.nvars+1));
%x,fval,exitflag,output,lambda,grad,hessian

for i = 1:length(ri)
    for j = 1:length(st1mprop)
        for k = 1:length(st2mprop)
            ri_trial = ri(i);
            prop1 = st1mprop(j);
            prop2 = st2mprop(k);
            %mutation_settings = {@mutationuniform, mutation_rate};

            %options = optimoptions('ga', 'PopulationSize', pop_size, 'MutationFcn', mutation_settings);
            options = optimoptions('fmincon','OutputFcn',@savemilpsolutions,'Display',...
                         'iter','Algorithm','sqp', 'MaxFunctionEvaluations', 3000);
            problem.options = options;
            problem.objective = @run_model_derivative;
            fprintf('Rocket Inner Radius: %f, St1 Prop Mass: %f, St2 Prop Mass: %f \n', ri_trial, prop1, prop2);
            
            problem.x0 = [ri_trial	prop1 prop2 ];%[1.561, 1.0774e6, 1.6552e5];
            [x,fval,exitflag,output,lambda,grad,hessian]  = fmincon(problem);

            % Store Values
            doe_results(exp_num, :) = [x,fval,exitflag,output,lambda,grad,hessian];
            %marker_row = ones(1, (problem.nvars+1))*exp_num;
            %population_data_full = [population_data_full; marker_row;[population, scores]];
            %output_full = [output_full, output];
            exp_num = exp_num + 1;
        
        end
    end
end

%warning(‘on’, ‘all’)