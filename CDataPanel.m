classdef CDataPanel < handle
  
  properties (Constant)
    iHEIGHT = 72;
  end
  
  properties
    hData        = iData.empty                                     % The data series associated with the view
    dBGCOLOR     = [0.18 0.20 0.25];     % Background color
  end
  
  properties (Access = private)
    hParent     = iDataWindow.empty
    
    hA          = matlab.graphics.axis.Axes.empty
    hI
    hT          = matlab.graphics.primitive.Text.empty                 % Text components
    
    hListeners
  end
  
  methods
    
    function obj = CDataPanel(hDataWindow, hData)
      
      obj.hParent = hDataWindow;
      obj.hData = hData;
      
      obj.hA = axes( ...
        'Parent'            , obj.hParent.hF, ...
        'XTick'             , {}, ...
        'YTick'             , {}, ...
        'YDir'              , 'reverse', ...
        'YLim'              , [0, obj.iHEIGHT] + 0.5, ...
        'Units'             , 'pixels', ...
        'Position'          , [10 10 100 obj.iHEIGHT], ...
        'Color'             , obj.hParent.hImagine.dCOL1, ...
        'Visible'           , 'on');
      hold on
      
      obj.hI.hThumb = image(...
        'CData'             , 1);

      obj.hT(1) = text(74, 57, hData.Name, ...
        'Parent'            , obj.hA, ...
        'Units'             , 'pixels', ...
        'FontSize'          , 14, ...
        'FontName'          , 'Aleo', ...
        'FontWeight'        , 'bold', ...
        'Hittest'           , 'on', ...
        'Color'             , [0.8 0.8 0.8]);
      
      dSize = hData.getSize(1:4);
      obj.hT(2) = text(74, 34, sprintf('Size %d x %d x %d x %d', dSize(1), dSize(2), dSize(3), dSize(4)), ...
        'Parent'            , obj.hA, ...
        'Units'             , 'pixels', ...
        'FontSize'          , 12, ...
        'Hittest'           , 'on', ...
        'VerticalAlignment' , 'baseline', ...
        'Color'             , [0.8 0.8 0.8]);
      
      obj.hT(3) = text(74, 22, sprintf('Resolution %1.2f x %1.2f x %1.2f %s^3', hData.Res(1), hData.Res(2), hData.Res(3), hData.SpatialUnits), ...
        'Parent'            , obj.hA, ...
        'Units'             , 'pixels', ...
        'FontSize'          , 12, ...
        'Hittest'           , 'on', ...
        'VerticalAlignment' , 'baseline', ...
        'Color'             , [0.8 0.8 0.8]);
      
      obj.hT(4) = text(74, 10, sprintf('Origin (%1.1f %1.1f %1.1f)', hData.Origin(1), hData.Origin(2), hData.Origin(3)), ...
        'Parent'            , obj.hA, ...
        'Units'             , 'pixels', ...
        'FontSize'          , 12, ...
        'Hittest'           , 'on', ...
        'VerticalAlignment' , 'baseline', ...
        'Color'             , [0.8 0.8 0.8]);
      
      obj.hListeners = addlistener(obj.hParent, 'ObjectBeingDestroyed', @obj.delete);
      obj.hListeners(2) = addlistener(obj.hParent.hF, 'WindowMousePress'  , @obj.mouseDown);
      
      obj.draw;
    end
    
    function setActive(obj, lActive)
      if lActive
        set(obj.hT(1), 'Color', [100 180 255]/255);
        set(obj.hT(2:end), 'Color', [0.8 0.8 0.8]);
      else
        set(obj.hT(1), 'Color', [0.8 0.8 0.8]);
        set(obj.hT(2:end), 'Color', [0.6 0.6 0.6]);
      end
    end
    
    function delete(obj, ~, ~)
      delete([obj.hA]);
      delete([obj.hListeners]);
      delete@handle(obj)
    end
    
    function setPosition(obj, dPos)
      dPos(4) = obj.iHEIGHT;
      set(obj.hA, ...
        'Position'      , dPos, ...
        'XLim'          , [0, dPos(3)] + 0.5, ...
        'YLim'          , [0, dPos(4)] + 0.5);
    end
    
    function dPos = getPosition(obj)
      dPos = obj.hA.Position;
    end
    
    function setWidth(obj, iWidth)
      for iI = 1:numel(obj)
        dPos = obj(iI).hA.Position;
        dPos(3) = iWidth;
        set(obj(iI).hA, ...
          'Position'     ,  dPos, ...
          'XLim'         , [0, iWidth] + 0.5);
      end
    end
        
    function draw(obj)
      dThumb = abs(double(obj.hData.getData));
      dThumb = dThumb - min(dThumb(:));
      dThumb = dThumb./max(dThumb(:));
      dThumb = imresize(dThumb, [64 64], 'bicubic');
      dThumb(dThumb < 0) = 0;
      dThumb(dThumb > 1) = 1;
      dThumb = dThumb.^0.6; % Give it some gamma
      if size(dThumb, 3) == 1
        dThumb = uint8(dThumb.*255);
      end
      set(obj.hI.hThumb, ...
        'CData'             , dThumb, ...
        'XData'             , 4 + [1 size(dThumb, 2)], ...
        'YData'             , 4 + [1 size(dThumb, 1)]);
    end
    
    function hA = getAxes(obj)
      hA = obj.hA;
    end
    
    [iView, iDimInd] = isOver(obj, hOver)
    
  end
  
  methods (Access = private)
    
    function mouseDown(obj, ~, ~)
      hOver = hittest();
      switch hOver
        case obj.hA
          
          % Change the active panel
          obj.hParent.hActivePanel = obj;
          obj.hParent.updateActivation();
          
        case obj.hT(1)
          if strcmp(obj.hParent.hF.SelectionType, 'open')
            obj.hT(1).Editing = 'on';
          end
          
        otherwise
      end
    end
    
  end
  
  methods (Static)
    
    function dData = getRand
      persistent dRand
      if isempty(dRand)
        dRand = (0.95 + 0.05.*rand(1, 72)).*linspace(1, 0.85, 72);
      end
      dData = dRand;
    end
    
  end
  
end
