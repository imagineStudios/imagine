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
    iNMenuIcons = nnz([obj.SMenu.GroupIndex] < 255 & [obj.SMenu.SubGroupInd] == 0) + 3;
    iNTools = nnz([obj.SMenu.GroupIndex] == 255) + 1.2;
    iSize = min(48, round(dFigureWidth./iNMenuIcons));
    iSize = min(iSize, round(dFigureHeight./iNTools));
    obj.iIconSize = max(24, iSize);
    obj.updateActivation;
    stop(obj.STimers.hIcons);
elseif isa(hObject, 'matlab.ui.Figure')
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Timer logic
    if strcmp(get(obj.hF, 'Visible'), 'on');
        stop(obj.STimers.hIcons);
        start(obj.STimers.hIcons);
    end
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Arrange the views

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Determine the view arrangement
iCols = size(obj.hViews, 1);
iRows = size(obj.hViews, 2);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Get the relative widths and heights of the views
dWidth  = obj.dColWidth(1:iCols);
dWidth  = dWidth./sum(dWidth);
dHeight = obj.dRowHeight(1:iRows);
dHeight = dHeight./sum(dHeight);

iAllViewHeight = dFigureHeight - obj.iIconSize - 2;
iAllViewWidth  = dFigureWidth  - obj.iIconSize - 1 - obj.iSidebarWidth;

iYStart = 2;
for iY = iRows:-1:1 % Start from the bottom
    
    if iY > 1
        iHeight = round(iAllViewHeight.*dHeight(iY));
    else
        % Flush 
        iHeight = dFigureHeight - iYStart - obj.iIconSize;
    end
    
    iXStart = obj.iIconSize + 1;
    for iX = 1:iCols
        if iX == iCols
            iWidth = dFigureWidth - iXStart - obj.iSidebarWidth - (obj.iSidebarWidth > 0);
        else
            iWidth = round(iAllViewWidth.*dWidth(iX));
        end
        obj.hViews(iX, iY).Position = [iXStart + obj.lRuler.*20, iYStart, iWidth - obj.lRuler.*20, iHeight - obj.lRuler.*20];
        iXStart = iXStart + iWidth;
    end
    iYStart = iYStart + iHeight;
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Arrange the remaining elements

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% MenuBar
set(obj.SAxes.hMenu,  'Position', [0, dFigureHeight - obj.iIconSize + 1, dFigureWidth + 1, obj.iIconSize], ...
    'XLim', [0 dFigureWidth + 1] + 0.5, 'YLim', [0 obj.iIconSize] + 0.5);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Toolbar
set(obj.SAxes.hTools, 'Position', [0, 1, obj.iIconSize, dFigureHeight - obj.iIconSize], ...
    'XLim', [0 obj.iIconSize] + 0.5, 'YLim', [0 dFigureHeight - obj.iIconSize] + 0.5);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Dock button
lInd = strcmp({obj.SMenu.Name}, 'dock');
set(obj.SImgs.hIcons(lInd), 'XData', 1 + dFigureWidth - obj.iIconSize);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Sidebar
set(obj.SSidebar.hPanel, 'Position', [dFigureWidth - obj.iSidebarWidth, 2, max(1, obj.iSidebarWidth), iAllViewHeight]);
set(obj.SSidebar.hAxes,  'Position', [1, iAllViewHeight - 190, 256, 192]);
set(obj.SSidebar.hIcons, 'Position', [2, iAllViewHeight - 190 - 32, 192, 32], 'XLim', [0 192] + 0.5, 'YLim', [0 32] + 0.5);
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Draw!
% obj.position;
% obj.grid;
% -------------------------------------------------------------------------
