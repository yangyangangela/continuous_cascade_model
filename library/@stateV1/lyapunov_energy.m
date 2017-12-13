function l = lyapunov_energy(S,x)
% The lyapunov energy
Mg = S.parameters.Mg;
Tl = S.parameters.Tl;
Pg = S.parameters.Pg;
Pl = S.parameters.Pl;

[w,ga,ba,eita] = unpack_x(S,x);
ga = [0;ga];

ke = 1/2*sum(Mg.*w.*w);% kinectic energy
[E_vir,E_line] = power_flow_energy(S,x);
fe = sum(E_vir('energy'))+sum(E_line('energy'));% flow energy
se = sum(Tl(:).*S.onoff_energy(eita));% state energy

pe = sum(ga.*Pg) + sum(ba.*Pl);

l = ke + fe + se + pe;

end