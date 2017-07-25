function resize(obj, ~, ~)

% -------------------------------------------------------------------------
% Get size of the figure
dFigureSize   = get(obj.hF, 'Position');
dFigureWidth  = dFigureSize(3);
dFigureHeight = dFigureSize(4);
% -------------------------------------------------------------------------

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% ScrollPanel
obj.hScrollPanel.setPosition([1, 1, dFigureWidth - 1, dFigureHeight - 72 - 1]);


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% MenuBar
set(obj.hA, ...
    'Position'  , [0, dFigureHeight - 72 + 1 - 4, dFigureWidth + 1, 72 + 4], ...
    'XLim'      , [0 dFigureWidth + 1] + 0.5, ...
    'YLim'      , [0 72 + 4] + 0.5);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Panels  
% iX = zeros(size(obj.hPanels)) + 1 + 5;
% iY = 1 + (obj.iPANELHEIGHT + 5).*(0:length(obj.hPanels) - 1) + 5;
% iWidth  = zeros(size(obj.hPanels)) + dFigureWidth - 20;
% iHeight = zeros(size(obj.hPanels)) + obj.iPANELHEIGHT;

% obj.hPanels.setPosition(iX, iY, iWidth, iHeight);
obj.hPanels.setWidth(dFigureWidth - 30);