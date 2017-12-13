function [T,X] = solve_dynamic(S,tf)
tspan = linspace(0,tf,100);
x0 = S.x;
[T,X] = ode15s(@(t,x) fx(S,t,x), tspan, x0);
end