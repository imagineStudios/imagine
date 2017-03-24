function resize(obj, ~, ~)

% -------------------------------------------------------------------------
% Get size of the figure
dFigureSize   = get(obj.hF, 'Position');
dFigureWidth  = dFigureSize(3);
dFigureHeight = dFigureSize(4);
% -------------------------------------------------------------------------

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% MenuBar
set(obj.hA, ...
    'Position'  , [0, dFigureHeight - 64 + 1, dFigureWidth + 1, 64], ...
    'XLim'      , [0 dFigureWidth + 1] + 0.5, ...
    'YLim'      , [0 64] + 0.5);

iX = zeros(size(obj.hPanels)) + 1;
iY = 1 + obj.iPANELHEIGHT.*(0:length(obj.hPanels) - 1);
iWidth  = zeros(size(obj.hPanels)) + dFigureWidth;
iHeight = zeros(size(obj.hPanels)) + obj.iPANELHEIGHT;

obj.hPanels.setPosition(iX, iY, iWidth, iHeight);