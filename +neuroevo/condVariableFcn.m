function Xnew = condVariableFcn(X)
Xnew = X;

Xnew.c4s(Xnew.numConv <= 3) = NaN;
Xnew.c4n(Xnew.numConv <= 3) = NaN;

Xnew.c5s(Xnew.numConv <= 4) = NaN;
Xnew.c5n(Xnew.numConv <= 4) = NaN;

Xnew.c6s(Xnew.numConv <= 5) = NaN;
Xnew.c6n(Xnew.numConv <= 5) = NaN;


Xnew.n2(Xnew.numNN <= 2) = NaN;
Xnew.n3(Xnew.numNN <= 3) = NaN;
end