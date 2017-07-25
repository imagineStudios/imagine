classdef CExplorer < handle
    
  properties
    hImagine      = CImagine.empty()
    hF
    hActivePanel  = CDataPanel.empty()
    hTooltip      = CTooltip.empty()
  end
  
  properties (Access = private)
    
    hPanels       = CDataPanel.empty()
    hScrollPanel  = CScrollPanel.empty()
    hA
    hI
    hSlider       = CSlider.empty()
    hC            = CComboBox.empty()
    
    hListeners
  end
  
  
  events
    update       % Fired to tell imagine to redraw
  end
  
  
  methods
    
    function obj = CExplorer(hImagine)
      
      try
        obj.hImagine = hImagine;
        obj.createGUIElements;
        obj.hListeners = addlistener(obj.hImagine, 'ObjectBeingDestroyed', @obj.close);
        % obj.hListeners(2) = addlistener(obj.hImagine, 'iActiveView', 'PostSet', @obj.updateActivation);
        
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
    resize(obj, ~, ~);
    mouseMove(obj, ~, ~)
    
    iPanel = isOver(obj, hOver)
    
    updateData(obj)
    
    setPanels(obj)
    
  end
  
  methods (Static)
    
    function dImg = getOrientIcons(iSize)
      
      persistent dIcons
%       dIcons = [];
      
      if isempty(dIcons)
        
        csIcons = {'physical', 'transversal', 'sagittal', 'coronal'};
        sIconPath = [fileparts(mfilename('fullpath')), filesep, '..', filesep, 'icons', filesep];
        
        dIcons = zeros(iSize, iSize, length(csIcons));
        
        for iI = 1:length(csIcons)
          [dImg, ~, dAlpha] = imread([sIconPath, csIcons{iI}, '.png']);
          dImg = double(cat(3, dImg, dAlpha));
          dImg = imresize(double(dImg)./255, [iSize, iSize], 'bicubic');
          dImg(dImg < 0) = 0;
          dImg(dImg > 1) = 1;
          dIcons(:,:,:,iI) = dImg;
        end
      end
      dImg = dIcons;
    end
    
    function dImg = getTypeIcons(iSize)
     
      persistent dIcons
%       dIcons = [];
      
      if isempty(dIcons)
        
        csIcons = {'scalar', 'categorical', 'rgb', 'vector'};
        sIconPath = [fileparts(mfilename('fullpath')), filesep, '..', filesep, 'icons', filesep];
        
        dIcons = zeros(iSize, iSize, 4, length(csIcons));
        
        for iI = 1:length(csIcons)
          [dImg, ~, dAlpha]  = imread([sIconPath, csIcons{iI}, '.png']);
          dImg = double(cat(3, dImg, dAlpha));
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
      dIcons = [];
      
      if isempty(dIcons)
        
        iNColormaps = length(SColormaps);
        dIcons = zeros(iSize/2, iSize, 3, iNColormaps);
        
        for iI = 1:iNColormaps
          dMap = SColormaps(iI).hFcn(iSize, 1);
          dIcons(:,:,:,iI) = [repmat( permute(dMap, [3 1 2]), [iSize/2, 1 1] )];
        end
        
      end
      
      dImg = dIcons;
      
    end
    
  end
  
end
