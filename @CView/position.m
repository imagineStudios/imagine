function position(obj, ~, ~)
% iView.POSITION Responsisble for positioning the contents of the views correctly.

for iI = 1:length(obj)
    
    hView = obj(iI);
    
    for iDimInd = 1:length(hView.hA)
        
        dAxesPos = get(hView.hA(iDimInd), 'Position');
        
        if ~isempty(hView.hData)
            dMinRes = min(hView.hParent.dMinRes(1:3));
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Panel not empty
            csDirs = {'normal', 'reverse'};
            iDim = hView.hData(1).Dims(iDimInd, :);
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Determine the limits of x- and y-axes
            dDelta_phys = dAxesPos([4, 3])./hView.Zoom * dMinRes;
            
            dXLim_mm = hView.DrawCenter(iDim(2)) + 0.5 * [-dDelta_phys(2) dDelta_phys(2)];
            dYLim_mm = hView.DrawCenter(iDim(1)) + 0.5 * [-dDelta_phys(1) dDelta_phys(1)];
            
            set(hView.hA(iDimInd), 'XLim', dXLim_mm, 'YLim', dYLim_mm, ...
                'XDir', csDirs{ hView.hData(1).Invert(iDim(2)) + 1}, ...
                'YDir', csDirs{~hView.hData(1).Invert(iDim(1)) + 1});
                        
        else
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Panel is empty
            dSize = dAxesPos([4 3]);
            dLim = 16./max(dSize).*dSize;
            set(hView.hA(iDimInd), 'XLim', 8 + 0.5*[-dLim(2) dLim(2)] + 0.5, ...
                'YLim', 8 + 0.5*[-dLim(1) dLim(1)] + 0.5, ...
                'XDir', 'normal', 'YDir', 'reverse');
            
        end
    end
end

