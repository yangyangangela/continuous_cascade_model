function [E_vir,E_line] = power_flow_energy(S,x)
% return dictionaries: {from_indices, to_indices, energy_vector}, 
% return the energy of power flow on virtual and flow real lines separately.

% see lyapunov_energy also

% retrieve the structure parameters
ng = S.parameters.ng;
Bij = S.parameters.Bij;
Cij = S.parameters.Cij;

bij = [zeros(ng,ng) Cij;Cij' Bij];


% retrieve state parameters
[~,gen_a,bus_a,stat_eita] = unpack_x(S,x);
gen_a = [0;gen_a];% add the slack bus angle
alpha = [gen_a(:); bus_a(:)];
baseMVA = S.vmpc.baseMVA;


% flow on the virtual lines that connect generators to their original buses
I = S.vmpc.branch(1:ng,1);
J = S.vmpc.branch(1:ng,2);
eg_fl = bij(sub2ind(size(bij),I,J)).*(1-cos(alpha(I(:))-alpha(J(:))))*baseMVA;
%eg_fl = bij(sub2ind(size(bij),I,J)).*(1-cos(alpha(I(:))-alpha(J(:))));
E_vir = containers.Map({'from','to','energy'},{I(:),J(:),eg_fl(:)});

% flow on the real lines, considering the status of lines.
I2 = S.vmpc.branch(ng+1:end,1);
J2 = S.vmpc.branch(ng+1:end,2);
eg_fl2 = bij(sub2ind(size(bij),I2,J2)).*stat_eita(:).*(1-cos(alpha(I2(:))-alpha(J2(:))))*baseMVA;
%eg_fl2 = bij(sub2ind(size(bij),I2,J2)).*stat_eita(:).*(1-cos(alpha(I2(:))-alpha(J2(:))));
E_line = containers.Map({'from','to','energy'},{I2(:),J2(:),eg_fl2(:)});


end