function disp(obj)

fprintf(1, 'IMAGINE %s with %d series\n\n', obj.sVERSION, length(obj.SData));

if isempty(obj.SData), return, end

lVisible = false(length(obj.SData));
for iI = 1:numel(obj.SView)
    lVisible(obj.SView(iI).iData) = true;
end

for iI = 1:length(obj.SData)
    sName = fCropText(obj.SData(iI).sName, 12);
    dSize = size(obj.SData(iI).dImg);
    dSize = dSize([1, 2, 4]);
    if ~isreal(obj.SData(iI).dImg)
        sMode = 'Complex';
    else
        if dSize(3) == 3;
            sMode = '   RGB';
        else
            sMode = 'Scalar';
        end
    end
    if lVisible(iI)
        sVisible = '*';
    else
        sVisible = ' ';
    end
    fprintf(1, '[%02d]: %s%s %03dx%03dx%03d %s   %2.2f, %2.2f, %2.2f\n', iI, sVisible, sName, dSize(1), dSize(2), dSize(3), sMode, obj.SData(iI).dOrigin([1 2 4]));
end

function sText = fCropText(sText, iLength)

if length(sText) == iLength
    return
elseif length(sText) > iLength
    sText = [sText(1:iLength - 7), char(8230), sText(end - 5:end)];
else
    sText = char(padarray(uint8(sText), [0, iLength - length(sText)], 32, 'post'));
end