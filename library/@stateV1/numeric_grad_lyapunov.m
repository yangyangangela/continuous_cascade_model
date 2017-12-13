function [grad_l,err] = numeric_grad_lyapunov(S,x0)


fun = @(x) lyapunov_energy(S,x);
[grad_l,err,~] = gradest(fun,x0);

if err>1e-6
    error('can not estimate the lyapunov gradient');
end

end