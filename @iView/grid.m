function grid(obj)

dGridSpacing = obj(1).hParent.getSlider('Grid Spacing');
dGrid = obj(1).hParent.dGrid;
lRuler = obj(1).hParent.lRuler;

% -------------------------------------------------------------------------
% If the grid serves as a temporary crosshair, reset and start the timer
% for undoing this
if dGrid == -1
    stop(obj(1).hParent.STimers.hGrid);
    start(obj(1).hParent.STimers.hGrid);
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
for iView = 1:numel(obj)
    
    o = obj(iView);
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Handle the grid visibility
    if isempty(o.hData) || (dGrid == 0 && ~lRuler)
        set(o.hA, ...
            'XGrid'         , 'off', ...
            'YGrid'         , 'off', ...
            'XMinorGrid'    , 'off', ...
            'YMinorGrid'    , 'off', ...
            'XTick'         , [], ...
            'YTick'         , [], ...
            'XTickLabel'    , {}, ...
            'YTickLabel'    , {});
        continue
    end
    
    set(o.hA, 'XGrid', 'on', 'YGrid', 'on');
    if dGrid > 0
        set(o.hA, 'XMinorGrid', 'on', 'YMinorGrid', 'on');
    else
        set(o.hA, 'XMinorGrid', 'off', 'YMinorGrid', 'off');
    end
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Determine the position of the grid ticks and labels
    for iDimInd = 1:length(o.hA)
        
        if dGrid == -1
            % -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
            % This is the crosshair case
            iDim = o.hData(1).Dims(iDimInd, :);
            dCoord_mm = o.DrawCenter(iDim);
            set(o.hA(iDimInd), 'XTick', dCoord_mm(2), 'YTick', dCoord_mm(1), ...
                'XTickLabel', {}, 'YTickLabel', {});
            
        else
            % -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
            % The standard grid
            
            % -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
            % Set the ticks
            dXLim = get(o.hA(iDimInd), 'XLim');
            dYLim = get(o.hA(iDimInd), 'YLim');
            dXTick = floor(dXLim(1)/dGridSpacing)*dGridSpacing:dGridSpacing:ceil(dXLim(2)/dGridSpacing)*dGridSpacing;
            dYTick = floor(dYLim(1)/dGridSpacing)*dGridSpacing:dGridSpacing:ceil(dYLim(2)/dGridSpacing)*dGridSpacing;
            set(o.hA(iDimInd), 'XTick', dXTick + 0.5, 'YTick', dYTick + 0.5);
            
            % -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
            % Set the tick labels
            if lRuler
                dViewSize = get(o.hA(iDimInd), 'Position');
                dXLim = get(o.hA(iDimInd), 'XLim');
                dPixelsPerTick = dViewSize(3)./diff(dXLim).*dGridSpacing;
                iMod = ceil(30/dPixelsPerTick);
                sXLabels = cell(size(dXTick));
                for iI = 1:length(dXTick)
                    if ~mod(round(dXTick(iI)/dGridSpacing), iMod)
                        sXLabels{iI} = sprintf('%d', round(dXTick(iI)));
                    else
                        sXLabels{iI} = '';
                    end
                end
                
                dYTick = get(o.hA(iDimInd), 'YTick') - 0.5;
                sYLabels = cell(size(dYTick));
                for iI = 1:length(dYTick)
                    if ~mod(round(dYTick(iI)/dGridSpacing), iMod)
                        sYLabels{iI} = sprintf('%d', round(dYTick(iI)));
                    else
                        sYLabels{iI} = '';
                    end
                end
                
                set(o.hA(iDimInd), 'XTickLabel', sXLabels, 'YTickLabel', sYLabels);
            else
                set(o.hA(iDimInd), 'XTickLabel', {}, 'YTickLabel', {});
            end
        end
        
    end
    
end
% -------------------------------------------------------------------------








