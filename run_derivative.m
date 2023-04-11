clc;clear;
warning('off', 'all');

addpath(genpath(pwd))
warning('OFF', 'MATLAB:table:ModifiedVarnames');
problem.nvars = 3;
%            [ri ,  mprop1, mprop2]
problem.lb = [0.8,   7000,  1000]; 
problem.ub = [4.5,   4e6,   1.5e6];
problem.solver = 'fmincon';
options = optimoptions('fmincon','OutputFcn',@savemilpsolutions,'Display',...
    'iter','Algorithm','sqp', 'MaxFunctionEvaluations', 3000);
problem.options = options;
problem.objective = @run_model_derivative;
problem.x0 = [1.561	1505000	755000 ];%[1.561, 1.0774e6, 1.6552e5];
[x,fval,exitflag,output,lambda,grad,hessian]  = fmincon(problem);
%function false = outfun(x,optimValues,state) %save xvals
%xiter[] = x;
%end

%warning(‘on’, ‘all’)