function new_x = turn_off_lines(S,e1)
% e1 is a vector [from_bus to_bus], bus are indexed in virtual network
nb = S.parameters.nb;
ng = S.parameters.ng;

FT = S.vmpc.branch(:,1:2);

line_indx = find(ismember(FT,e1,'rows'))-ng;% line index (only consider transmission lines)

new_x = S.x;
new_x(ng+ng-1+nb+line_indx)=0.001;% turn of the lines

return


