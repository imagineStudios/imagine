function dMap = CubeHelix(iNBins, dGamma)

dStart     =  0.5;
dRotations = -1.5;
dHue       =  2;

dT = linspace(0, 1, iNBins)';
dT = dT.^dGamma;

dMap = [max(min(dT + dHue.*dT.*(1 - dT)./2.*(-0.1486.*cos(2.*pi.*(dStart./3 + dRotations.*dT + 1)) ...
            + 1.7823.*sin(2.*pi.*(dStart./3 + dRotations.*dT + 1))), 1), 0), ...
        max(min(dT + dHue.*dT.*(1 - dT)./2.*(-0.2923.*cos(2.*pi.*(dStart./3 + dRotations.*dT + 1)) + ...
            - 0.9065.*sin(2.*pi.*(dStart./3 + dRotations.*dT + 1))), 1), 0), ...
        max(min(dT + dHue.*dT.*(1 - dT)./2.*(+1.9729.*cos(2.*pi.*(dStart./3 + dRotations.*dT + 1))), 1), 0)];