function dImg = fGetLetterGraphic(sTemplate, iN, dSize, sFont)

% dSize = dSizePt/72*dDPI

if nargin < 4, sFont = 'Helvetica'; end
if nargin < 3, dSize = 12; end
if nargin < 2
    csText = {sTemplate};
else
    iInd = find(sTemplate == '%');
    if isempty(iInd) || iInd == length(sTemplate)
        for iI = 1:iN
            csText(iI) = {sTemplate};
        end
    else
        cStart = sTemplate(iInd + 1);
        for iI = 1:iN
            sText = sTemplate;
            sText = strrep(sText, sTemplate(iInd:iInd + 1), char(cStart + iI - 1));
            csText(iI) = {sText};
        end
    end
end

hF = figure('Units'         , 'pixels', ...
            'Position'      , [1 1 length(sTemplate).*dSize.*0.6 dSize + 20], ...
            'Color'         , 'k', ...
            'MenuBar'       , 'none', ...
            'Visible'       , 'off' ...
            );
        
hA = axes('Position'        , [0 0 1 1], ...
          'Color'           , 'k', ...
          'XColor'          , 'k', ...
          'YColor'          , 'k');

hT = text(0, 0, csText{1}, ...
            'HorizontalAlignment'   , 'left', ...
            'VerticalAlignment'     , 'bottom', ...
            'Color'                 , 'w', ...
            'BackgroundColor'       , 'k', ...
            'FontUnits'             , 'pixels', ...
            'FontSize'              , dSize, ...
            'FontName'              , sFont ...
            );
        
iImg = getframe(hF);
dImg = double(iImg.cdata(:,:,1))/255;
dImg = repmat(dImg, [1 1 length(csText)]);

for iI = 2:length(csText)
    set(hT, 'String', csText{iI});
    iImg = getframe(hF);
    dImg(:,:,iI) = double(iImg.cdata(:,:,1))/255;
end

close(hF);

lMip = max(dImg, [], 3) > 0;

iXMin = find(any(lMip, 1), 1, 'first');
iXMax = find(any(lMip, 1), 1, 'last');
iYMin = find(any(lMip, 2), 1, 'first');
iYMax = find(any(lMip, 2), 1, 'last');

dImg = dImg(iYMin:iYMax, iXMin:iXMax, :);
