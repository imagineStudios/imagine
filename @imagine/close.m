function close(obj, ~, ~)

% -------------------------------------------------------------------------
% Stop and delete the timers
try
    csFields = fieldnames(obj.STimers);
    for iI = 1:length(csFields)
        stop(obj.STimers.(csFields{iI}));
        delete(obj.STimers.(csFields{iI}));
    end
catch me
    disp(me.message);
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
    S.l3DMode       = obj.isOn('2d');
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