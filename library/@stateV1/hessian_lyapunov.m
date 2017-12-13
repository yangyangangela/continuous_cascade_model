function H = hessian_lyapunov(S,x0)
% H = jacobian(grad(lyapunov_energy))
% H = [ M 0     0   0;
%       0 Beta  K   0;
%       0 K'    F   G;
%       0 0     G'  Eta; ]

Cij = S.parameters.Cij; % Cij = const1 if the i'th generator connects to j'th bus
Bij = S.parameters.Bij; % Bij~=0 if there is a line connecting bus i to bus j
ng = S.parameters.ng;
nl = S.parameters.nl;
nb = S.parameters.nb;

Mg = S.parameters.Mg;
Tl = S.parameters.Tl;

[~,ga,ba,eita] = unpack_x(S,x0);
ga = [0;ga];

baseMVA = S.vmpc.baseMVA;



%%
M = diag(Mg);% ng-by-ng

%
beta = zeros(1,ng-1);
for i = 1:ng
    beta(i) = sum(Cij(i,:)'.*cos(ga(i)-ba))*baseMVA;
end
Beta = diag(beta(2:ng));

% K has the same structure as Cij without the first row
K = zeros(size(Cij));
[i1,i2] = find(Cij);
for c = 1 : ng
    i = i1(c); j = i2(c);
    K(i,j) = -Cij(i,j)*cos(ga(i)-ba(j))*baseMVA;
end
K(1,:) = [];

%
F = zeros(size(Bij));
% power flow on each branch
FROM_BUS=1;TO_BUS=2;
I = S.vmpc.branch(end-nl+1:end,FROM_BUS)-ng;J = S.vmpc.branch(end-nl+1:end,TO_BUS)-ng;% index of original power network
IND = sub2ind(size(Bij),I,J);
F(IND) = -Bij(IND).*cos(ba(I)-ba(J)).*eita.*baseMVA; % power flow term on each transmission line
IND2 = sub2ind(size(Bij),J,I);
F(IND2) = -Bij(IND2).*cos(ba(J)-ba(I)).*eita.*baseMVA; % power flow term on each transmission line
for i = 1 : nb
    F(i,i) = -sum(F(i,:))+sum(beta(find(Cij(:,i))));
end


%
G = zeros(nb,nl);
for l = 1:nl
    i = I(l);j = J(l);
    G(i,l) = Bij(i,j)*sin(ba(i)-ba(j))*baseMVA;
    G(j,l) = Bij(i,j)*sin(ba(j)-ba(i))*baseMVA;
end


%
fun = @(x) S.onoff(x);
Eta = zeros(nl,nl);
for l = 1 :length(eita)
    [grad_eta,~,~] = gradest(fun,eita(l));
    Eta(l,l) = -grad_eta*Tl(l);
end


H = [M zeros(ng,ng-1) zeros(ng,nb) zeros(ng,nl);
    zeros(ng-1,ng) Beta K zeros(ng-1,nl);
    zeros(nb,ng) K' F G;
    zeros(nl,ng) zeros(nl,ng-1) G' Eta];

return