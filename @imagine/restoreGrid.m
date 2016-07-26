function restoreGrid(obj, hObject, eventdata)

if isfield(obj.SAction, 'dGrid')
    obj.dGrid = obj.SAction.dGrid;
    obj.grid;
end
stop(obj.STimers.hGrid);