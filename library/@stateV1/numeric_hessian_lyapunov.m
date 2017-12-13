function H = numeric_hessian_lyapunov(S,x0)

fun = @(x) lyapunov_energy(S,x);

[H,err] = hessian(fun,x0);

if err>1e-6
    error('can not estimate the Hessian gradient');
end

end