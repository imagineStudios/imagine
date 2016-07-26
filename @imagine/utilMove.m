function utilMove(obj, ~, ~)

dPos = round(get(obj.SAxes.hUtil, 'CurrentPoint'));
dXLim = get(obj.SAxes.hUtil, 'XLim') + 0.5;
dYLim = get(obj.SAxes.hUtil, 'YLim') + 0.5;

if dPos(1, 1) >= dXLim(1) && dPos(1, 1) < dXLim(2) && ...
   dPos(1, 2) >= dYLim(1) && dPos(1, 2) < dYLim(2)
    
    switch get(obj.SImgs.hUtil, 'UserData')
        
        % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        % Case 1: Determine the number of views
        case 1
            dMask = ones(obj.iMAXVIEWS).*0.5;
            dMask(1:dPos(1, 2), 1:dPos(1, 1)) = 0.8;
            set(obj.SImgs.hUtil, 'AlphaData', dMask);
            
            % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
            % Case 2: Select the colormap
        case 2
            iSize = size(get(obj.SImgs.hUtil, 'CData'));
            dMask = ones(iSize(1:2)).*0.5;
            dMask(dPos(1, 2), :) = 0.9;
            dMask = dMask(1:iSize(1), 1:iSize(2));
            
            csColormaps = obj.getColormaps;
            obj.tooltip(csColormaps{dPos(1, 2)});
            set(obj.SImgs.hUtil, 'AlphaData', dMask);
            
        otherwise
            
    end
    
end
% ---------------------------------------------------------------------