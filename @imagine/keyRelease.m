function keyRelease(obj, hObject, eventdata)

% -------------------------------------------------------------------------
% Bail if only a modifier has been pressed. For some reason the mac command
% and fn keys are represented as '0'
if any(strcmp(eventdata.Key, {'shift', 'control', 'alt'})) || ...
      (strcmp(eventdata.Key, '0') && isempty(eventdata.Character))
    switch eventdata.Key
        case 'shift', obj.SAction.lShift = false;
        case 'control', obj.SAction.lControl = false;
        case 'alt', obj.SAction.lAlt = false;
    end
    return
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Get the modifier (shift, cntl, cmd, alt) keys
iModifier = 0;
if any(strcmp(eventdata.Modifier, 'shift'))         , iModifier = iModifier + 1; end;
if any(strcmp(eventdata.Modifier, 'control')) || ...
        any(strcmp(eventdata.Modifier, 'command'))  , iModifier = iModifier + 2; end;
if any(strcmp(eventdata.Modifier, 'alt'))           , iModifier = iModifier + 4; end;
% -------------------------------------------------------------------------

switch iModifier
    
    case 0
        
        switch eventdata.Key
            
            case 'space'
                for iI = find([obj.SMenu.GroupIndex] == 255)
                    obj.SMenu(iI).Active = false;
                end
                obj.SMenu(obj.SAction.iOldToolInd).Active = true;
                obj.updateActivation;
            
        end
end

obj.SAction.iOldToolInd = 0;