function gphi = grad_lyapunov(S,x0)
% gradient of lyapunov function.

Cij = S.parameters.Cij; % Cij = const1 if the i'th generator connects to j'th bus
Bij = S.parameters.Bij; % Bij~=0 if there is a line connecting bus i to bus j
ng = S.parameters.ng;
nl = S.parameters.nl;
nb = S.parameters.nb;
Pg = S.parameters.Pg;
Pl = S.parameters.Pl;
Mg = S.parameters.Mg;
Tl = S.parameters.Tl;

[w,ga,ba,eita] = unpack_x(S,x0);
ga = [0;ga];%ref angle +bus angle

baseMVA = S.vmpc.baseMVA;


%%
dw = Mg(:).*w(:);

%
dga = zeros(ng-1,1);
for i = 2:ng
    dga(i-1) = sum(Cij(i,:)'.*sin(ga(i)-ba(:)))*baseMVA+Pg(i);
end

%
dba = zeros(nb,1);
% power flow on each branch
FROM_BUS=1;TO_BUS=2;
I = S.vmpc.branch(end-nl+1:end,FROM_BUS)-ng;J = S.vmpc.branch(end-nl+1:end,TO_BUS)-ng;% index of original power network
IND = sub2ind(size(Bij),I,J);
z = Bij(IND).*(1-cos(ba(I)-ba(J))).*baseMVA; % power flow energy on each transmission line

% adjust the Bij according to the status
Bij(IND) = Bij(IND).*eita;
IND2 = sub2ind(size(Bij),J,I);
Bij(IND2) = Bij(IND2).*eita;
b = [zeros(ng,ng) Cij;Cij' Bij];
alpha = [ga(:);ba(:)];% generator angle + bus angle
P = [Pg(:); Pl(:)];% power input,ng+nb

%!!!!!!!!!!!!!!!!!! The following can be turned off, if the P(1) is
%balanced when S is initiated.
P(1) = -sum(P(2:end));% balance power supply and demand using the slack bus

for i = ng+1 : ng+nb
    dba(i-ng) = sum(b(i,:)'.*sin(alpha(i)-alpha(:)))*baseMVA+P(i);
end

%
deita = -Tl.*S.onoff(eita)+z(:);


%%
gphi = [dw;dga;dba;deita];

end
