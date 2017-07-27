function setPanels(obj)
hData = obj.hImagine.hData;

if length(hData) < length(obj.hPanels)
  delete(obj.hPanels(length(hData) + 1:end));
end

for iI = 1:length(hData)
  if iI > length(obj.hPanels)
    obj.hPanels(iI) = CDataPanel(obj, hData(iI));
    obj.hScrollPanel.add(obj.hPanels(iI));
  end
end

uistack(obj.hA, 'top');

end