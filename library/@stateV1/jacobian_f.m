function J = jacobian_f(S,x)

J = S.skew_matrix() * hessian_lyapunov(S,x);

end