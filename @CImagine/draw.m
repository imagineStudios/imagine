function draw(obj, ~, ~)

% -------------------------------------------------------------------------
% Timer logic for hd mode
if nargin > 1
    % Stop timer to make sure it doesn't fire again
    stop(obj.STimers.hDrawFancy);
    lHD = obj.isOn('hd');
else
    if obj.isOn('hd')
        % Reset and start timer
        stop(obj.STimers.hDrawFancy);
        start(obj.STimers.hDrawFancy);
    end
    lHD = false;
end
obj.hViews.draw(lHD);
% -------------------------------------------------------------------------
