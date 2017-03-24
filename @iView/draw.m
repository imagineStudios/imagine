function draw(obj, lHD)

persistent dBGImg
% dBGImg = [];
if isempty(dBGImg)
    dBGImg = fBGImg(obj(1).hParent.dBGCOLOR);
end

% -------------------------------------------------------------------------
% Determine some drawing parameters
% dGamma         = get(obj.SSliders(1).hScatter, 'XData');
% dMaskAlpha     = obj.getSlider('Mask Alpha');
% dQuiverWidth   = obj.getSlider('Quiver Width');
% sDrawMode      = obj.getDrawMode;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Initialize windowing limits for phase and linked cases
% if strcmp(sDrawMode, 'phase')
%     dMin = -pi; dMax = pi;
% elseif obj.isOn('lock_window') && obj.SView(1).iData
%     dMin = obj.SData(obj.SView(1).iData).dWindowCenter - 0.5.*obj.SData(obj.SView(1).iData).dWindowWidth;
%     dMax = obj.SData(obj.SView(1).iData).dWindowCenter + 0.5.*obj.SData(obj.SView(1).iData).dWindowWidth;
% end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Loop over all views

% iImgInd = 0;
for iI = 1:numel(obj)
    
    hView = obj(iI);

    if isempty(obj(iI).hData)

        set(hView.hI, ...
            'CData'     , dBGImg, ...
            'AlphaData' , 1, ...
            'XData'     , [1 size(dBGImg, 2)], ...
            'YData'     , [1 size(dBGImg, 1)]);

    else

        for iJ = 1:length(obj(iI).hData)

            % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
            % Get the image data, do windowing and apply colormap
            for iDimInd = 1:length(hView.hA)
                
                [dImg, dXData, dYData, dAlpha] = ...
                    obj(iI).hData(iJ).getData(hView.DrawCenter, iDimInd, hView.hA(iDimInd), lHD);
                
                if ~strcmp(obj(iI).hData(iJ).Mode, 'vector')
                    % It's image data
                    set(hView.hI(iDimInd, iJ), ...
                        'CData'     , dImg, ...
                        'AlphaData' , dAlpha, ...
                        'XData'     , dXData, ...
                        'YData'     , dYData);
                    
                else
                    % Its a quiver plot
                    set(SView.hQuiver, ...
                        'XData'     , dXData, ...
                        'YData'     , dYData, ...
                        'Visible'   , 'on', ...
                        'LineWidth' , dQuiverWidth);
                    
                    set(SView.hQuiver.Edge, ...
                        'ColorBinding'  , 'interpolated', ...
                        'ColorData'     , uint8(dImg))
                end
            end
    %         set(SView.hText(1, 1, :),  'String', sprintf('[%d]: %s', SView.iData(1), obj.SData(SView.iData(1)).sName), 'Visible', 'on');
            %             set(SView.hAxes, 'Color', obj.dColormap(1,:));

        end
    end
end



% if lHD && ~strcmp(obj.SData(iSeries).sMode, 'vector') && ~strcmp(obj.SData(iSeries).sMode, 'categorical')

    % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
    % Fancy mode: Interpolate the images to full resolution. Is
    % executed when arbitrary input is supplied or the timer fires.
    
    % -   -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
    % Pad the image for better boundary extrapolation
%     dImg = [dImg(:,1), dImg, dImg(:, end)];
%     dImg = [dImg(1,:); dImg; dImg(end, :)];
%     dX = (-1:size(dImg, 2) - 2).*dAspect(2) + dOrigin(2);
%     dY = (-1:size(dImg, 1) - 2).*dAspect(1) + dOrigin(1);
    



function dImg = fBGImg(dColor)
dLogo = [0 0 0 1 1 0 0 0; ...
         0 0 0 1 1 0 0 0; ...
         0 0 0 0 0 0 0 0; ...
         0 0 1 1 1 0 0 0; ...
         0 0 0 1 1 0 0 0; ...
         0 0 0 1 1 0 0 0; ...
         0 0 1 1 1 1 0 0; ...
         0 0 0 0 0 0 0 0;];
dPattern = 0.8 + 0.1*rand(16) + 0.2*padarray(dLogo, [4 4], 0, 'both');
dPattern = dPattern.*repmat(linspace(1, 0.8, 16)', [1, 16]);
dPattern = repmat(dPattern, [1 1 3]);

dImg = repmat(permute(dColor, [1 3 2]), [16 16 1]).*dPattern;