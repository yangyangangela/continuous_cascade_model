function E = onoff_energy(g)
% Normalized status energy function:
% The status of a component is represented by a continous variable g, ranging
% from zero to one. Before simulation, we indicate the threshold g_c below which g will be driven to 
% a region close to zero. 

% see lyapunov_energy also
% Version: 2016-03

E = -1/10.*log(g)-1/10.*log(1-g)-2*g.^5+5.2627.*g;
%E  = 2.*log(1-g)+x.*log(1./x-1)-40g.^3;
% %% set up parameters
% b = 20;
% a1  = 10;
% a2 = a1 * b;
% 
% %%
% % g=g_star, theta takes the maximum
% g_star =1 - log(a2/a1)/(a2-a1);
% 
% % assume g<g_c as on;
% g_c = 0.9;
% 
% %
% E = 1/theta_2(g_star)*(F_g(a1,g)-F_g(a2,g)+theta_1(g_c)*g);
% E = E(:);
% %%
%     function tt = f_g(alpha,gamma)
%         % the basic construction function of theta(g)
%         tt = -exp(-alpha * gamma) + exp(alpha * (gamma - 1));
%     end
% 
%     function tt = F_g(alpha,gamma)
%         %dF(alpha,gamma)/dalpha = -f_g(alpha,gamma)
%         tt = -1/alpha*(exp(-alpha * gamma) + exp(alpha * (gamma - 1)));
%     end    
% 
%     function tt = theta_1(g)
%         tt = f_g(a1,g) - f_g(a2,g);
%     end
% 
%     function tt = theta_2(g)
%         tt = theta_1(g) - theta_1(g_c);
%     end


end