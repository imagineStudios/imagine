function dT = fInPolygon(dQ, dP)
% Parameter: Ecken P[1], ...,P[n] eines ebenen Polygons P, Testpunkt Q
% Rückgabe:  +1, wenn Q innerhalb P liegt;
%            ?1, wenn Q außerhalb P liegt;
%            0, wenn Q auf P liegt

if numel(dQ) ~= 2
    error('Testpoint must be a 2-dimensional vector!');
end

iSize = size(dP);
if ~any(iSize == 2)
    error('Polygon must be 2xn or nx2 vector!');
end

if iSize(1) == 2
    dP = dP';   % Make sure dP is nx2
end

dP = [dP; dP(1, :)];  %  Setze P[0] = P[n] und t = ?1
dT = -1;

for iI = 1:size(dP, 1) - 1 % Für i = 0, ..., n?1
    dT = dT * fCrossProdTest(dQ, dP(iI, :), dP(iI + 1, :));
    if dT == 0, return, end
end
 


function dRes = fCrossProdTest(dA, dB, dC)
% Parameter: Punkte A = (x_A,y_A), B = (x_B,y_B), C = (x_C,y_C)
% Rückgabe:  ?1, wenn der Strahl von A nach rechts die Kante [BC] schneidet (außer im unteren Endpunkt);
%            0, wenn A auf [BC] liegt;
%            sonst +1

if dA(2) == dB(2) && dA(2) == dC(2) % Wenn y_A = y_B = y_C
    if (dB(1) <= dA(1)) && (dA(1) <= dC(1)) || ...%    Wenn x_B ? x_A ? x_C oder x_C ? x_A ? x_B
       (dC(1) <= dA(1)) && (dA(1) <= dB(1))
        dRes = 0; % Ergebnis: 0
        return
    else
      dRes = 1; % Ergebnis: +1
      return
    end
end

if dB(2) > dC(2) % Wenn y_B > y_C   Vertausche B und C
    dTemp = dB;
    dB = dC;
    dC = dTemp;
end

if all(dA == dB) % Wenn y_A = y_B und x_A = x_B  Ergebnis: 0
    dRes = 0;
    return
end

if dA(2) <= dB(2) || dA(2) > dC(2) % Wenn y_A ? y_B oder y_A > y_C Ergebnis: +1
    dRes = 1;
    return
end

dDelta = (dB(1) - dA(1)).*(dC(2) - dA(2)) - (dB(2) - dA(2)) .* (dC(1) - dA(1)); %   Setze Delta = (x_B?x_A) * (y_C?y_A) ? (y_B?y_A) * (x_C?x_A)
if dDelta == 0
    dRes = 0;
else
    dRes = -sign(dDelta);
end