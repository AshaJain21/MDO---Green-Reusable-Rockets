function properties = getRocketProperties(C)

properties.F    = C{1};
properties.O    = C{2};
properties.Isp  = C{3};
properties.P    = C{4};
properties.MR   = C{5};
properties.AR   = C{6};
properties.De   = C{7};
properties.Ae   = pi*(properties.De/2)^2;
properties.At   = properties.Ae/properties.AR;

properties.N_F = 1;
if strcmp(properties.F, 'UDMH')
    properties.F = 'C2H8N2bLb_UDMH';
elseif strcmp(properties.F, 'RP-1')
    properties.F = 'RP_1';  
elseif strcmp(properties.F, 'LH2')
    properties.F = 'H2bLb';    
elseif strcmp(properties.F, 'CH4')
    properties.F = 'CH4bLb';  
elseif strcmp(properties.F, 'A-50')
    properties.F = {'C2H8N2bLb_UDMH', 'N2H4bLb'};  
    properties.N_F = [1, 1];
end

properties.N_O = 1;
if strcmp(properties.O, 'LOX')
    properties.O = 'O2bLb';
elseif strcmp(properties.F, 'N2O4')
    properties.O = 'N2O4bLb';  
end


end