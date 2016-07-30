function [dImg, dXData, dYData] = getData(obj, SView, iSeries, lHD)

if nargin < 4, lHD = false;   end
if nargin < 3
    iSeries = SView.iData(1);
end

dQuiverSpacing = obj.getSlider('Quiver Spacing');
dAlpha = obj.getSlider('Mask Alpha');

dImg   = [];
dXData = [];
dYData = [];

iDim = obj.SData(SView.iData(1)).iDims(SView.iDimInd, :);

d3Lim_mm = obj.get3Lim(SView);
iT    = obj.SData(SView.iData(1)).dDrawCenter(5);

iZInd = getSliceInd(obj, d3Lim_mm, iSeries, iDim);
if isempty(iZInd), return, end

if iT > size(obj.SData(iSeries).dImg, 5), iT = size(obj.SData(iSeries).dImg, 5); end
% -------------------------------------------------------------------------
% Get the corresponding image data
switch iDim(3)
    case 1, dImg = obj.SData(iSeries).dImg(iZInd,:,:,:,iT);
    case 2, dImg = obj.SData(iSeries).dImg(:,iZInd,:,:,iT);
    case 4, dImg = obj.SData(iSeries).dImg(:,:,:,iZInd,iT);
end
dImg = permute(dImg, [iDim(1:2) 3 iDim(3)]);
% -------------------------------------------------------------------------


sDrawMode = obj.getDrawMode;

% -------------------------------------------------------------------------
% For complex data and not phase mode, get the magnitude
if ~strcmp(sDrawMode, 'phase') && ~isreal(dImg)
    dImg = abs(dImg);
end
% -------------------------------------------------------------------------



% -------------------------------------------------------------------------
% Get phase image or projections respectively
switch sDrawMode
    
    case 'phase'
        if isreal(dImg)
            dImg = pi*sign(dImg);
        else
            dImg = angle(dImg);
        end
        
    case 'max'
        dImg = max(dImg, [], 4);
        
    case 'min'
        dImg = min(dImg, [], 4);
        
end
% -------------------------------------------------------------------------

dAspect = obj.SData(iSeries).dRes(iDim(1:2));
dOrigin = obj.SData(iSeries).dOrigin(iDim(1:2));
dXData = [0 size(dImg, 2) - 1].*dAspect(2) + dOrigin(2);
dYData = [0 size(dImg, 1) - 1].*dAspect(1) + dOrigin(1);

if lHD && ~strcmp(obj.SData(iSeries).sMode, 'vector') && ~strcmp(obj.SData(iSeries).sMode, 'categorical')
    % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
    % Fancy mode: Interpolate the images to full resolution. Is
    % executed when arbitrary input is supplied or the timer fires.
    
    % -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
    % Pad the image for better boundary extrapolation
    dImg = [dImg(:,1), dImg, dImg(:, end)];
    dImg = [dImg(1,:); dImg; dImg(end, :)];
    dX = (-1:size(dImg, 2) - 2).*dAspect(2) + dOrigin(2);
    dY = (-1:size(dImg, 1) - 2).*dAspect(1) + dOrigin(1);
    
    dXLim = get(SView.hAxes, 'XLim');
    dYLim = get(SView.hAxes, 'YLim');
    dPosition = get(SView.hAxes, 'Position');
    
    dXI = (0.5:dPosition(3) - 0.5)./dPosition(3).*diff(dXLim) + dXLim(1);
    dYI = (0.5:dPosition(4) - 0.5)./dPosition(4).*diff(dYLim) + dYLim(1);
    
    dXI = dXI(dXI >= mean(dX(1:2)) & dXI <= mean(dX(end-1:end)));
    dYI = dYI(dYI >= mean(dY(1:2)) & dYI <= mean(dY(end-1:end)));
    
    [dXXI, dYYI] = meshgrid(dXI, dYI);
    dImg = interp2(dX, dY, double(dImg), dXXI, dYYI, 'spline', 0);
    
    dXData = [dXI(1), dXI(end)];
    dYData = [dYI(1), dYI(end)];
end

% -------------------------------------------------------------------------
% If vector data, create the quiver data
if strcmp(obj.SData(iSeries).sMode, 'vector')
        
    dXData = (0:dQuiverSpacing:dAspect(2)*size(dImg, 2) - 2) + dOrigin(2);
    dYData = (0:dQuiverSpacing:dAspect(1)*size(dImg, 1) - 2) + dOrigin(1);
    
    dImg = dImg(round((dYData - dOrigin(1))./dAspect(1) + 1), ...
                round((dXData - dOrigin(2))./dAspect(2) + 1), :);
            
    dLength = sqrt(sum(dImg.^2, 3));
    dLength(dLength == 0) = 1;
    dC = abs(dImg(:,:,[2 1 3]))./repmat(dLength, [1 1 3]);
    dC = reshape(dC, [], 3)';
    dC = [dC; dAlpha.*ones(1, size(dC, 2))];
    dC = uint8(dC*255);
    
    iDim(iDim == 4) = 3;
    dImg = dImg(:,:,iDim(1:2));
    dU = dImg(:,:,2);
    dV = dImg(:,:,1);
    
    
    dImg = reshape(repmat(dC, [5 1]), 4, []);

    
    
    [dXData, dYData] = fQuiver(dXData, dYData, dU(:), dV(:));
end
% -------------------------------------------------------------------------


function [dLineX, dLineY] = fQuiver(dX, dY, dU, dV)

% Preprocess the coordinate system inputs
if isvector(dX)
    % if scalar (cartesian system), mesh the values
    [dX, dY] = meshgrid(dX, dY);
end

% Make sure everything is a row vector for easy processing
dX = dX(:)';
dY = dY(:)';

dU = dU(:)';
dV = dV(:)';

dUV = [dU', dV'];
dArrow1 = 0.4.*dUV*fRotation(150/180*pi);
dArrow2 = 0.4.*dUV*fRotation(210/180*pi);

% Create the line data of the arrows, such that it cen be displayed using a
% single line
dLineX = [dX; dX + dU; dX + dU + dArrow1(:, 1)'; nan(1, length(dX)); dX + dU + dArrow2(:, 1)'; dX + dU; nan(1, length(dX))];
dLineX = dLineX(:);
dLineY = [dY; dY + dV; dY + dV + dArrow1(:, 2)'; nan(1, length(dX)); dY + dV + dArrow2(:, 2)'; dY + dV; nan(1, length(dX))];
dLineY = dLineY(:);


function dRot = fRotation(dAlpha)

dRot = [cos(dAlpha), -sin(dAlpha); sin(dAlpha), cos(dAlpha)];