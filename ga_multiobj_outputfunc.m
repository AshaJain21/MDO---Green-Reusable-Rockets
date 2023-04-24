function [state, options, optchanged] = ga_multiobj_outputfunc(options, state, flag)
    persistent mdo_proj_populations
    optchanged = false;

    if isempty(mdo_proj_populations)
        mdo_proj_populations = state.Population;
    else  
        mdo_proj_populations = [mdo_proj_populations; state.Population];
    end
    assignin('base','mdo_proj_populations',mdo_proj_populations)
end