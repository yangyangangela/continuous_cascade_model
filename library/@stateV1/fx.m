function  dxdt = fx(S,t,x) % dynamic function
%%
% dxdt=fx(State,time,x)

%%
%[nb,ng,nl,Bij,Cij,Pg,Pl,Dg,Dl,Mg,Tl] = unpack_parameters(S);
nb = S.parameters.nb;
ng = S.parameters.ng;
nl = S.parameters.nl;
Bij = S.parameters.Bij;
Cij = S.parameters.Cij;
Pg = S.parameters.Pg(:);
Pl = S.parameters.Pl(:);
Dg = S.parameters.Dg(:);
Dl = S.parameters.Dl(:);
Mg = S.parameters.Mg(:);
Tl = S.parameters.Tl(:);

%[w,ga,ba,eita] = unpack_x(x,S);
w = x(1:ng);w =w(:);% generator frequency
ga = x(ng+1:2*ng-1);ga=ga(:);% generator angle 1-by-(ng-1)
ba = x(2*ng:2*ng+nb-1);ba=ba(:);% bus angle 1-by-nb
eita = x(2*ng+nb:2*ng+nb+nl-1);eita=eita(:);% branch status

%%
baseMVA = S.vmpc.baseMVA;

% power flow on each branch
FROM_BUS=1;TO_BUS=2;
I = S.vmpc.branch(end-nl+1:end,FROM_BUS)-ng;J = S.vmpc.branch(end-nl+1:end,TO_BUS)-ng;% index of original power network
IND = sub2ind(size(Bij),I,J);
%z = Bij(IND).*(1-cos(ba(I)-ba(J))); % power flow energy on each transmission line
z = Bij(IND).*(1-cos(ba(I)-ba(J))).*baseMVA; % power flow energy on each transmission line

% adjust the Bij according to the status
Bij(IND) = Bij(IND).*eita;
IND2 = sub2ind(size(Bij),J,I);
Bij(IND2) = Bij(IND2).*eita;
b = [zeros(ng,ng) Cij;Cij' Bij];
alpha = [0; ga(:);ba(:)];%ref angle + generator angle + bus angle
P = [Pg(:); Pl(:)];% power input,ng+nb

%!!!!!!!!The following can be turned off if P(1) has been balanced when S
%is initiated.
%P(1) = -sum(P(2:end)); % balance power supply and demand using the slack

% complementary variables
y = zeros(ng+nb,1);%netpower withdraw at each node
for i = 1 : ng+nb
    y(i) = sum(b(i,:)'.*sin(alpha(i)-alpha(:)))*baseMVA+P(i);
    %y(i) = sum(b(i,:)'.*sin(alpha(i)-alpha(:)))+P(i);
end

%
dwdt = -(Dg.*w+y(1:ng))./Mg;
dgadt = w(2:ng) - w(1);
dbadt = -y(ng+1:ng+nb)./Dl-w(1);
%deitadt = Tl.*S.onoff(eita)-z;
deitadt = 10*(S.onoff(eita)-z./Tl);
dxdt = [dwdt;dgadt;dbadt;deitadt];

end