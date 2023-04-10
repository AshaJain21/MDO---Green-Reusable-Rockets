clc;clear;
addpath(genpath(pwd))
warning('OFF', 'MATLAB:table:ModifiedVarnames');
problem.nvars = 3;
%            [ri ,  mprop1, mprop2]
problem.lb = [0.8,   7000,  1000]; 
problem.ub = [4.5,   4e6,   1.5e6];
problem.solver = 'fmincon';
options = optimoptions('fmincon','Display',...
    'iter','Algorithm','sqp', 'MaxFunctionEvaluations', 3000);
problem.options = options;
problem.objective = @run_model_derivative;
problem.x0 = [3.0305	1505000	1500000];%[1.561, 1.0774e6, 1.6552e5];
[x,fval,exitflag,output,lambda,grad,hessian]  = fmincon(problem);