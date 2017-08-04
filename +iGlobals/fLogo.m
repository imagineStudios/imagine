function dImg = fLogo(iSize, iN, hCol)

iSUPERSAMPLING = 4;

% if isfunctionhandle(hCol)
  dCol = hCol(iN);
% else
%   dCol = hCol;
% end

dQ = fQuadrant(iSize.*iSUPERSAMPLING);
dAlpha = [flip(dQ, 2); flip(dQ, 1)];
dAlpha = iGlobals.fDecimate(dAlpha, iSUPERSAMPLING);
dAlpha = padarray(dAlpha, round(iSize.*[0.6, 2.4]), 0, 'pre');
dAlpha = padarray(dAlpha, round(iSize.*[1, 1.4]), 0, 'post');


dImg = zeros(size(dAlpha, 1), size(dAlpha, 2), 3);
dA = zeros(size(dAlpha));

for iI = 1:iN
  dC = repmat(permute(dCol(iI, :), [1 3 2]), size(dImg, 1), size(dImg, 2), 1);
  dAR = repmat(0.8.*iGlobals.fRotate(dAlpha, -(iI - 1 - (iN - 1)/2).*180/(iN - 1) + 25, round(iSize.*[2.4 2.6])), 1, 1, 3);
  dC = dC.*dAR; % premultiplied alpha
  
  % Blend over with alpha
  dImg = dC + dImg.*(1 - dAR);
  dA = dAR(:,:,1) + dA.*(1 - dAR(:,:,1));
end

dImg = dImg./repmat(dA, 1, 1, 3);
dImg = cat(3, dImg, dA);

% hF = figure;
% hI = imshow(dImg);
% set(hI, 'AlphaData', dA);
% set(hF, 'Color', 0.1.*[1 1 1]);



function dQuadrant = fQuadrant(iRadius)

[dX, dY] = meshgrid(0:iRadius - 1, 0:iRadius - 1);
dQuadrant = double((dX.^2 + dY.^2) <= iRadius.^2);
dQuadrant = flip(dQuadrant, 1);


