function position(obj)
% imagine.POSITION Responsisble for positioning the contents of the views
% correctly.

if isempty(obj.SView), return, end

% Lookup to make setting the axes directions more convenient
csDirs = {'normal', 'reverse'};

cAxesPos = get([obj.SView.hAxes], 'Position');

% Find the visible axes with the minimum resolution and use this as the
% definition of 100 %
iVisibleData = unique([obj.SView.iData]);
iVisibleData = iVisibleData(iVisibleData > 0);
if ~isempty(iVisibleData)
    dRes = [obj.SData(iVisibleData).dRes];
    dRes = dRes(:, [1 2 4]);
    dRes = min(dRes);
else
    dRes = 1;
end

% dRes = min(obj.SData(SView.iData).dRes([1 2 4]));

for iView = 1:numel(obj.SView)
    
    SView = obj.SView(iView);
    if SView.iData
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Panel not empty
        iDim = obj.SData(SView.iData(1)).iDims(SView.iDimInd, :);
        
        % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        % Determine the limits of x- and y-axes
        
        if iscell(cAxesPos)
            dAxesPos = cAxesPos{iView};
        else
            dAxesPos = cAxesPos;
        end
        dDelta_mm = dAxesPos([4, 3])./obj.SData(SView.iData(1)).dZoom * dRes;
        
        set(SView.hAxes, 'XLim', obj.SData(SView.iData(1)).dDrawCenter(iDim(2)) + 0.5 * [-dDelta_mm(2) dDelta_mm(2)], ...
                         'YLim', obj.SData(SView.iData(1)).dDrawCenter(iDim(1)) + 0.5 * [-dDelta_mm(1) dDelta_mm(1)], ...
                         'XDir', csDirs{obj.SData(SView.iData(1)).lInvert(iDim(2)) + 1}, ...
                         'YDir', csDirs{~obj.SData(SView.iData(1)).lInvert(iDim(1)) + 1});
        
    else
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Panel is empty
        
        dAxesPos = get(SView.hAxes, 'Position');
        dSize = dAxesPos(4:-1:3);
        dLim = 16./max(dSize).*dSize;
        set(SView.hAxes, 'XLim', 8 + 0.5*[-dLim(2) dLim(2)] + 0.5, ...
                         'YLim', 8 + 0.5*[-dLim(1) dLim(1)] + 0.5);
        
%         set(SView.hAxes, 'XLim', [0 1], 'YLim', [0 1], 'XDir', 'normal', 'YDir', 'normal');
        
    end
    
end





