function close(obj, ~, ~)

% -------------------------------------------------------------------------
% Save settinge and close figure, delete object
try
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Save settings
    sMFilePath = [fileparts(mfilename('fullpath')), filesep, 'Settings.mat'];
    
    S.iPosition = get(obj.hF, 'Position');
    save(sMFilePath, 'S');
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Delete and close
    delete(obj.hListeners);
    delete(obj.hF);
    delete(obj);
catch me % if you can
    % Just to make sure that the figure is closed. Super annoying if there
    % is an error here
    delete(obj.hListeners);
    delete(obj.hF);
    delete(obj);
    rethrow(me);
end
% -------------------------------------------------------------------------