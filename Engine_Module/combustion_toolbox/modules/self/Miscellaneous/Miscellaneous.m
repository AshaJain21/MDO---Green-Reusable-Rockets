function self = Miscellaneous()
    % Initialize struct with miscellaneous data
    % 
    % Returns:
    %     self (struct): struct with miscellaneous data
    
    % Description
    self.description = 'Miscellaneous'; 
    % Variables
    % * Timer
    self.timer_0 = [];
    self.timer_loop = [];
    % * Plot
    self.config.position = get_monitor_positions(2); % Default figure position [pixels]
    self.config.innerposition = [0.05 0.05 0.9 0.9]; % Set figure inner position [normalized]
    self.config.outerposition = [0.05 0.05 0.9 0.9]; % Set figure outer position [normalized]
    self.config.linestyle = '-';                     % Set line style for plots
    self.config.symbolstyle = 'o';                   % Set symbol style for plots
    self.config.linewidth = 1.8;                     % Set line width for plots
    self.config.fontsize = 20;                       % Set fontsize
    self.config.colorpalette = 'Seaborn';            % Set Color palette (see brewermap function for more options)
    self.config.colorpaletteLenght = 11;             % Set Maximum number of colors to use in the color palette
    self.config.box = 'off';                         % Display axes outline
    self.config.grid = 'off';                        % Display or hide axes grid lines
    self.config.hold = 'on';                         % Retain current plot when adding new plots
    self.config.axis_x = 'auto';                     % Set x-axis limits
    self.config.axis_y = 'auto';                     % Set y-axis limits
    self.config.xscale = 'linear';                   % Set x-axis scale (linear or logarithmic)
    self.config.yscale = 'linear';                   % Set y-axis scale (linear or logarithmic)
    self.config.xdir = 'normal';                     % Set x-axis direction (normal or reverse)
    self.config.ydir = 'normal';                     % Set y-axis direction (normal or reverse)
    self.config.title = [];                          % Set title
    self.config.label_type = 'medium';               % Set label with variable (short), name (medium), or name and variable (long)
    self.config.labelx = [];                         % Set x label
    self.config.labely = [];                         % Set y label
    self.config.legend_name = [];                    % Set legend labels
    self.config.legend_location = 'northeastoutside';% Set legend location
    self.config.colorline = [44, 137, 160]/255;      % Default colorline
    self.config.colorlines = [135, 205, 222;...      % Default colorlines
                               95, 188, 211;...      % Default colorlines
                               44, 137, 160;...      % Default colorlines
                               22,  68,  80]/255;    % Default colorlines
    self.config.blue = [0.3725, 0.7373, 0.8275];     % Default colorline
    self.config.gray = [0.50, 0.50, 0.50];           % Default colorline
    self.config.red = [0.64,0.08,0.18];              % Default colorline
    self.config.orange = [212, 85, 0]/255;           % Default colorline
    self.config.brown = [200, 190, 183]/255;         % Default colorline
    self.config.brown2 = [72, 55, 55]/255;           % Default colorline
    % * Flags
    self.FLAG_FIRST = true;                          % Flag indicating first calculation
    self.FLAG_FOI = true;                            % Flag indicating that the computations of the reactant mixture ....
    self.FLAG_ADDED_SPECIES = false;                 % Flag indicating that there are added reactants species, because were not considered as products -> to recompute stochiometric matrix
    self.FLAG_N_Fuel = true;                         % Flag indicating that the number of moles of the fuel species are defined
    self.FLAG_N_Oxidizer = true;                     % Flag indicating that the number of moles of the oxidant species are defined
    self.FLAG_N_Inert = true;                        % Flag indicating that the number of moles of the inert species are defined
    self.FLAG_WEIGHT = false;                        % Flag indicating that the number of moles of the oxidizer/inert speces are defined from its weight percentage
    self.FLAG_RESULTS = true;                        % Flag to show results in the command window
    self.FLAG_CHECK_INPUTS = false;                  % Flag indicating that the algorithm has checked the input variables
    self.FLAG_GUI = false;                           % Flag indicating that the user is using the GUI
    self.FLAG_LABELS = false;                        % Flag ...
    self.FLAG_PROP = [];                             % Struct with flags indicanting if there are several values of the respective property (fieldname)
    self.FLAGS_PROP.TR = false;                      % Flag several values of Temperature Reactant (TR)
    self.FLAG_LENGTH_LOOP = false;                   % Flag for several computations
    % * Export data
    self.export_results.value = false;               % Bool variable to export results
    self.export_results.format = '.xls';             % Default fileformat to export results
    self.export_results.filename = 'results';        % Default filename to export results
    % * Others
    self.index_LS_original = [];                     % Indexes original list of products
    self.display_species = {};                       % Species to plot on the molar/mass fraction plots
    self.i = [];                                     % Index of the current computations
end