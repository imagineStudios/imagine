function dF = fLiveWireGetCostFcn(dImg, dWz, dWg, dWd)

if nargin < 2,
    dWz = 0.2;
    dWg = 0.8;
    dWd = 0.2;
end

% -------------------------------------------------------------------------
% Calculat the cost function

% The gradient strength cost Fg
dImg = double(dImg);
[dY, dX] = gradient(dImg);
dFg = sqrt(dX.^2 + dY.^2);
dFg = 1 - dFg./max(dFg(:));

% The zero-crossing cost Fz
lFz = ~edge(dImg, 'zerocross');

% The Sum:

dF = dWz.*double(lFz)+ dWg.*dFg;
% -------------------------------------------------------------------------