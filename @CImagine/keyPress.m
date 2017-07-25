function keyPress(obj, hObject, eventdata)

persistent lLoopDir
persistent lastTime

if isempty(lLoopDir)
    lLoopDir = false;
end
if isempty(lastTime)
    lastTime = -1;
end


% Zoom levels for the Cntl+/- commands
dZOOMFACTORS = [0.1 0.175 0.25 0.33 0.5 0.66 1 1.5 2 3 4 6 8 12 16 24 32];
% dSECOND = 1/(24*60*60);

% -------------------------------------------------------------------------
% Reduce key repetition rate to amout set by slider
% dFPS = obj.getSlider('Keyboard FPS');
% dDelay = dSECOND/dFPS;
% dNow = now;
% if dNow - lastTime < dDelay
%     return
% end
% lastTime = dNow;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Bail if only a modifier has been pressed. For some reason the mac command
% and fn keys are represented as '0'
if any(strcmp(eventdata.Key, {'shift', 'control', 'alt'})) || ...
        (strcmp(eventdata.Key, '0') && isempty(eventdata.Character))
    switch eventdata.Key
        case 'shift', obj.SAction.lShift = true;
        case 'control', obj.SAction.lControl = true;
        case 'alt', obj.SAction.lAlt = true;
    end
    return
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Get the modifier (shift, cntl, cmd, alt) keys
iModifier = 0;
if any(strcmp(eventdata.Modifier, 'shift'))         , iModifier = iModifier + 1; end;
if any(strcmp(eventdata.Modifier, 'control')) || ...
   any(strcmp(eventdata.Modifier, 'command'))       , iModifier = iModifier + 2; end;
if any(strcmp(eventdata.Modifier, 'alt'))           , iModifier = iModifier + 4; end;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Look for buttons with corresponding accelerators/modifiers and trigger
% their callback
iI = find(strcmp(eventdata.Key, {obj.SMenu.Accelerator}) & iModifier == [obj.SMenu.Modifier]);
if ~isempty(iI)
    obj.iconDown(obj.SMenu(iI).Name, eventdata);
    return
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Functions not implemented by buttons
switch iModifier
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % No modifier
    case 0
        switch eventdata.Key
            
            % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
            % Image up
            case 'uparrow'
                changeImg(obj, hObject, -1);
                
            % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -    
            % Image down
            case 'downarrow'
                changeImg(obj, hObject, 1);
                
            % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -    
            % Series up
            case 'leftarrow'
                
                lShift = obj.SAction.lShift;
                obj.SAction.lShift = true;
                changeImg(obj, hObject, -1);
                obj.SAction.lShift = lShift;
                
            % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -    
            % Series down
            case 'rightarrow'
                lShift = obj.SAction.lShift;
                obj.SAction.lShift = true;
                changeImg(obj, hObject, 1);
                obj.SAction.lShift = lShift;
                
            % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
            % Loop through series in a 1->end fashion
            case {'period', 'comma'}
                if isempty(obj.hViews(1).hData), return, end
                
                iNTime = obj.hViews(1).hData(1).getSize(4);
                if strcmp(eventdata.Key, 'period')
                    iT = mod(obj.hViews(1).DrawCenter(4), iNTime) + 1;
                else
                    if obj.hViews(1).DrawCenter(4) == 1, lLoopDir = true; end
                    if obj.hViews(1).DrawCenter(4) == iNTime, lLoopDir = false; end
                    iT = obj.hViews(1).DrawCenter(4) - 1 + 2.*uint8(lLoopDir);
                end
                
                for iI = 1:numel(obj.hViews)
                    obj.hViews(iI).DrawCenter(4) = iT;
                end
                obj.draw;
                obj.hViews.showTimePoint;
            
            % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
            % Temporarily switch to cursor tool
            case 'space' 
                if obj.SAction.iOldToolInd == 0
                    iInd = find([obj.SMenu.GroupIndex] == 255 & [obj.SMenu.Active]);
                    obj.SAction.iOldToolInd = iInd;
                    for iI = find([obj.SMenu.GroupIndex] == 255)
                        obj.SMenu(iI).Active = strcmp(obj.SMenu(iI).Name, 'cursor');
                    end
                    obj.updateActivation;
                end
            
            % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
            % Cycle colormaps
            case 'tab'
                csColormaps = obj.getColormaps;
                iInd = find(strcmp(obj.sColormap, csColormaps));
                iInd = mod(iInd, length(csColormaps)) + 1;
                obj.setColormap(csColormaps{iInd});
                obj.tooltip(obj.sColormap);
        end
         
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Shift
    case 1 
        switch eventdata.Key
            
            % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
            % Cycle Tools
            case 'space' 
                iTools   = find([obj.SMenu.GroupIndex] == 255 & [obj.SMenu.Enabled]);
                iToolInd = find(strcmp({obj.SMenu.Name}, obj.getTool));
                iToolIndInd = find(iTools == iToolInd);
                iTools = [iTools(end), iTools, iTools(1)];
                iToolIndInd = iToolIndInd + 2;
                iToolInd = iTools(iToolIndInd);
                obj.iconClick(obj.SImgs.hIcons(iToolInd), eventdata);
                obj.tooltip(obj.SMenu(iToolInd).Tooltip);
            
            % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
            % Cycle colormaps (reverse)
            case 'tab'
                csColormaps = obj.getColormaps;
                iInd = find(strcmp(obj.sColormap, csColormaps));
                iInd = mod(iInd - 2, length(csColormaps)) + 1;
                obj.setColormap(csColormaps{iInd});
                obj.tooltip(obj.sColormap);

        end
        
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Command / Control
    case 2
        switch eventdata.Character
            
            % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
            % Toggle Grid
            case 'g'
                if obj.dGrid ~= -1
                    if obj.dGrid
                        obj.dGrid = 0;
                    else
                        obj.dGrid = 1;
                    end
                    obj.resize(0);
                end
            
            % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
            % Toggle Ruler
            case 'r' 
                obj.lRuler = ~obj.lRuler;
                obj.resize(0);
            
            % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
            % Zoom in
            case {'+', '-'}
                dMinus = double(eventdata.Character == '-');
                for iI = 1:length(obj.hViews)
                    dDiff = dZOOMFACTORS - obj.hViews(iI).Zoom;
                    [dVal, iPos] = min(abs(dDiff));
                    if dVal == 0.0 % Zoom was on a discrete level
                        iPos = iPos + 1 - 2.*dMinus;
                    else
                        iPos = find(dDiff > 0, 1, 'first') - dMinus;
                    end
                    iPos = min(length(dZOOMFACTORS), max(1, iPos));
                    obj.hViews(iI).Zoom = dZOOMFACTORS(iPos);
                end
%                 obj.tooltip(sprintf('%d %%', uint16(obj.SData(obj.iStartSeries).dZoom.*100)));
                obj.tooltip(sprintf('%d %%', dZOOMFACTORS(iPos)*100));
                obj.hViews.position();
                obj.draw();
                obj.hViews.grid();
                
            % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
            % Set mask opacity
            case {'1', '2', '3', '4', '5', '6', '7', '8', '9'}
                dMaskOpacity = double(eventdata.Character - '0')./10;
                set(obj.SScatters.hSlider(5), 'XData', dMaskOpacity);
                obj.draw;
                obj.tooltip(sprintf('Mask Opacity: %d %%', uint8(dMaskOpacity*100)));
        end
                
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Command + Shift
    case 3
        switch eventdata.Key
            
            case 'd' % Debug entry point
                pause(0.1);
                
        end

end
% -----------------------------------------------------------------
set(obj.hF, 'SelectionType', 'normal');
end