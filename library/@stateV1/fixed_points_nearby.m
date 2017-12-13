function x_star = fixed_points_nearby(S,x0)
% find the nearest fixed points starting from x0
% f_x = @(x) S.fx(0,x);
% [x_star,~]=fsolve(f_x,x0);

% another way is to find the grad_lyapunov=0
f_x = @(x) S.grad_lyapunov(x);
[x_star,~]=fsolve(f_x,x0);
end