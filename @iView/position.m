function position(obj, ~, ~)
% imagine.POSITION Responsisble for positioning the contents of the views
% correctly.

% Lookup to make setting the axes directions more convenient
csDirs = {'normal', 'reverse'};

dAxesPos = get(obj.hA, 'Position');

% Find the visible axes with the minimum resolution and use this as the
% definition of 100 %
% iVisibleData = unique([obj.SView.iData]);
% iVisibleData = iVisibleData(iVisibleData > 0);
% if ~isempty(iVisibleData)
%     dRes = [obj.SData(iVisibleData).dRes];
%     dRes = dRes(:, [1 2 4]);
%     dRes = min(dRes);
% else
%     dRes = 1;
% end

% dRes = min(obj.SData(SView.iData).dRes([1 2 4]));

if ~isempty(obj.iData)
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Panel not empty
    iDim = obj.SData(SView.iData(1)).iDims(SView.iDimInd, :);
    
    % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
    % Determine the limits of x- and y-axes
    
    dDelta_mm = dAxesPos([4, 3])./obj.SData(SView.iData(1)).dZoom * dRes;
    
    set(SView.hAxes, 'XLim', obj.SData(SView.iData(1)).dDrawCenter(iDim(2)) + 0.5 * [-dDelta_mm(2) dDelta_mm(2)], ...
        'YLim', obj.SData(SView.iData(1)).dDrawCenter(iDim(1)) + 0.5 * [-dDelta_mm(1) dDelta_mm(1)], ...
        'XDir', csDirs{obj.SData(SView.iData(1)).lInvert(iDim(2)) + 1}, ...
        'YDir', csDirs{~obj.SData(SView.iData(1)).lInvert(iDim(1)) + 1});
    
else
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Panel is empty
    dSize = dAxesPos([4 3]);
    dLim = 16./max(dSize).*dSize;
    set(obj.hA, 'XLim', 8 + 0.5*[-dLim(2) dLim(2)] + 0.5, ...
                'YLim', 8 + 0.5*[-dLim(1) dLim(1)] + 0.5, ...
                'XDir', 'normal', 'YDir', 'reverse');
    
end






