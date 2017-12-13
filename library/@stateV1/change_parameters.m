function new_para = change_parameters(S, dName, dValue)
% change the 'dName' in S.parameters to the 'dValue' that user chooses
new_para = S.parameters;

oldValue = getfield(new_para,dName);
if ~isequal(size(oldValue(:)),size(dValue(:)))
    error('The size of the new parameters does not match the old parameters.');
else
    new_para = setfield(new_para,dName,dValue);
end



