function SView = getView(obj)

% oOver = hittest;
% lInd = oOver == [obj.SView.hAxes];


hViews = [obj.SView.hAxes];
if isscalar(hViews)
    dXLim = get(hViews, 'XLim');
    dYLim = get(hViews, 'YLim');
    dPos  = get(hViews, 'CurrentPoint');
else
    dXLim = cell2mat(get(hViews, 'XLim'));
    dYLim = cell2mat(get(hViews, 'YLim'));
    dPos  = cell2mat(get(hViews, 'CurrentPoint'));
end

dXPos = dPos(1:2:end, 1);
dYPos = dPos(1:2:end, 2);

lInd = dXPos >= dXLim(: ,1) & dXPos <= dXLim(: ,2) & ...
       dYPos >= dYLim(: ,1) & dYPos <= dYLim(: ,2);
    


if ~any(lInd)
    SView = [];
else
    SView = obj.SView(lInd);
end



