function elist = edge_list(S)
ng = S.parameters.ng;

% flow on the real lines, considering the status of lines.
I = S.vmpc.branch(ng+1:end,1);
J = S.vmpc.branch(ng+1:end,2);

dis = false;
if dis
    disp('---transmission lines---')
    disp('from    to');
    disp('------------');
    for i = 1:length(I)
        disp([num2str(I(i)) '       ' num2str(J(i))]);
    end
end
    elist = containers.Map({'from','to'},{I,J});
end
