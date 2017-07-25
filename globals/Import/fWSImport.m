% =========================================================================
% *** FUNCTION fWSImport
% ***
% *** Lets the user select one or multiple variables from the base
% *** workspace for import into imagine
% ***
% =========================================================================
function csVarOut = fWSImport()

iFIGUREWIDTH = 300;
iFIGUREHEIGHT = 400;
iBUTTONHEIGHT = 24;

csVarOut = {};
iPos = get(0, 'ScreenSize');

% -------------------------------------------------------------------------
% Create figure and GUI elements
hF = figure( ...
    'Position'              , [(iPos(3) - iFIGUREWIDTH)/2, (iPos(4) - iFIGUREHEIGHT)/2, iFIGUREWIDTH, iFIGUREHEIGHT], ...
    'Units'                 , 'pixels', ...
    'DockControls'          , 'off', ...
    'WindowStyle'           , 'modal', ...
    'Name'                  , 'Load workspace variable...', ...
    'NumberTitle'           , 'off', ...
    'KeyPressFcn'           , @fMouseActionFcn, ...
    'Resize'                , 'off');

csVars = evalin('base', 'who');
hList = uicontrol(hF, ...
    'Style'                 , 'listbox', ...
    'Units'                 , 'pixels', ...
    'Position'              , [1 iBUTTONHEIGHT + 1 iFIGUREWIDTH iFIGUREHEIGHT - iBUTTONHEIGHT], ...
    'HitTest'               , 'on', ...
    'String'                , csVars, ...
    'Min'                   , 0, ...
    'Max'                   , 2, ...
    'KeyPressFcn'           , @fMouseActionFcn, ...
    'Callback'              , @fMouseActionFcn);

hButOK = uicontrol(hF, ...
    'Style'                 , 'pushbutton', ...
    'Units'                 , 'pixels', ...
    'Position'              , [1 1 iFIGUREWIDTH/2 iBUTTONHEIGHT], ...
    'Callback'              , @fMouseActionFcn, ...
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
        csVarOut(iI) = csVars(iList(iI));
    end
end
try
    close(hF);
catch %#ok<CTCH>
    csVarOut = {};
end
% -------------------------------------------------------------------------


    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    % * *
    % * * NESTED FUNCTION fMouseActionFcn (nested in fGetWorkspaceVar)
    % * *
    % * * Determine whether axes are linked
	% * *
    % = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    function fMouseActionFcn(hObject, eventdata)
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
    % * * END NESTED FUNCTION fGridMouseMoveFcn
	% = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
    
end
% =========================================================================
% *** END FUNCTION fWSImport (and its nested functions)
% =========================================================================
