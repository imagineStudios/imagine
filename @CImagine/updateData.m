function updateData(obj, ~, ~)

lDraw = false;
for iI = 1:length(obj.SData)
    if ~isempty(obj.SData(iI).sSource)
        obj.SData(iI).dImg = evalin('base', obj.SData(iI).sSource);
        lDraw = true;
    end
end

if lDraw, obj.draw(obj.STimers.hDrawFancy); end