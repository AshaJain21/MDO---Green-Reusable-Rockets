clc;clear;
warning('off', 'all');
addpath(genpath(pwd))
warning('OFF', 'MATLAB:table:ModifiedVarnames');
delete 'rocket_results.mat'; %ONLY if we dont have one
delete 'nonlcon_results.mat'
problem.nvars = 3;
%            [ri ,  mprop1, mprop2]
problem.lb = [0.8,   7000,  1000]; 
problem.ub = [4.5,   4e6,   1.5e6];
problem.solver = 'fmincon';
problem.nonlcon = @calculate_nonpenalty_constraints_derivative; %normalized constraints

options = optimoptions('fmincon','OutputFcn',@savemilpsolutions,'Display',...
    'iter','Algorithm','sqp', 'MaxFunctionEvaluations', 3000, ...
    'ConstraintTolerance', 1e-1);
problem.options = options;
problem.objective = @run_model_derivative;
problem.x0 = [4.0, 6.3813e5, 2.5879e5];%[1.561, 1.0774e6, 1.6552e5];
[x,fval,exitflag,output,lambda,grad,hessian]  = fmincon(problem);


%% From hessian get scaling factors
  hessian =[14967575.1759008,6461.46021645655,-66601.0093060988;
      6461.46021645655,3.03878431187838,-29.4119429240569;
  -66601.0093060988,-29.4119429240569,298.102748320664];
[U,S,V] = svd(hessian);
condition = max(diag(S))/min(diag(S));
scaling_exp = floor(log10(diag(S))); %%%%% SET TO 0 IF NOT APLLYING SCALING 
global scaling_vec
scaling_vec = 10.^scaling_exp; %%% 
%hessian scaling factor
%% Rescale
global scaling_vec
warning('off', 'all');
addpath(genpath(pwd))
warning('OFF', 'MATLAB:table:ModifiedVarnames');
delete 'rocket_results.mat'; %ONLY if we dont have one
delete 'nonlcon_results.mat'
problem.nvars = 3;
%            [ri ,  mprop1, mprop2]
problem.lb = [0.8*scaling_vec(1),   7000*scaling_vec(2),  1000*scaling_vec(3)];%[]; 
problem.ub = [4.5*scaling_vec(1),   4e6*scaling_vec(2),   1.5e6*scaling_vec(3)];%[];
problem.solver = 'fmincon';
problem.nonlcon = @rescaled_nonpenalty_constraints_derivative; %normalized constraints

options = optimoptions('fmincon','OutputFcn',@savemilpsolutions,'Display',...
    'iter','Algorithm','sqp', 'MaxFunctionEvaluations', 3000, ...
    'ConstraintTolerance', 1e-1);
problem.options = options;
problem.objective = @run_model_derivative_scaled;
problem.x0 = [4.4663*scaling_vec(1), 6.3813e5*scaling_vec(2), 2.5879e5*scaling_vec(3)];%[1.561, 1.0774e6, 1.6552e5];
[x,fval,exitflag,output,lambda,grad,hessian]  = fmincon(problem);

%[4.4663, 6.3813e5,2.5879e6]
%[2.15*scaling_vec(1), 2.8505e4*scaling_vec(2), 2.1957e4*scaling_vec(3)];
%% 
clc;clear;
warning('off', 'all');
addpath(genpath(pwd))
ri = [1.00, 1.561,2.0, 2.5, 3.0305,4.0, 4.5];% 3.0305, 4.5];
st1mprop = [1e4,5e4, 1e5,5e5,1e6,1505000,3e6];% 1505000, 3e6];
st2mprop = [1e4,5e4,1e5,755000,1e6,1.5e6];%755000, 1.5e6];
problem.nvars =3;
num_trials = length(ri) * length(st1mprop)*length(st2mprop);
%Initialize arrays for results
doe_results = zeros(num_trials, 5);%(2+problem.nvars+3));
%doe_flag = zeros(num_trials, 7);%(2+problem.nvars+3));
exp_num = 1;
output_full = struct(iterations=0, funcCount=0, algorithm = '', message='',...
    constrviolation=0, stepsize=0, lssteplength=0, firstorderopt=0,bestfeasible=[]);
grad_data = zeros(3, (num_trials));
lamb_data =struct(eqlin=[], eqnonlin=[], ineqlin=[], ineqnonlin=[], lower=[], upper=[]);%zeros(1, (problem.nvars+1));
hess_data = zeros(3, (problem.nvars*num_trials));
%x,fval,exitflag,output,lambda,grad,hessian

for i = 1:length(ri)
    for j = 1:length(st1mprop)
        for k = 1:length(st2mprop)
            ri_trial = ri(i);
            prop1 = st1mprop(j);
            prop2 = st2mprop(k);
            %mutation_settings = {@mutationuniform, mutation_rate};
            %problem.nvars = 3;
%            [ri ,  mprop1, mprop2]
            problem.lb = [0.8,   7000,  1000]; 
            problem.ub = [4.5,   4e6,   1.5e6];
            problem.solver = 'fmincon';
            problem.nonlcon = @calculate_nonpenalty_constraints_derivative; %normalized constraints

            %options = optimoptions('ga', 'PopulationSize', pop_size, 'MutationFcn', mutation_settings);
            options = optimoptions('fmincon','OutputFcn',@savemilpsolutions,'Display',...
                         'iter','Algorithm','sqp', 'MaxFunctionEvaluations', 3000, 'ConstraintTolerance', 1e-1);
            problem.options = options;
            problem.objective = @run_model_derivative;
            fprintf('Rocket Inner Radius: %f, St1 Prop Mass: %f, St2 Prop Mass: %f \n', ri_trial, prop1, prop2);
            
            problem.x0 = [ri_trial	prop1 prop2 ];%[1.561, 1.0774e6, 1.6552e5];
            [x,fval,exitflag,output,lambda,grad,hessian]  = fmincon(problem);

            %[x_opt,fval,exitflag,output,population,scores] 
            %[pop_size, mutation_rate, x_opt, exitflag, fval, comp_time];
            % Store Values
            doe_results(exp_num, :) = [x, fval, exitflag];%,output,lambda,grad,hessian];
            %doe_flag(exp_num, :) = [fval,exitflag];
            marker_row = ones(1, (problem.nvars+1))*exp_num;
            %gradhess_data = [lambda,grad,hessian]; %marker_row;[population, scores]];
            output_full = [output_full, output];
            grad_data(:,exp_num) =grad; 
            lamb_data = [lamb_data, lambda];
            hess_data(:,i:i+2) = hessian;
            exp_num = exp_num + 1;
        
        end
    end
end

%warning(‘on’, ‘all’)