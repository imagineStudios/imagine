function setViewMapping(obj)

dColors = lines(64);

for iView = 1:numel(obj.SView)
    
    % -------------------------------------------------------------------------
    % Determine data source and image orientation for current view
    if ~obj.isOn('2d')
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Layer view: Each view has its own series
        iMappingInd = obj.iStartSeries + iView - 1;
        obj.SView(iView).iDimInd = 1;
    else
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % 3D view: each series occupies 3 views (all 3 orientations)
        iMappingInd = obj.iStartSeries + ceil(iView./3) - 1;
        obj.SView(iView).iDimInd = mod(iView - 1, 3) + 1;
    end
    
    iNImg = 0;
    iNQuiver = 0;
    
    if iMappingInd <= length(obj.cMapping)
        obj.SView(iView).iData = obj.cMapping{iMappingInd};
        
        for iI = 1:length(obj.SView(iView).iData)
            if strcmp(obj.SData(obj.SView(iView).iData(iI)).sMode, 'vector')
                iNQuiver = iNQuiver + 1;
            else
                iNImg = iNImg + 1;
            end
        end
        
    else
        obj.SView(iView).iData = [];
    end
    
    iNImg = max(1, iNImg);
    
    if iNQuiver > 1
        obj.close;
        error('Only one quiver per view supported!');
    end
    
    if iNImg > length(obj.SView(iView).hImg)
        for iI = length(obj.SView(iView).hImg) + 1:iNImg
            obj.SView(iView).hImg(iI) = image( ...
                'Parent'                , obj.SView(iView).hAxes, ...
                'CData'                 , zeros(1, 1, 3), ...
                'HitTest'               , 'off');
        end
    end
    
    if iNImg < length(obj.SView(iView).hImg)
        delete(obj.SView(iView).hImg(iNImg + 1:end));
        obj.SView(iView).hImg = obj.SView(iView).hImg(1:iNImg);
    end
    
    if iNQuiver > length(obj.SView(iView).hQuiver)
        obj.SView(iView).hQuiver = line(0, 0, ...
            'Parent'                , obj.SView(iView).hAxes, ...
            'Visible'               , 'off', ...
            'Hittest'               , 'off');
        obj.SView(iView).hQuiver.Color(4) = 0.3;
    end
    
    if iNQuiver < length(obj.SView(iView).hQuiver)
        delete(obj.SView(iView).hQuiver(iNQuiver + 1:end));
        obj.SView(iView).hQuiver = obj.SView(iView).hQuiver(1:iNImg);
    end
    
    if iNImg || iNQuiver
        
        % Create the auxiliary components if necessary
        if isempty(obj.SView(iView).hLine)
            obj.SView(iView).hLine(1) = line(0, 0, ...
                'Parent'                , obj.SView(iView).hAxes, ...
                'Color'                 , 'w', ...
                'Visible'               , 'off');
            obj.SView(iView).hLine(2) = line(0, 0, ...
                'Parent'                , obj.SView(iView).hAxes, ...
                'Color'                 , dColors(iMappingInd,:), ...
                'Marker'                , 's', ...
                'MarkerFaceColor'       , dColors(iMappingInd,:), ...
                'LineStyle'             , '-.', ...
                'Visible'               , 'off');
            try set(obj.SView(iView).hLine, 'AlignVertexCenters', 'on'); end
            
            obj.SView(iView).hScatter = scatter(0, 0, 10, 's', ...
                'Parent'                , obj.SView(iView).hAxes, ...
                'MarkerEdgeColor'       , 'none', ...
                'Visible'               , 'off', ...
                'Hittest'               , 'off');
            
            for iI = 1:8
                obj.SView(iView).hText(iI) = text(1, 1, '', ...
                    'Parent'                , obj.SView(iView).hAxes, ...
                    'Units'                 , 'pixels', ...
                    'FontSize'              , 14, ...
                    'Hittest'               , 'off');
            end
            obj.SView(iView).hText = reshape(obj.SView(iView).hText, [2 2 2]);
            set(obj.SView(iView).hText(:, :, 1), 'Color', 'k');
            set(obj.SView(iView).hText(:, :, 2), 'Color', 'w');
            set(obj.SView(iView).hText(:, 1, :), 'HorizontalAlignment', 'left');
            set(obj.SView(iView).hText(:, 2, :), 'HorizontalAlignment', 'right');
            set(obj.SView(iView).hText(1, :, :), 'VerticalAlignment', 'top');
            set(obj.SView(iView).hText(2, :, :), 'VerticalAlignment', 'bottom');
            set(obj.SView(iView).hText(2, 1, 1),  'Position', [10, 10]);
            set(obj.SView(iView).hText(2, 1, 2),  'Position', [9, 11]);
        end
    else
        delete(obj.SView(iView).hLine);      obj.SView(iView).hLine = [];
        delete(obj.SView(iView).hScatter);   obj.SView(iView).hScatter = [];
        delete(obj.SView(iView).hText(:));      obj.SView(iView).hText = [];
    end
    % -------------------------------------------------------------------------
    
end