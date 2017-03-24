function [dImg, dXData, dYData, dAlpha] = getData(obj, dDrawCenter, iDimInd, hA, lHD)

if nargin == 1 && nargout == 1
    % Special case of only one input argument: Return thumbnail
    dImg = obj.Img(:,:,obj.ThumbSlice,1,:);
    return
end

if nargin < 5, lHD = false;   end

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

dImg = double(dImg);

lNum = ~isnan(dImg);
dImg(~lNum) = 0;

dAspect = obj.Res(iDim(1:2));
dOrigin = obj.Origin(iDim(1:2));

if lHD && ~strcmp(obj.Mode, 'vector') && ~strcmp(obj.Mode, 'categorical') && ~isscalar(dImg)
    % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
    % Fancy mode: Interpolate the images to full resolution. Is
    % executed when arbitrary input is supplied or the timer fires.
    
    % -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
    % Pad the image for better boundary extrapolation
    dImg = [dImg(:,1), dImg, dImg(:, end)];
    dImg = [dImg(1,:); dImg; dImg(end, :)];
    dX = (-1:size(dImg, 2) - 2).*dAspect(2) + dOrigin(2);
    dY = (-1:size(dImg, 1) - 2).*dAspect(1) + dOrigin(1);
    
    dXLim = get(hA, 'XLim');
    dYLim = get(hA, 'YLim');
    dPosition = get(hA, 'Position');
    
    dXI = (0.5:dPosition(3) - 0.5)./dPosition(3).*diff(dXLim) + dXLim(1);
    dYI = (0.5:dPosition(4) - 0.5)./dPosition(4).*diff(dYLim) + dYLim(1);
    
    dXI = dXI(dXI >= mean(dX(1:2)) & dXI <= mean(dX(end-1:end)));
    dYI = dYI(dYI >= mean(dY(1:2)) & dYI <= mean(dY(end-1:end)));
    
    [dXXI, dYYI] = meshgrid(dXI, dYI);
    dImg = interp2(dX, dY, double(dImg), dXXI, dYYI, 'spline', 0);
    dNum = interp2(dX(2:end-1), dY(2:end-1), double(lNum), dXXI, dYYI, 'spline', 0);
    
    dXData = [dXI(1), dXI(end)];
    dYData = [dYI(1), dYI(end)];
else
    dNum = double(lNum);
    dXData = [0 size(dImg, 2) - 1].*dAspect(2) + dOrigin(2);
    dYData = [0 size(dImg, 1) - 1].*dAspect(1) + dOrigin(1);
end


% -------------------------------------------------------------------------
% Apply the intensity scaling and current colormap
if strcmp(sDrawMode, 'phase')
    dMin = -pi;
    dMax = pi;
else
    dMin = obj.Window(1);
    dMax = obj.Window(2);
end

switch obj.Mode
    
    case 'scalar'
        dImgA = dImg - dMin;
        dImgA = dImgA./(dMax - dMin);
        dImgA(dImgA < 0) = 0;
        dImgA(dImgA > 1) = 1;
        
        iImg = round(dImgA.*(size(obj.Colormap.dMap, 1) - 1)) + 1;
        dImg = reshape(obj.Colormap.dMap(iImg, :), [size(iImg, 1) ,size(iImg, 2), 3]);
        
    case 'categorical'
        dColormap = [0 0 0; lines(max(dImg(:)))];
        iImg = round(dImg) + 1;
        dImg = reshape(dColormap.dMap(iImg, :), [size(iImg, 1) ,size(iImg, 2), 3]);
            
    case 'rgb'
        dImg = dImg - dMin;
        dImg = dImg./(dMax - dMin);
        dImg(dImg < 0) = 0;
        dImg(dImg > 1) = 1;
        
end
% -------------------------------------------------------------------------

if obj.Alpha == 0 && strcmp(obj.Mode, 'scalar')
    dAlpha = dImgA;
elseif ~isempty(d3Lim_px)
    dAlpha = obj.Alpha;
else
    dAlpha = 0;
end
dAlpha = dNum.*dAlpha;