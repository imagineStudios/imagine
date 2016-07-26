function utilDown(obj, ~, ~)

dPos = round(get(obj.SAxes.hUtil, 'CurrentPoint'));
dXLim = get(obj.SAxes.hUtil, 'XLim');
dYLim = get(obj.SAxes.hUtil, 'YLim');
        
if dPos(1, 1) >= dXLim(1) && dPos(1, 1) < dXLim(2) && ...
   dPos(1, 2) >= dYLim(1) && dPos(1, 2) < dYLim(2)
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Distinguish the different utility axes modes
    switch get(obj.SImgs.hUtil, 'UserData')
        
        % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        % Mode 1: Determine number of views
        case 1
            
            obj.setViews(dPos(1,1:2));
            drawnow
            
            % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
            % Mode 2: Determine colormap
        case 2
            dPos = round(get(obj.SAxes.hUtil, 'CurrentPoint'));
            
            if dPos(1,1) > 0 && dPos(1,1) <= dXLim(2) && dPos(1,2) > 0 && dPos(1,2) <= dYLim(2)
                csColormaps = obj.getColormaps;
                obj.setColormap(csColormaps{dPos(1, 2)});
            end
    end
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Fade out and hide the utility axes
dAlphaData = get(obj.SImgs.hUtil, 'AlphaData');
dAlphaData = double(dAlphaData > 0.6);
for dAlpha = 0.8:-0.1:0
    set(obj.SImgs.hUtil, 'AlphaData', dAlpha.*dAlphaData);
    drawnow update
    pause(0.01);
end
% set(obj.SAxes.hUtil, 'Visible', 'off');
set(obj.SImgs.hUtil, 'Visible', 'off');

set(obj.hF, 'WindowButtonMotionFcn', @obj.mouseMove, 'WindowButtonDownFcn', '');