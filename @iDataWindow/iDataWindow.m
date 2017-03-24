classdef iDataWindow < handle
  
  properties (Constant)
    iPANELHEIGHT = 72;
  end
  
  properties
    hImagine    = imagine.empty
    hF
    hActivePanel = iDataPanel.empty
  end
  
  properties (Access = private)
    hPanels     = iDataPanel.empty                                     % The data series associated with the view
    dColors
    hListeners
    hA
    hI
    hSlider     = iSlider.empty
    hC          = iComboBox.empty
  end
  
  
  events
    update                                                             % Fired to tell imagine to redraw
  end
  
  
  methods
    
    function obj = iDataWindow(hImagine)
      
      try
        obj.hImagine = hImagine;
        obj.createGUIElements;
        obj.hListeners = addlistener(obj.hImagine, 'ObjectBeingDestroyed', @obj.close);
        %                 obj.hListeners(2) = addlistener(obj.hImagine, 'iActiveView', 'PostSet', @obj.updateActivation);
        obj.dColors = lines(36);
        
        obj.setPanels;
        obj.updateActivation;
        
        set(obj.hF, 'Visible', 'on');
      catch me
        delete(obj.hF);
        rethrow(me);
      end
      
    end
    
    close(obj, ~, ~)
    
    updateActivation(obj, ~, ~)
    draw(obj, lHD)
    position(obj, ~, ~)
    resize(obj, ~, ~);
    mouseMove(obj, ~, ~)
    
    iPanel = isOver(obj, hOver)
    
    updateData(obj)
    
    function setPanels(obj)
      hData = obj.hImagine.hData;
      
      if length(hData) < length(obj.hPanels)
        delete(obj.hPanels(length(hData) + 1:end));
      end
      
      for iI = 1:length(hData)
        if iI > length(obj.hPanels)
          obj.hPanels(iI) = iDataPanel(obj, hData(iI));
        end
        obj.hPanels(iI).fill;
      end
      
    end
    
  end
  
  methods (Static)
    
    function dImg = getOrientIcons(iSize)
      persistent dIcons
      %             dIcons = [];
      if isempty(dIcons)
        
        csIcons = {'physical', 'transversal', 'sagittal', 'coronal'};
        sIconPath = [fileparts(mfilename('fullpath')), filesep, '..', filesep, 'icons', filesep];
        
        dIcons = zeros(iSize, iSize, length(csIcons));
        
        for iI = 1:length(csIcons)
          [~, ~, dImg] = imread([sIconPath, csIcons{iI}, '.png']);
          dImg = dImg(8:end-7, 8:end-7);
          dImg = imresize(double(dImg)./255, [iSize, iSize], 'bicubic');
          dImg(dImg < 0) = 0;
          dImg(dImg > 1) = 1;
          dIcons(:,:,iI) = dImg;
        end
        dIcons = permute(dIcons, [1, 2, 4, 3]);
        dIcons = repmat(dIcons, [1, 1, 3, 1]);
      end
      dImg = dIcons;
    end
    
    function dImg = getTypeIcons(iSize)
      persistent dIcons
      %             dIcons = [];
      if isempty(dIcons)
        
        csIcons = {'scalar', 'categorical', 'rgb', 'vector'};
        sIconPath = [fileparts(mfilename('fullpath')), filesep, '..', filesep, 'icons', filesep];
        
        dIcons = zeros(iSize, iSize, 3, length(csIcons));
        
        for iI = 1:length(csIcons)
          dImg = imread([sIconPath, csIcons{iI}, '.png']);
          dImg = dImg(8:end-7, 8:end-7, :);
          dImg = imresize(double(dImg)./255, [iSize, iSize], 'bicubic');
          dImg(dImg < 0) = 0;
          dImg(dImg > 1) = 1;
          dIcons(:,:,:,iI) = dImg;
        end
      end
      dImg = dIcons;
    end
    
    function dImg = getColormapIcons(iSize, SColormaps)
      
      persistent dIcons
      % dIcons = [];
      
      if isempty(dIcons)
        
        iNColormaps = length(SColormaps);
        dIcons = zeros(iSize, iSize, 3, iNColormaps);
        
        for iI = 1:iNColormaps
          dMap = SColormaps(iI).hFcn(iSize, 1);
          dIcons(:,:,:,iI) = repmat( permute(dMap, [3 1 2]), [iSize, 1 1] );
        end
        
      end
      
      dImg = dIcons;
      
    end
    
  end
  
end
