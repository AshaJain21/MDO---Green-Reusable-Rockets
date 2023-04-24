function [state, options, optchanged] = ga_multiobj_outputfunc(options, state, flag)
    persistent mdo_proj_populations
    optchanged = false;

    raw_pop_data = [state.Population, state.Score, state.isFeas];

    filtered_population_data = raw_pop_data(raw_pop_data(:,end)==1, :);

    if isempty(mdo_proj_populations)
        mdo_proj_populations = filtered_population_data;
    else  
        mdo_proj_populations = [mdo_proj_populations; filtered_population_data];
    end
    assignin('base','mdo_proj_populations',mdo_proj_populations)
end