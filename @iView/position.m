function position(obj, ~, ~)
% imagine.POSITION Responsisble for positioning the contents of the views
% correctly.

% Lookup to make setting the axes directions more convenient
csDirs = {'normal', 'reverse'};

dAxesPos = get(obj.hA, 'Position');

% Find the visible axes with the minimum resolution and use this as the
% definition of 100 %
if ~isempty(obj.hData)
    dRes = obj.hData(1).Res;
    dMinRes = min(dRes);
else
    dMinRes = 1;
end

% dRes = min(obj.SData(SView.iData).dRes([1 2 4]));

if ~isempty(obj.hData)
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Panel not empty
    iDim = obj.hData(1).Dims(obj.iDimInd, :);
    % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
    % Determine the limits of x- and y-axes
    dDelta_phys = dAxesPos([4, 3])./obj.Zoom * dMinRes;
    
    set(obj.hA, 'XLim', obj.DrawCenter(iDim(2)) + 0.5 * [-dDelta_phys(2) dDelta_phys(2)], ...
                'YLim', obj.DrawCenter(iDim(1)) + 0.5 * [-dDelta_phys(1) dDelta_phys(1)]);, ...
%                 'XDir', csDirs{ obj.hData(1).lInvert(iDim(2)) + 1}, ...
%                 'YDir', csDirs{~obj.hData(1).lInvert(iDim(1)) + 1});
    
else
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Panel is empty
    dSize = dAxesPos([4 3]);
    dLim = 16./max(dSize).*dSize;
    set(obj.hA, 'XLim', 8 + 0.5*[-dLim(2) dLim(2)] + 0.5, ...
                'YLim', 8 + 0.5*[-dLim(1) dLim(1)] + 0.5, ...
                'XDir', 'normal', 'YDir', 'reverse');
    
end






