function updateActivation(obj, ~, ~)

for iI = 1:length(obj.hPanels)
    if obj.hPanels(iI) == obj.hActivePanel
        obj.hPanels(iI).setActive(true);
    else
        obj.hPanels(iI).setActive(false);
    end
end

if ~isempty(obj.hActivePanel)
  hData = obj.hActivePanel.hData;
  obj.hSlider.Value = hData.Alpha*100;
  obj.hSlider.draw();
  
  iInd = find(strcmp(hData.Orientation, ...
    {'physical', 'transversal', 'sagittal', 'coronal'}));
  obj.hC(1).setInd(iInd);
  
  iInd = find(strcmp(hData.Colormap.sName, ...
    {obj.hImagine.SColormaps.sName}));
  obj.hC(3).setInd(iInd);
  
end