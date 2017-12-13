function t = onoff(g)

% Normalized status function:
% The status of a component is represented by a continous variable g, ranging
% from zero to one. Before simulation, we indicate the threshold g_c below which g will be driven to 
% a region close to zero. At the region near one, the local maximum of
% onoff(g) is one, that is onoff(g_star)=1. 
% Version: 2015-07

t = 1./(10.*g)-1./(10.*(1-g))+10.*g.^4-5.2627;

end