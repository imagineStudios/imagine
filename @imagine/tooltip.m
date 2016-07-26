function tooltip(obj, sString, eventdata)

dTOOLTIPSCALING         = 12;

% -------------------------------------------------------------------------
% Create the image of the tooltip
persistent dMaskBorder dBackground

if isempty(dMaskBorder)
    sPath = mfilename('fullpath');
    sPath = fileparts(sPath);
    [~, ~, dMaskBorder] = imread([sPath, filesep, 'icons', filesep, 'tooltip_mask.png']);
    dMaskBorder = double(dMaskBorder)/255;
end

iTOOLTIPHEIGHT = size(dMaskBorder, 1);

if isempty(dBackground)
    dBackground = [linspace(60, 70, 20), linspace(30, 40, 20)]' + 5.*rand(40, 1);
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Determine wether to show or hide the tooltip. isobject() and isstring()
% are used, so timer callback can be directly assigned to this function.
if isempty(sString) || isobject(sString(1)) || ishandle(sString(1)) 
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Hide the tooltip
    if strcmp(get(obj.STooltip.hImg, 'Visible'), 'on')
        stop(obj.STimers.hToolTip);
        set([obj.STooltip.hImg obj.STooltip.hText],  'Visible', 'off');
        set(obj.STooltip.hText, 'String', '');
    end
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Hide the scatters and restore the text visibility
    for iView = 1:numel(obj.SView)
        set(obj.SView(iView).hScatter, 'Visible', 'off');
%         set(obj.SView(iView).hText(2, 1, :), 'Visible', 'on');
    end
    
else
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Show the tooltip
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Make sure tooltip is on to and restart timers
    stop(obj.STimers.hToolTip);
    start(obj.STimers.hToolTip);
    if ~strcmp(get(obj.STooltip.hText, 'String'), sString)
        
        iWidth = round(length(sString).*dTOOLTIPSCALING) + 20;
        dFigureSize = get(obj.hF, 'Position');
        dFigureSize(3) = dFigureSize(3) + 2.*obj.iIconSize - obj.iSidebarWidth;
        dFigureSize(4) = dFigureSize(4) - 2.*obj.iIconSize;
        
%         if strcmp(get(obj.STooltip.hImg, 'Visible'), 'off')
            set(obj.STooltip.hAxes, 'Position', [(dFigureSize(3) - iWidth)/2, ...
                0.618.*dFigureSize(4) - iTOOLTIPHEIGHT/2, ... % Awww... the golden ratio!
                iWidth, iTOOLTIPHEIGHT], ...
                'XLim', [0.5, iWidth + 0.5], ...
                'YLim', [0.5, iTOOLTIPHEIGHT + 0.5]);
%         end
        
        set(obj.STooltip.hText, 'String', sString, 'Position', ...
            [iWidth/2, iTOOLTIPHEIGHT*0.55], 'Visible', 'on');
        
        dMask = 0.75.*[dMaskBorder, ones(iTOOLTIPHEIGHT, iWidth - 2*size(dMaskBorder, 2)), flip(dMaskBorder, 2)];
        dImg = repmat(dBackground, [1, iWidth]);
        
        set(obj.STooltip.hImg, 'CData', dImg, 'AlphaData', dMask, 'Visible', 'on');
    end
    
end
% -------------------------------------------------------------------------