function position(obj, ~, ~)
% imagine.POSITION Responsisble for positioning the contents of the views
% correctly.

for iI = 1:length(obj)
    
    hView = obj(iI);
    
    for iJ = 1:length(hView.hA)
        
        dAxesPos = get(hView.hA(iJ), 'Position');
        
        % dRes = min(hView.SData(SView.iData).dRes([1 2 4]));
        
        if ~isempty(hView.hData)
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Panel not empty
            csDirs = {'normal', 'reverse'};
            dMinRes = min(hView.hData(1).Res);
            iDim = hView.hData(1).Dims(1, :);
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Determine the limits of x- and y-axes
            dDelta_phys = dAxesPos([4, 3])./hView.Zoom * dMinRes;
            
            dXLim_mm = hView.DrawCenter(iDim(2)) + 0.5 * [-dDelta_phys(2) dDelta_phys(2)];
            dYLim_mm = hView.DrawCenter(iDim(1)) + 0.5 * [-dDelta_phys(1) dDelta_phys(1)];
            
            set(hView.hA, 'XLim', dXLim_mm, 'YLim', dYLim_mm, ...
                'XDir', csDirs{ hView.hData(1).Invert(iDim(2)) + 1}, ...
                'YDir', csDirs{~hView.hData(1).Invert(iDim(1)) + 1});
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Draw the color marker in the top-left corner
            if hView.hData(1).Invert(iDim(1))
                dYData = dYLim_mm(2) - 10.*diff(dYLim_mm)./dAxesPos(4);
            else
                dYData = dYLim_mm(1) + 10.*diff(dYLim_mm)./dAxesPos(4);
            end
            if hView.hData(1).Invert(iDim(2))
                dXData = dXLim_mm(2) - 10.*diff(dXLim_mm)./dAxesPos(3);
            else
                dXData = dXLim_mm(1) + 10.*diff(dXLim_mm)./dAxesPos(3);
            end
            
            set(hView.hS, 'XData', dXData, 'YData', dYData);
            
        else
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Panel is empty
            dSize = dAxesPos([4 3]);
            dLim = 16./max(dSize).*dSize;
            set(hView.hA(iJ), 'XLim', 8 + 0.5*[-dLim(2) dLim(2)] + 0.5, ...
                'YLim', 8 + 0.5*[-dLim(1) dLim(1)] + 0.5, ...
                'XDir', 'normal', 'YDir', 'reverse');
            
        end
    end
end

