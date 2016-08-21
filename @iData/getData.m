function [dImg, dXData, dYData] = getData(obj, dDrawCenter, iDimInd, lHD)

if nargin < 3, lHD = false;   end

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
iT = min(dDrawCenter(4), size(obj.Img, 4));

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
% Apply the global draw mode
sDrawMode = obj.Parent.getDrawMode;

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% For complex data and not phase mode, get the magnitude
if ~strcmp(sDrawMode, 'phase') && ~isreal(dImg)
    dImg = abs(dImg);
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Calculate phase image or projection
switch sDrawMode
    case 'phase'
        if isreal(dImg)
            dImg = pi*sign(dImg);
        else
            dImg = angle(dImg);
        end
        
    case 'max'
        dImg = max(dImg, [], 3);
        
    case 'min'
        dImg = min(dImg, [], 3);
        
end
% -------------------------------------------------------------------------

dAspect = obj.Res(iDim(1:2));
dOrigin = obj.Origin(iDim(1:2));
dXData = [0 size(dImg, 2) - 1].*dAspect(2) + dOrigin(2);
dYData = [0 size(dImg, 1) - 1].*dAspect(1) + dOrigin(1);

dImg = double(dImg);

% if lHD && ~strcmp(obj.SData(iSeries).sMode, 'vector') && ~strcmp(obj.SData(iSeries).sMode, 'categorical')
%     % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
%     % Fancy mode: Interpolate the images to full resolution. Is
%     % executed when arbitrary input is supplied or the timer fires.
%     
%     % -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
%     % Pad the image for better boundary extrapolation
%     dImg = [dImg(:,1), dImg, dImg(:, end)];
%     dImg = [dImg(1,:); dImg; dImg(end, :)];
%     dX = (-1:size(dImg, 2) - 2).*dAspect(2) + dOrigin(2);
%     dY = (-1:size(dImg, 1) - 2).*dAspect(1) + dOrigin(1);
%     
%     dXLim = get(hView.hAxes, 'XLim');
%     dYLim = get(hView.hAxes, 'YLim');
%     dPosition = get(hView.hAxes, 'Position');
%     
%     dXI = (0.5:dPosition(3) - 0.5)./dPosition(3).*diff(dXLim) + dXLim(1);
%     dYI = (0.5:dPosition(4) - 0.5)./dPosition(4).*diff(dYLim) + dYLim(1);
%     
%     dXI = dXI(dXI >= mean(dX(1:2)) & dXI <= mean(dX(end-1:end)));
%     dYI = dYI(dYI >= mean(dY(1:2)) & dYI <= mean(dY(end-1:end)));
%     
%     [dXXI, dYYI] = meshgrid(dXI, dYI);
%     dImg = interp2(dX, dY, double(dImg), dXXI, dYYI, 'spline', 0);
%     
%     dXData = [dXI(1), dXI(end)];
%     dYData = [dYI(1), dYI(end)];
% end

% -------------------------------------------------------------------------
% If vector data, create the quiver data
% if strcmp(obj.Mode, 'vector')
%         
%     dXData = (0:dQuiverSpacing:dAspect(2)*size(dImg, 2) - 2) + dOrigin(2);
%     dYData = (0:dQuiverSpacing:dAspect(1)*size(dImg, 1) - 2) + dOrigin(1);
%     
%     dImg = dImg(round((dYData - dOrigin(1))./dAspect(1) + 1), ...
%                 round((dXData - dOrigin(2))./dAspect(2) + 1), :);
%             
%     dLength = sqrt(sum(dImg.^2, 3));
%     dLength(dLength == 0) = 1;
%     dC = abs(dImg(:,:,[2 1 3]))./repmat(dLength, [1 1 3]);
%     dC = reshape(dC, [], 3)';
%     dC = [dC; dAlpha.*ones(1, size(dC, 2))];
%     dC = uint8(dC*255);
%     
%     iDim(iDim == 4) = 3;
%     dImg = dImg(:,:,iDim(1:2));
%     dU = dImg(:,:,2);
%     dV = dImg(:,:,1);
%     
%     
%     dImg = reshape(repmat(dC, [5 1]), 4, []);
% 
%     
%     
%     [dXData, dYData] = fQuiver(dXData, dYData, dU(:), dV(:));
% end

% dQuiverSpacing  = obj.Parent.getSlider('Quiver Spacing');
% dAlpha          = obj.Parent.getSlider('Mask Alpha');

% -------------------------------------------------------------------------
% Apply the intensity scaling and current colormap

dMin = obj.WindowCenter - 0.5.*obj.WindowWidth;
dMax = obj.WindowCenter + 0.5.*obj.WindowWidth;

switch obj.Mode
    
    case 'scalar'
        dImg = dImg - dMin;
        dImg = dImg./(dMax - dMin);
        dImg(dImg < 0) = 0;
        dImg(dImg > 1) = 1;
        
        iImg = round(dImg.*(size(obj.dColormap, 1) - 1)) + 1;
        dImg = reshape(obj.dColormap(iImg, :), [size(iImg, 1) ,size(iImg, 2), 3]);
        
    case 'categorical'
        dColormap = [0 0 0; lines(max(dImg(:)))];
        iImg = round(dImg) + 1;
        dImg = reshape(dColormap(iImg, :), [size(iImg, 1) ,size(iImg, 2), 3]);
            
    case 'rgb'
        dImg = dImg - dMin;
        dImg = dImg./(dMax - dMin);
        dImg(dImg < 0) = 0;
        dImg(dImg > 1) = 1;
        
end
% -------------------------------------------------------------------------