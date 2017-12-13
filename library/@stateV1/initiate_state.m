function  [x, parameters, vmpc] = initiate_state(mpc)
% Generate the initial state x, the structural parameters that will used for further
% calculations, and the virtual mpc which incorperates the generators as
% new buses.
%
% x=[omega, generator_alpha, bus_alpha, eita], the dimension of this vector
% is [1-by-ng, 1-by-(ng-1), 1-by-nb, 1-by-nl], where ng=#generators,
% nb=#buses, and nl=#branches
%
% parameters.ng: scalar, #generators
% parameters.nb: scalar, #buses
% parameters.nl: scalar, #branches
% parameters.Bij: Bij = bij is the total charging susceptance of branch(i-j)
% parameters.Cij: Cij = const1 if the i'th generator connects to j'th bus
% parameters.Pg: vector, power generation at i'th generator, Pg_i<0
% parameters.Pl: vector, power customered at i'th bus, Pl_i>0
% parameters.Dg: vector, damping ratio of generators
% parameters.Dl: vector, oscillating ratio of load buses
% parameters.Mg: vector, generator inertia =2H/(2*pi*60hz)
% parameters.Tl: vector, branch capacity
%
% vmpc: struct, virtual mpc
% vmpc.bus: following mpc.bus, the last ng rows are the virtual buses of generators
% vmpc.gen: following mpc.gen, each generator is connected to the virtual bus
% vmpc.branch: the last ng branches are the virtual branches
%% constant on dynamical data, note these data can be changed by change_parameter function
CONST1 = .00001;% the reactance X of virtual lines (in p.u. with baseMVA)
CONST2 = 5;% damping ratio of Dg
CONST3 = 1;% oscillating ratio of load buses Dl
CONST4 =5; % generator inertia Mg

%%

%
% index of bus
BUS_I=1;BUS_TYPE=2;PD=3;QD=4;GS=5;BS=6;BUS_AREA=7;VM=8;VA=9;BASE_KV=10;
ZONE=11;VMAX=12;VMIN=13;
% index of generator
GEN_BUS=1;PG=2;QG=3;QMAX=4;QMIN=5;VG=6;MBASE=7;GEN_STATUS=8;
% index of branch
F_BUS=1;T_BUS=2;BR_R=3;BR_X=4;BR_B=5;RATE_A=6;RATE_B=7;RATE_C=8;TAP=9;SHIFT=10;BR_STATUS=11;PF=14;

% remove double line
U = unique(mpc.branch(:,1:2),'rows');
for i =1 : size(U,1)
    ind = find(ismember(mpc.branch(:,1:2),U(i,:),'rows'));
    if length(ind)>1
        %[~,ix]=max(mpc.branch(ind,BR_X));% keep the branch with minimum reactance, i.e. maximum Bij
        L1 = mpc.branch(ind(1),BR_X);% inductance of the first
        L2 = mpc.branch(ind(2),BR_X);%inductance of the second
        mpc.branch(ind(1),BR_X)=1/(1/L1+1/L2);
        mpc.branch(ind(2),:)=[];
    end
end


nb = size(mpc.bus,1);% number of buses
nl = size(mpc.branch,1);% number of lines
ng = size(mpc.gen,1);% number of generators

% change the busID to 1:nb
bus_id = mpc.bus(:,BUS_I);mpc.bus(:,BUS_I)=1:nb;
for i = 1:ng
    mpc.gen(i,GEN_BUS) = find(bus_id==mpc.gen(i,BUS_I));
end
for i = 1:nl
    mpc.branch(i,F_BUS) = find(bus_id==mpc.branch(i,F_BUS));
    mpc.branch(i,T_BUS) = find(bus_id==mpc.branch(i,T_BUS));
end

% adjust mpc, such that the generator on reference bus is listed as the
% first generator
ref_ind = mpc.bus(find(mpc.bus(:,BUS_TYPE)==3),BUS_I);% bus index of the reference
gen_ind = find(mpc.gen(:,GEN_BUS)==ref_ind);% find the generator index on the ref bus
if length(gen_ind)>1
    [~,gen_ind] = max(mpc.gen(gen_ind,PG));
end

mg = mpc.gen(1,:);mpc.gen(1,:) = mpc.gen(gen_ind,:);mpc.gen(gen_ind,:)=mg;


%-------------------------------------------------------------------------%
% initilize virtual mpc
vmpc = mpc;

