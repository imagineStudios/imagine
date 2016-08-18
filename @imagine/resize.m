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
    'Position'      , [0, dFigureHeight - obj.iIconSize + 1, dFigureWidth + 1, dMenubarHeight], ...
    'XLim'          , [0 dFigureWidth + 1] + 0.5, ...
    'YLim'          , [0 obj.iIconSize] + 0.5);

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

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Sidebar
set(obj.SSidebar.hPanel, 'Position', [dFigureWidth - obj.iSidebarWidth, 2, max(1, obj.iSidebarWidth), dContentsHeight]);
set(obj.SSidebar.hAxes,  'Position', [1, dContentsHeight - 190, 256, 192]);
set(obj.SSidebar.hIcons, 'Position', [2, dContentsHeight - 190 - 32, 192, 32], 'XLim', [0 192] + 0.5, 'YLim', [0 32] + 0.5);
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Arrange the views
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Get the origins, widths and heights of each view's axes
iX = round(fNonLinSpace(dToolbarWidth + 1, dFigureWidth + 1, obj.dColWidth(1:obj.iAxes(1))));
iY = round(fNonLinSpace(dContentsHeight + 1, 1, obj.dRowHeight(1:obj.iAxes(2))));
[iXX, iYY] = meshgrid(iX, iY);
iXXStart = iXX(1:end - 1, 1:end - 1)';
iXXWidth = diff(iXX(1:end-1, :), 1, 2)' - 1;
iYYStart = iYY(2:end, 1:end - 1)';
iYYHeight = - diff(iYY(:, 1:end - 1), 1, 1)' - 1;

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Update the views
obj.hViews.setPosition(iXXStart, iYYStart, iXXWidth, iYYHeight);
% -------------------------------------------------------------------------





function dPos = fNonLinSpace(dStart, dEnd, dRelDistance)

dInt = cumsum(dRelDistance./sum(dRelDistance));
dPos = [dStart, (dEnd - dStart).*dInt + dStart];
