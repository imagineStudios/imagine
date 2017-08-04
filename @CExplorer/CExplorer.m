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
    hI            = matlab.graphics.primitive.Image.empty()
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
    
    function dImg = getOrientIcons(hImagine, iSize)
      
      persistent dIcons
      %       dIcons = [];
      
      if isempty(dIcons)
        
        csIcons = {'physical', 'transversal', 'sagittal', 'coronal'};
        sIconPath = [hImagine.sBasePath, filesep(), '..', filesep(), 'themes', filesep(), hImagine.sTheme, filesep(), 'icons', filesep()];
        
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
    
    function dImg = getTypeIcons(hImagine, iSize)
      
      persistent dIcons
      %       dIcons = [];
      
      if isempty(dIcons)
        
        csIcons = {'scalar', 'categorical', 'rgb', 'vector'};
        sIconPath = [hImagine.sBasePath, filesep(), '..', filesep(), 'themes', filesep(), hImagine.sTheme, filesep(), 'icons', filesep()];
        
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
    
    
    function dImg = getColormapIcons(iSize, iN, SColormaps)
      
      persistent dIcons
      dIcons = [];
      
      if isempty(dIcons)
        
        iSUPERSAMPLING = 4;
        
        iRadius = round(iSize/5)*iSUPERSAMPLING;
        [dX, dY] = meshgrid(0:iRadius - 1, 0:iRadius - 1);
        dQuadrant = double((dX.^2 + dY.^2) <= iRadius.^2);
        dLogo = iGlobals.fDecimate([flip(flip(dQuadrant, 2), 1); dQuadrant], iSUPERSAMPLING);
        dAlpha = zeros(iSize);
        dAlpha(4:(size(dLogo, 1) + 3), (iSize/2):(iSize/2 + size(dLogo, 2) - 1)) = dLogo;
        
        for iI = 1:length(SColormaps)
          
          dCol = SColormaps(iI).hFcn(iN, 1);
          
          dImg = zeros(iSize, iSize, 3);
          dA = zeros(iSize);
          
          for iJ = 1:iN
            dC = repmat(permute(dCol(iJ, :), [1 3 2]), size(dImg, 1), size(dImg, 2), 1);
            dAR = repmat(0.8.*iGlobals.fRotate(dAlpha, -(iJ - 1 - (iN - 1)/2).*180/(iN - 1) + 25), 1, 1, 3);
            dC = dC.*dAR; % premultiplied alpha
            
            % Blend over with alpha
            dImg = dC + dImg.*(1 - dAR);
            dA = dAR(:,:,1) + dA.*(1 - dAR(:,:,1));
          end
          
          dImg = dImg./repmat(dA, 1, 1, 3);
          
          dIcons(:,:,:,iI) = cat(3, dImg, dA);
        end
        
      end
      
      dImg = dIcons;
      
    end
    
    
  end
  
end
