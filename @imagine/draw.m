function draw(obj, ~, ~)

persistent dBGImg

% dBGImg = [];
if isempty(dBGImg)
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
    
    dBGImg = repmat(permute(obj.dFGCOLOR, [1 3 2]), [16 16 1]).*dPattern;
    
%     dBGImg = fBlend(obj.dFGCOLOR, dPattern, 'multiply', 0.6);
end

% -------------------------------------------------------------------------
% Timer logic for hd mode
if nargin > 1
    % Stop timer to make sure it doesn't fire again
    stop(obj.STimers.hDrawFancy);
    lHD = obj.isOn('hd');
else
    if obj.isOn('hd')
        % Reset and start timer
        stop(obj.STimers.hDrawFancy);
        start(obj.STimers.hDrawFancy);
    end
    lHD = false;
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Determine some drawing parameters
% dGamma         = get(obj.SSliders(1).hScatter, 'XData');
dMaskAlpha     = obj.getSlider('Mask Alpha');
dQuiverWidth   = obj.getSlider('Quiver Width');
sDrawMode      = obj.getDrawMode;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Initialize windowing limits for phase and linked cases
if strcmp(sDrawMode, 'phase')
    dMin = -pi; dMax = pi;
elseif obj.isOn('lock_window') && obj.SView(1).iData
    dMin = obj.SData(obj.SView(1).iData).dWindowCenter - 0.5.*obj.SData(obj.SView(1).iData).dWindowWidth;
    dMax = obj.SData(obj.SView(1).iData).dWindowCenter + 0.5.*obj.SData(obj.SView(1).iData).dWindowWidth;
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Loop over all views
for iView = 1:numel(obj.SView)
    
    SView = obj.SView(iView);
    
    iImgInd = 0;
    
    if isempty(SView.iData)
        set(SView.hImg(1), 'CData', dBGImg);
        
        dAxesPos = get(SView.hAxes, 'Position');
        dSize = dAxesPos(4:-1:3);
        dLim = size(dBGImg(:,:,1))./max(dSize).*dSize;
        set(SView.hAxes, 'XLim', size(dBGImg, 2)/2 + 0.5*[-dLim(2) dLim(2)] + 0.5, ...
                         'YLim', size(dBGImg, 1)/2 + 0.5*[-dLim(1) dLim(1)] + 0.5);
        
    else
        
        for iData = SView.iData
            
            if ~obj.isOn('lock_window') && ~strcmp(sDrawMode, 'phase') % Individual windowing
                dMin = obj.SData(iData).dWindowCenter - 0.5.*obj.SData(iData).dWindowWidth;
                dMax = obj.SData(iData).dWindowCenter + 0.5.*obj.SData(iData).dWindowWidth;
            end
            
            if ~strcmp(obj.SData(iData).sMode, 'vector'), iImgInd = iImgInd + 1; end
            
            % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
            % Get the image data, do windowing and apply colormap
            [dImg, dXData, dYData]  = obj.getData(SView, iData, lHD);
            dImg = double(dImg);
            
            switch obj.SData(iData).sMode
                
                case {'scalar', 'categorical', 'rgb'}
                    
                    % scale and do colormapping
                    if strcmp(obj.SData(iData).sMode, 'categorical')
                        dColormap = [0 0 0; lines(max(dImg(:)))];
                        iImg = round(dImg) + 1;
                        dImg = reshape(dColormap(iImg, :), [size(iImg, 1) ,size(iImg, 2), 3]);
                        dAlpha = dMaskAlpha;
                    else
                        dImg = dImg - dMin;
                        dAlpha = dImg./(dMax - dMin);
                        dAlpha(dAlpha < 0) = 0;
                        dAlpha(dAlpha > 1) = 1;
                        
                        if strcmp(obj.SData(iData).sMode, 'scalar')
                            
                            if iImgInd == 1
                                dColormap = obj.dColormap;
                            else
                                dColormap = hot(256);
                            end
                            iImg = round(dAlpha.*(size(dColormap, 1) - 1)) + 1;
                            dImg = reshape(dColormap(iImg, :), [size(iImg, 1) ,size(iImg, 2), 3]);
                            %                         dAlpha = 0;
                            dAlpha = dMaskAlpha;
                            %                         dAlpha = dAlpha.*dMaskAlpha;
                        else
                            dImg = dAlpha;
                            dAlpha = mean(dAlpha, 3).*dMaskAlpha;
                        end
                    end
                    
                    if iImgInd == 1, dAlpha = 1; end
                    
                    set(SView.hImg(iImgInd), 'CData', dImg, 'XData', dXData, 'YData', dYData, 'AlphaData', dAlpha);
                    
                case 'vector'
                    
                    set(SView.hQuiver, 'XData', dXData, 'YData', dYData, 'Visible', 'on', 'LineWidth', dQuiverWidth);
                    set(SView.hQuiver.Edge, 'ColorBinding', 'interpolated', 'ColorData', uint8(dImg))
            end
            
            set(SView.hText(1, 1, :),  'String', sprintf('[%d]: %s', SView.iData(1), obj.SData(SView.iData(1)).sName), 'Visible', 'on');
%             set(SView.hAxes, 'Color', obj.dColormap(1,:));
            
        end
    end
end




















% -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
% Apply mask if any
% if SView.iMask > 0
%
%     [dMask, dXData, dYData] = obj.getData(SView, true, lHD);
%
%     if ~isempty(dMask)
%         if size(obj.SData(SView.iMask).dImg, 3) == 1
%
%             switch(class(dMask))
%
%                 case 'uint8' % Assume categorial data
%                     dColormapMask = [0 0 0; lines(max(dMask(:)))];
%                     dMaskRGB = reshape(dColormapMask(dMask + 1, :), [size(dMask, 1) ,size(dMask, 2), 3]);
%                     dAlpha = dMaskAlpha;
%
%                 case 'logical' % Assume binary mask
%                     dColormapMask = [0 0 0; lines(1)];
%                     dMaskRGB = reshape(dColormapMask(dMask + 1, :), [size(dMask, 1) ,size(dMask, 2), 3]);
%                     dAlpha = dMaskAlpha;
%
%                 otherwise % Assume intensity image
%                     dMin = obj.SData(SView.iMask).dWindowCenter - 0.5.*obj.SData(SView.iMask).dWindowWidth;
%                     dMax = obj.SData(SView.iMask).dWindowCenter + 0.5.*obj.SData(SView.iMask).dWindowWidth;
%                     dMask = dMask - dMin;
%                     dMask = dMask./(dMax - dMin);
%                     dMask(dMask < 0) = 0;
%                     dMask(dMask > 1) = 1;
%                     iMask = round(dMask.*(255)) + 1;
%                     dColormapMask = hot(256);
%                     dMaskRGB = reshape(dColormapMask(iMask, :), [size(iMask, 1) ,size(iMask, 2), 3]);
%                     dAlpha = dMask.*dMaskAlpha;
%             end
%             set(SView.hQuiver, 'Visible', 'off');
%             set(SView.hMask, 'CData', dMaskRGB, 'XData', dXData, 'YData', dYData, 'Visible', 'on', 'AlphaData', dAlpha);
%
%         else
%             set(SView.hQuiver, 'XData', dXData, 'YData', dYData, 'Visible', 'on', 'LineWidth', dQuiverWidth);
%             set(SView.hQuiver.Edge, 'ColorBinding', 'interpolated', 'ColorData', dMask)
%             set(SView.hMask, 'Visible', 'off');
%         end
%     end