% add virtual buses at the beginning of vmpc.bus
vmpc.bus(:,BUS_TYPE) = 1; % change bus type to pq
abus = zeros(ng,size(mpc.bus,2));
abus(:,BUS_I) = 1:ng;
abus(:,BUS_TYPE) = 2;
abus(:,VM) = 1;
abus(:,BASE_KV) = mpc.bus(1,BASE_KV);
abus(:,VMAX) = mpc.bus(1,VMAX);
abus(:,VMIN) = mpc.bus(1,VMIN);
abus(:,BUS_AREA)=1;
abus(1,BUS_TYPE)=3;
abus(:,ZONE) = 1;
vmpc.bus(:,BUS_I) = vmpc.bus(:,BUS_I)+ng;
vmpc.bus = [abus;vmpc.bus];

% change the bus number of generators to the index of virtual buses
vmpc.gen(:,GEN_BUS) = 1:ng;

% add virtual lines at the head of vmpc.branch
vmpc.branch = mpc.branch;
abranch = zeros(ng,size(mpc.branch,2));
abranch(:,F_BUS) = 1:ng;
abranch(:,T_BUS) = mpc.gen(:,GEN_BUS)+ng;
abranch(:,BR_X) = CONST1;
abranch(:,RATE_A) = inf;
abranch(:,RATE_B) = inf;
abranch(:,RATE_C) = inf;
abranch(:,TAP) = 0;
abranch(:,BR_STATUS)=1;
vmpc.branch(:,F_BUS) = vmpc.branch(:,F_BUS) +ng;
vmpc.branch(:,T_BUS) = vmpc.branch(:,T_BUS) +ng;
vmpc.branch = [abranch;vmpc.branch];


%-------------------------------------------------------------------------%
% initilize parameters
Bij = zeros(nb,nb);
F = mpc.branch(:,F_BUS);T=mpc.branch(:,T_BUS);IND1 = sub2ind(size(Bij),[F;T],[T;F]);
Bij(IND1) = [1./mpc.branch(:,BR_X);1./mpc.branch(:,BR_X)];
Cij = zeros(ng,nb);
IND2 = sub2ind(size(Cij),1:ng,mpc.gen(:,GEN_BUS)');
Cij(IND2) = 1/CONST1;
Pg = -mpc.gen(:,PG);
Pl = mpc.bus(:,PD);
Dg = ones(ng,1)*CONST2;
Dl = ones(nb,1)*CONST3;
Mg = ones(ng,1)*CONST4;

% reset the negative reactance to be a very small number
Bij(Bij<0)=100000;
Cij(Cij<0)=100000;

parameters.ng = ng; parameters.nb = nb; parameters.nl = nl; 
parameters.Bij = Bij; parameters.Cij = Cij; 
parameters.Pg = Pg; parameters.Pl = Pl;
parameters.Dg = Dg; parameters.Dl = Dl;
parameters.Mg = Mg;
parameters.Tl = ones(nl,1)*500000;%mpc.branch(:,RATE_A);% initialize as a large number.


% if there is a Pg=0 in the initial case, set it to be 1
parameters.Pg(Pg==0) = -1;


% set default capacities
%option 2
%parameters.Tl(parameters.Tl==0) = 300;% it is power flow/baseMVA
% option 2
% Tl = 1./mpc.branch(:,BR_X)*mpc.baseMVA;
% parameters.Tl = Tl;% set base to be Bij
% option 3
% mpopt=mpoption('OUT_ALL',0,'VERBOSE',0);% print no information, no output
% mmpc = runpf(mpc,mpopt);
% parameters.Tl = max(abs(mmpc.branch(:,PF)))*10;

%-------------------------------------------------------------------------%
% initilize state x
mpopt = mpoption('OUT_ALL', 0,'VERBOSE',0);
results = runpf(vmpc,mpopt);

% adjust the Pg and make sure sum(P)=0
parameters.Pg(1) = -sum(Pl)-sum(Pg(2:end));
vmpc.gen(1,PG) = -parameters.Pg(1);


w = zeros(1,ng);
ga = results.bus(1:ng,VA)./180*pi;ga(1)=[];
ba = results.bus(ng+1:ng+nb,VA)./180*pi;
eita = ones(1,nl)*0.999;
x = [w(:); ga(:); ba(:); eita(:)];


end