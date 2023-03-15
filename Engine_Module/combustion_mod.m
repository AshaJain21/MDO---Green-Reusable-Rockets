% TO DO
% 1) figure out which engines are staged (hot T) and which are not (cold T) 

function [thrust, ue, mdot, self] = combustion_mod(rocketProp)
%% Get Combustion Products
    % INITIALIZE FINITE-AREA-CHAMBER --------------------------------------
    self = App('HC/O2/N2 PROPELLANTS');

    % SET CONDITIONS ------------------------------------------------------
    self = set_prop(self, 'TR', 90, 'pR', rocketProp.P,'phi',rocketProp.MR);
    self.PD.S_Fuel     = {rocketProp.F};
    self.PD.N_Fuel = rocketProp.N_F;
    self.PD.S_Oxidizer = {rocketProp.O};
    self.PD.FLAG_IAC   = true;
    self = set_prop(self, 'Aratio', rocketProp.AR);
    
    % SOLVE PROBLEM -------------------------------------------------------
    self = solve_problem(self, 'ROCKET');
       
%% Solve for Outputs
    gamma = self.PS.mix2_c{1, 1}.gamma;
    T_c = self.PS.mix2_c{1, 1}.T;
    R = 8.314;
%     altitude = 0:500:75000;
    exponent = -(gamma + 1)/2/(gamma - 1);
    mdot = rocketProp.P*rocketProp.At/sqrt(T_c)*sqrt(gamma/R)*(1 + (gamma - 1)/2)^exponent;
    
    thrust = mdot*9.81*rocketProp.Isp;
    
    ue = thrust/mdot;

end