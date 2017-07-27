% =========================================================================
% *** FUNCTION fMatRead
% ***
% *** Lets the user select one or multiple variables from the base
% *** workspace for import into imagine
% ***
% =========================================================================
function csVarOut = fMatRead(sFilename)

iFIGUREWIDTH = 300;
iFIGUREHEIGHT = 400;
iBUTTONHEIGHT = 24;

csVarOut = {};
iPos = get(0, 'ScreenSize');

% -------------------------------------------------------------------------
% Get variables in the mat file
set(gcf, 'Pointer', 'watch'); drawnow
SInfo = whos('-file', sFilename);
set(gcf, 'Pointer', 'arrow');
csNames = {};
csNamesDims = {};
for iI = 1:length(SInfo)
    if length(SInfo(iI).size) < 2 || length(SInfo(iI).size) > 4, continue, end
    if strcmp(SInfo(iI).class, 'struct') || ...
       strcmp(SInfo(iI).class, 'cell')
        continue
    end
    csNames{iI} = SInfo(iI).name;
    sString = sprintf('%s (%s', SInfo(iI).name, sprintf('%ux', SInfo(iI).size));
    sString = [sString(1:end-1), ')'];
    csNamesDims{iI} = sString;
end
% -------------------------------------------------------------------------

if isempty(csNames)
   fprintf('fMatRead: No matching variables stored in ''%s''\n!', sFilename);
   return
end

if length(csNames) == 1
    csVarOut(1) = csNames(1);
    return
end

% -------------------------------------------------------------------------
% Create figure and GUI elements
hF = figure( ...
    'Position'              , [(iPos(3) - iFIGUREWIDTH)/2, (iPos(4) - iFIGUREHEIGHT)/2, iFIGUREWIDTH, iFIGUREHEIGHT], ...
    'Units'                 , 'pixels', ...
    'DockControls'          , 'off', ...
    'WindowStyle'           , 'modal', ...
    'Name'                  , 'Load variables from mat-File...', ...
    'NumberTitle'           , 'off', ...
    'KeyPressFcn'           , @fMatMouseActionFcn, ...
    'Resize'                , 'off');

hList = uicontrol(hF, ...
    'Style'                 , 'listbox', ...
    'Units'                 , 'pixels', ...
    'Position'              , [1 iBUTTONHEIGHT + 1 iFIGUREWIDTH iFIGUREHEIGHT - iBUTTONHEIGHT], ...
    'HitTest'               , 'on', ...
    'Min'                   , 0, ...
    'Max'                   , 2, ...
    'String'                , csNamesDims, ...
    'KeyPressFcn'           , @fMatMouseActionFcn, ...
    'Callback'              , @fMatMouseActionFcn);

hButOK = uicontrol(hF, ...
    'Style'                 , 'pushbutton', ...
    'Units'                 , 'pixels', ...
    'Position'              , [1 1 iFIGUREWIDTH/2 iBUTTONHEIGHT], ...
    'Callback'              , @fMatMouseActionFcn, ...
    'HitTest'               , 'on', ...
    'String'                , 'OK');

hButCancel = uicontrol(hF, ...
    'Style'                 , 'pushbutton', ...
    'Units'                 , 'pixels', ...
    'Position'              , [iFIGUREWIDTH/2 + 1 1 iFIGUREWIDTH/2 iBUTTONHEIGHT], ...
    'Callback'              , 'uiresume(gcf);', ...
    'HitTest'               , 'on', ...
    'String'                , 'Cancel');
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Set default action and enable gui interaction
sAction = 'Cancel';
uiwait(hF);
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% uiresume was triggered (in fMouseActionFcn) -> return
if strcmp(sAction, 'OK')
    iList = get(hList, 'Value');
    csVarOut = cell(length(iList), 1);
    for iI = 1:length(iList)
        csVarOut(iI) = csNames(iList(iI));
    end
end
close(hF);
% -------------------------------------------------------------------------


    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * *
    % * * NESTED FUNCTION fMatMouseActionFcn (nested in fGetMatFileVar)
    % * *
    % * * Determine whether axes are linked
	% * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fMatMouseActionFcn(hObject, eventdata)
        if isfield(eventdata, 'Key')
            switch eventdata.Key
                case 'escape', uiresume(hF);
                case 'return'
                    sAction = 'OK';
                    uiresume(hF);
            end
        end
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % React on action depending on its source component
        switch(hObject)
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Click in LISBOX: return if double-clicked
            case hList
                if strcmp(get(hF, 'SelectionType'), 'open')
                    sAction = 'OK';
                    uiresume(hF);
                end
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % OK button
            case hButOK
                sAction = 'OK';
                uiresume(hF);
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

            otherwise

        end
        % End of switch statement
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        
    end
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * * END NESTED FUNCTION fMatMouseActionFcn
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    
end
% =========================================================================
% *** END FUNCTION fMatRead (and its nested functions)
% =========================================================================