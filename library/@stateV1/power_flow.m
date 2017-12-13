function  [Pf_vir,Pf_line] = power_flow(S,x)
% return dictionaries: {from_indices, to_indices, flow_vector}, 
% return flow on virtual and flow real lines separately.


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
fl = bij(sub2ind(size(bij),I,J)).*(sin(alpha(I(:))-alpha(J(:))))*baseMVA;
%fl = bij(sub2ind(size(bij),I,J)).*(sin(alpha(I(:))-alpha(J(:))));
Pf_vir = containers.Map({'from','to','flow'},{I(:),J(:),fl(:)});

% flow on the real lines, considering the status of lines.
I2 = S.vmpc.branch(ng+1:end,1);
J2 = S.vmpc.branch(ng+1:end,2);
fl2 = bij(sub2ind(size(bij),I2,J2)).*stat_eita(:).*(sin(alpha(I2(:))-alpha(J2(:))))*baseMVA;
%fl2 = bij(sub2ind(size(bij),I2,J2)).*stat_eita(:).*(sin(alpha(I2(:))-alpha(J2(:))));

Pf_line = containers.Map({'from','to','flow'},{I2(:),J2(:),fl2(:)});

end