% TO DO
% 1) figure out which engines are staged (hot T) and which are not (cold T) 

function [thrust, ue, mdot, products] = combustion_mod(rocketProp)
%% Get Combustion Products
    % INITIALIZE FINITE-AREA-CHAMBER --------------------------------------
    self = App('HC/O2/N2 PROPELLANTS');

    % SET CONDITIONS ------------------------------------------------------
    self = set_prop(self, 'TR', 90, 'pR', rocketProp.P,'phi',rocketProp.MR);
    self.PD.S_Fuel     = {rocketProp.F};
    self.PD.N_Fuel     = rocketProp.N_F;
    self.PD.S_Oxidizer = {rocketProp.O};
    self.PD.FLAG_IAC   = true;
    self = set_prop(self, 'Aratio', rocketProp.AR);
    
    % SOLVE PROBLEM -------------------------------------------------------
    self = solve_problem(self, 'ROCKET');
    [mass_fraction, ind_sort] = sort(self.PS.mix2_c{1, 1}.Xi, 'descend');
    major = mass_fraction > 1.0e-14; % constant of what is negligible product
    minor  = sum(mass_fraction(~major));
    Nminor = length(mass_fraction) - sum(major);
    products.name = self.S.LS(ind_sort(major))';
    products.massFraction = mass_fraction(major);

    if sum(mass_fraction) ~= 1
        disp('mass fraction error')
    end
       
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