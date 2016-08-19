function disp(obj)

fprintf(1, 'IMAGINE %s with %d series:\n\n', obj.sVERSION, length(obj.hData));

if isempty(obj.hData), return, end

for iI = 1:length(obj.hData)
    sName = fCropText(obj.hData(iI).Name, 12);
    dSize = obj.hData(iI).getSize;
    fprintf(1, '[%02d]: %s %03dx%03dx%03dx%03d %s   %2.2f, %2.2f, %2.2f\n', iI, sName, dSize(1), dSize(2), dSize(3), dSize(4), obj.hData(iI).Mode);
end

% fprintf(1, '\n\nAnd %d views with the following mapping:\n\n', length(obj.hData));
% 
% for iI = 1:length(obj.hViews)
%     
%     sData = sprintf('%02d ', obj.DataMapping{iI});
%     fprintf(1, '[%02d]: [%s]\n', iI, sData);
% end
fprintf(1, '\n');


function sText = fCropText(sText, iLength)

if length(sText) == iLength
    return
elseif length(sText) > iLength
    sText = [sText(1:iLength - 7), char(8230), sText(end - 5:end)];
else
    sText = char(padarray(uint8(sText), [0, iLength - length(sText)], 32, 'post'));
end