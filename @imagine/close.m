function close(obj, ~, ~)

% -------------------------------------------------------------------------
% Stop and delete the timers
if ~isempty(obj.STimers)
    csTimers = fieldnames(obj.STimers);
    for iI = 1:length(csTimers)
        stop(obj.STimers.(csTimers{iI}));
        delete(obj.STimers.(csTimers{iI}));
    end
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Save settinge and close figure, delete object
try
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Save settings
    sMFilePath = [fileparts(mfilename('fullpath')), filesep, 'imagineSave.mat'];
    
    S.iPosition = get(obj.hF, 'Position');
    S.sPath = obj.sPath;
    S.lRuler        = obj.lRuler;
    S.dGrid         = max(0, obj.dGrid);
    S.l3DMode       = obj.isOn('3d');
    S.lDocked       = strcmp(get(obj.hF, 'WindowStyle'), 'docked');
    S.iSidebarWidth = obj.iSidebarWidth;
    S.iIconSize     = obj.iIconSize;
    
    save(sMFilePath, 'S');
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Delete and close
    delete(obj.hF);
    delete(obj);
catch me % if you can
    % Just to make sure that the figure is closed. Super annoying if there
    % is an error here
    delete(obj.hF);
    delete(obj);
    rethrow(me);
end
% -------------------------------------------------------------------------