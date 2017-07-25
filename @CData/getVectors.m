function [dUData, dVData, dXData, dYData, dCData] = getVectors(obj, dDrawCenter, iDimInd, hA)

iDim = obj.Dims(iDimInd, :);

% -------------------------------------------------------------------------
% Get the corresponding image data

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Calculate the boundaries of the projection in physical units

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Translate to slice indices
d3Lim_px = obj.getSliceLim(dDrawCenter, iDim);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Determine timepoint
iT = max(1, min(dDrawCenter(4), size(obj.Img, 4)));

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Get data and permute into first two dimensions (3rd for projection data, 4th for rgb/vector data)
if ~isempty(d3Lim_px)
    switch iDim(3)
        case 1, dImg = obj.Img(d3Lim_px,:,:,iT,:);
        case 2, dImg = obj.Img(:,d3Lim_px,:,iT,:);
        case 3, dImg = obj.Img(:,:,d3Lim_px,iT,:);
    end
    dImg = permute(dImg, [iDim(1:2) iDim(3) 5 4]);
else
    dImg = 0;
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Calculate phase image or projection
switch obj.Parent.getDrawMode
    
    case 'max'
        dImg = max(dImg, [], 3);
        
    case 'min'
        dImg = min(dImg, [], 3);
        
end
% -------------------------------------------------------------------------

dImg = double(dImg);

lNum = ~isnan(dImg);
dImg(~lNum) = 0;

dAspect = obj.Res(iDim(1:2));
dOrigin = obj.Origin(iDim(1:2));

dNum = double(lNum);

dXData = (0:10:dAspect(2)*size(dImg, 2) - 2) + dOrigin(2);
dYData = (0:10:dAspect(1)*size(dImg, 1) - 2) + dOrigin(1);

dImg = dImg(round((dYData - dOrigin(1))./dAspect(1) + 1), ...
    round((dXData - dOrigin(2))./dAspect(2) + 1), :);

dLength = sqrt(sum(dImg.^2, 3));
dLength(dLength == 0) = 1;
dCData = abs(dImg(:,:,[2 1 3]))./repmat(dLength, [1 1 3]);
dCData = reshape(dCData, [], 3)';

iDim(iDim == 4) = 3;
dImg = dImg(:,:,iDim(1:2));
dUData = dImg(:,:,2);
dVData = dImg(:,:,1);