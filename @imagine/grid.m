function grid(obj)

dGridSpacing = get(obj.SSliders(3).hScatter, 'XData');

% -------------------------------------------------------------------------
% If the grid serves as a temporary crosshair, reset and start the timer
% for undoing this
if obj.dGrid == -1
    stop(obj.STimers.hGrid);
    start(obj.STimers.hGrid);
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
for iView = 1:numel(obj.oView)
    
    SView = obj.SView(iView);
    
    if ~isempty(SView.iData)
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Handle the grid visibility
        if obj.dGrid ~= 0
            set(SView.hAxes, 'XGrid', 'on', 'YGrid', 'on');
            if obj.dGrid > 0
                set(SView.hAxes, 'XMinorGrid', 'on', 'YMinorGrid', 'on');
            else
                set(SView.hAxes, 'XMinorGrid', 'off', 'YMinorGrid', 'off');
            end
        else
            set(SView.hAxes, 'XGrid', 'off', 'YGrid', 'off', ...
                             'XMinorGrid', 'off', 'YMinorGrid', 'off', ...
                             'XTick', [], 'YTick', []);
        end
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Determine the position of the grid ticks and labels
        if obj.dGrid ~= 0 || obj.lRuler
            
            if obj.dGrid == -1
                % -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
                % This is the crosshair case
                iDim = obj.SData(SView.iData(1)).iDims(SView.iDimInd, :);
                dCoord_mm = obj.SData(SView.iData(1)).dDrawCenter(iDim);
                set(SView.hAxes, 'XTick', dCoord_mm(2), 'YTick', dCoord_mm(1), ...
                    'XTickLabel', {}, 'YTickLabel', {});
                
            else
                % -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
                % The standard grid
                
                % -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
                % Set the ticks
                dXLim = get(SView.hAxes, 'XLim');
                dYLim = get(SView.hAxes, 'YLim');
                dXTick = floor(dXLim(1)/dGridSpacing)*dGridSpacing:dGridSpacing:ceil(dXLim(2)/dGridSpacing)*dGridSpacing;
                dYTick = floor(dYLim(1)/dGridSpacing)*dGridSpacing:dGridSpacing:ceil(dYLim(2)/dGridSpacing)*dGridSpacing;
                set(SView.hAxes, 'XTick', dXTick + 0.5, 'YTick', dYTick + 0.5);
                
                % -   -   -   -   -   -   -   -   -   -   -   -   -   -   -
                % Set the tick labels
                if obj.lRuler
                    dViewSize = get(SView.hAxes, 'Position');
                    dXLim = get(SView.hAxes, 'XLim');
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
                    
                    dYTick = get(SView.hAxes, 'YTick') - 0.5;
                    sYLabels = cell(size(dYTick));
                    for iI = 1:length(dYTick)
                        if ~mod(round(dYTick(iI)/dGridSpacing), iMod)
                            sYLabels{iI} = sprintf('%d', round(dYTick(iI)));
                        else
                            sYLabels{iI} = '';
                        end
                    end
                    
                    set(SView.hAxes, 'XTickLabel', sXLabels, 'YTickLabel', sYLabels);
                else
                    set(SView.hAxes, 'XTickLabel', {}, 'YTickLabel', {});
                end
            end
            
        end
        
    else
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Empty axes
        set(SView.hAxes, ...
            'XGrid'         , 'off', ...
            'YGrid'         , 'off', ...
            'XMinorGrid'    , 'off', ...
            'YMinorGrid'    , 'off', ...
            'XTick'         , [], ...
            'YTick'         , [], ...
            'XTickLabel'    , {}, ...
            'YTickLabel'    , {});
    end
end
% -------------------------------------------------------------------------








