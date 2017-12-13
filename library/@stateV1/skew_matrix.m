function M = skew_matrix(S)
% M =[ -Dg./Mg^2  A    B     0;
%       -A'     0    0     0;
%       -B'     0  -1./Dl  0;
%       0       0    0     -I];
% jacobian_f(S,x) = M(S)*hessian_lyapunov(S,x)

ng = S.parameters.ng;
nl = S.parameters.nl;
nb = S.parameters.nb;

Mg = S.parameters.Mg;
Dg = S.parameters.Dg;
Dl = S.parameters.Dl;

A = [ones(1,ng-1)./Mg(1);...
    -diag(1./Mg(2:end))];

B = [ones(1,nb)./Mg(1);...
    zeros(ng-1,nb)];

M = [-diag(Dg./Mg./Mg) A B zeros(ng,nl);...
    -A' zeros(ng-1,ng-1) zeros(ng-1,nb) zeros(ng-1,nl);...
    -B' zeros(nb,ng-1) -diag(1./Dl) zeros(nb,nl);...
    zeros(nl,ng) zeros(nl,ng-1) zeros(nl,nb) -eye(nl)];

end
    