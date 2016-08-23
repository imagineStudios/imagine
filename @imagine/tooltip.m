function tooltip(obj, sString, ~)

dTOOLTIPSCALING = 12; % Empirical factor to scale from letter count to width in px

% -------------------------------------------------------------------------
% Create the image and alpha mask for the tooltip
persistent dBGMask dBGImg

if isempty(dBGImg)
    dBGImg = [linspace(60, 70, 20), linspace(30, 40, 20)]' + 5.*rand(40, 1);
end

if isempty(dBGMask)
    sPath = mfilename('fullpath');
    sPath = fileparts(sPath);
    [~, ~, dBGMask] = imread([sPath, filesep, 'icons', filesep, 'tooltip_mask.png']);
    dBGMask = double(dBGMask)/255;
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
    obj.hViews.showSquare;
    
else
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Show the tooltip (if no change has ocurred)
    if ~strcmp(get(obj.STooltip.hText, 'String'), sString)
        
        % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        % Determine the position in the figure
        iWidth = round(length(sString).*dTOOLTIPSCALING) + 20;
        dHeight = size(dBGMask, 1);
        dFigureSize = get(obj.hF, 'Position');
        dXPos = (dFigureSize(3) + 2.*obj.iIconSize - obj.iSidebarWidth - iWidth)/2;
        dYPos = 0.618.*(dFigureSize(4) - 2.*obj.iIconSize) - dHeight/2; % Awww... the golden ratio!
        set(obj.STooltip.hAxes, ...
            'Position'  , [dXPos, dYPos, iWidth, dHeight], ...
            'XLim'      , [0.5, iWidth + 0.5], ...
            'YLim'      , [0.5, dHeight + 0.5]);
        
        % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        % Update the image data and the alpha mask
        dMask = 0.75.*[dBGMask, ones(dHeight, iWidth - 2*size(dBGMask, 2)), flip(dBGMask, 2)];
        dImg = repmat(dBGImg, [1, iWidth]);
        set(obj.STooltip.hImg, 'CData', dImg, 'AlphaData', dMask, 'Visible', 'on');
        
        % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        % Update the text
        set(obj.STooltip.hText, 'String', sString, 'Position', ...
            [iWidth/2, dHeight*0.55], 'Visible', 'on');
    end
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % restart timers
    stop(obj.STimers.hToolTip);
    start(obj.STimers.hToolTip);
    
end
% -------------------------------------------------------------------------