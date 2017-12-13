function [w,ga,ba,eita] = unpack_x(S,x)
nb=S.parameters.nb; ng=S.parameters.ng; nl=S.parameters.nl;
w = x(1:ng);w =w(:);% generator frequency
ga = x(ng+1:2*ng-1);ga=ga(:);% generator angle 1-by-(ng-1)
ba = x(2*ng:2*ng+nb-1);ba=ba(:);% bus angle 1-by-nb
eita = x(2*ng+nb:2*ng+nb+nl-1);eita=eita(:);% branch status
end