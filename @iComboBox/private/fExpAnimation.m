function dFraction = fExpAnimation(iN, dStart, dEnd)

dFraction = dEnd + (dStart - dEnd).*linspace(1, 0, iN).^3;
dFraction(end) = dEnd; % Make sure end-value is reached