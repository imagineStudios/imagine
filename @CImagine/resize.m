function resize(obj, hObject, ~)
%RESIZE Arranges all the contens of the GUI

% -------------------------------------------------------------------------
% Get size of the figure
dFigureSize   = get(obj.hF, 'Position');
dFigureWidth  = dFigureSize(3);
dFigureHeight = dFigureSize(4);
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% If triggered by the timer, check if icons have to be resized
if isa(hObject, 'timer')
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Determine the desired size according to figure dimensions
    iNMenuIcons = nnz([obj.SMenu.GroupIndex] < 255 & [obj.SMenu.SubGroupInd] == 0) + 3;
    iNTools = nnz([obj.SMenu.GroupIndex] == 255) + 1.2;
    iSize = min(48, round(dFigureWidth./iNMenuIcons));
    iSize = min(iSize, round(dFigureHeight./iNTools));
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Resize if necessary
    if iSize ~= obj.iIconSize
        obj.iIconSize = max(24, iSize);
        obj.updateActivation; % Rescales the icons if necessary
    end
    stop(obj.STimers.hIcons);
elseif isa(hObject, 'matlab.ui.Figure')
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Origin is figure (user is resizing) -> start timer to check for icon resizing
    if strcmp(get(obj.hF, 'Visible'), 'on');
        stop(obj.STimers.hIcons);
        start(obj.STimers.hIcons);
    end
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Arrange the imagine elements

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% MenuBar
dMenubarHeight = obj.iIconSize;
dContentsHeight = dFigureHeight - dMenubarHeight;
set(obj.SAxes.hMenu,  ...
    'Position'      , [0, dFigureHeight - obj.iIconSize + 1 - 4, dFigureWidth + 1, dMenubarHeight + 4], ...
    'XLim'          , [0 dFigureWidth + 1] + 0.5, ...
    'YLim'          , [0 obj.iIconSize + 4] + 0.5);

dCData = repmat(permute(obj.SColors.bg_normal, [1 3 2]), obj.iIconSize + 4, 1);
dCData(obj.iIconSize + 1:end, :, :) = 0;
dAlpha = ones(obj.iIconSize + 4, 1);
dAlpha(obj.iIconSize + 1:obj.iIconSize + 4) = [0.7; 0.5; 0.3; 0.0];
set(obj.SImgs.hMenu, ...
  'CData'       , dCData, ...
  'AlphaData'   , dAlpha);
  

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Toolbar
dToolbarWidth = obj.iIconSize;
set(obj.SAxes.hTools, ...
    'Position'      , [0, 1, dToolbarWidth, dFigureHeight - obj.iIconSize], ...
    'XLim'          , [0 obj.iIconSize] + 0.5, ...
    'YLim'          , [0 dFigureHeight - obj.iIconSize] + 0.5);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Dock button
lInd = strcmp({obj.SMenu.Name}, 'dock');
set(obj.SImgs.hIcons(lInd), 'XData', 1 + dFigureWidth - obj.iIconSize);
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Arrange the views
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Get the origins, widths and heights of each view's axes
iX = round(iGlobals.fNonLinSpace(dToolbarWidth + 1, dFigureWidth + 1, obj.dColWidth(1:obj.iAxes(1))));
iY = round(iGlobals.fNonLinSpace(dContentsHeight + 1, 1, obj.dRowHeight(1:obj.iAxes(2))));
[iXX, iYY] = meshgrid(iX, iY);
iXXStart = iXX(1:end - 1, 1:end - 1)';
iXXWidth = diff(iXX(1:end-1, :), 1, 2)' - 1;
iYYStart = iYY(2:end, 1:end - 1)';
iYYHeight = - diff(iYY(:, 1:end - 1), 1, 1)' - 1;

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Update the views
obj.hViews.setPosition(iXXStart, iYYStart, iXXWidth, iYYHeight);
obj.hViews.showSquare;
% -------------------------------------------------------------------------

