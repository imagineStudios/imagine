function utilDown(obj, ~, ~)

% -------------------------------------------------------------------------
% Set the right amount of views

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Determine the desired layout
dPos = round(get(obj.SAxes.hUtil, 'CurrentPoint'));
dXLim = get(obj.SAxes.hUtil, 'XLim');
dYLim = get(obj.SAxes.hUtil, 'YLim');

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Check if input valid and set views
if dPos(1, 1) >= dXLim(1) && dPos(1, 1) < dXLim(2) && ...
   dPos(1, 2) >= dYLim(1) && dPos(1, 2) < dYLim(2)
    
    obj.setViews(dPos(1,1:2));
    drawnow
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Hide and disable the utility axes

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Fade out and hide the utility axes
dAlphaData = get(obj.SImgs.hUtil, 'AlphaData');
dAlphaData = double(dAlphaData > 0.6);
for dAlpha = 0.8:-0.1:0
    set(obj.SImgs.hUtil, 'AlphaData', dAlpha.*dAlphaData);
    drawnow update
    pause(0.01);
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Disable util axes
set(obj.SImgs.hUtil, 'Visible', 'off');
set(obj.hF, 'WindowButtonMotionFcn', @obj.mouseMove, 'WindowButtonDownFcn', '');
% -------------------------------------------------------------------------