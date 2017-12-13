function x = pack_x(S,w,ga,ba,eita)
nb=S.parameters.nb; ng=S.parameters.ng; nl=S.parameters.nl;
x(1:ng)=w(:);% generator frequency
x(ng+1:2*ng-1)=ga(:);% generator angle 1-by-(ng-1), generator 1 not included
x(2*ng:2*ng+nb-1)=ba(:);% bus angle 1-by-nb
x(2*ng+nb:2*ng+nb+nl-1)=eita(:);% branch status

end