classdef CTooltip < handle
  
  properties (Constant)
    dTOOLTIPSCALING = 12; % Empirical factor to scale from letter count to width in px
  end
  
  properties
    hParent
    
    hA = matlab.graphics.axis.Axes.empty()
    hI = matlab.graphics.primitive.Image.empty()
    hT = matlab.graphics.primitive.Text.empty()
    
    hTimer = timer.empty()
  end
  
  properties (Access = private)
    hListeners
    dBGCol
  end
  
  methods
    
    function obj = CTooltip(hParent, dBGCol)
      obj.hParent = hParent;
      obj.dBGCol = dBGCol;
      
      % -------------------------------------------------------------------------
      % Create the GUI elements
      obj.hA = axes(...
        'Units'                 , 'pixels', ...
        'YDir'                  , 'reverse', ...
        'Visible'               , 'off', ...
        'Hittest'               , 'off');
      
      obj.hI = image(...
        'CData'                 , 1, ...
        'Visible'               , 'off', ...
        'HitTest'               , 'on');
      
      obj.hT = text(0.5, 0.3, '', ...
        'HorizontalAlignment'   , 'center', ...
        'VerticalAlignment'     , 'baseline', ...
        'Color'                 , ones(1, 3), ...
        'Units'                 , 'normalized', ...
        'FontUnits'             , 'normalized', ...
        'FontSize'              , 0.5, ...
        'FontName'              , 'Aleo', ...
        'FontWeight'            , 'bold');
      
      % -------------------------------------------------------------------------
      % Create the timer
       obj.hTimer = timer(...
         'Name'                 , 'tooltip', ...
         'StartDelay'           , 0.8, ...
         'UserData'             , 'CW_Tooltip', ...
         'TimerFcn'             , @obj.hide);
       
      % -------------------------------------------------------------------------
      % Attach listeners
      obj.hListeners = addlistener(obj.hParent, 'ObjectBeingDestroyed' , @obj.delete);
      obj.hListeners(2) = addlistener(obj.hParent, 'WindowMouseMotion' , @obj.checkOver);
      
    end
    
    function delete(obj, ~, ~)
      delete([obj.hListeners]);
      stop(obj.hTimer);
      delete(obj.hTimer);
      delete@handle(obj)
    end
    
    function show(obj, sString)
      
      if ~strcmp(get(obj.hT, 'String'), sString)
        uistack(obj.hA, 'top');
        dBGMask = obj.getMaskImg();
        
        % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        % Determine the position in the figure
        iWidth = round(length(sString).*obj.dTOOLTIPSCALING) + 20;
        dHeight = size(dBGMask, 1);
        dFigureSize = get(obj.hParent, 'Position');
        dXPos = (dFigureSize(3) - iWidth)/2;
        if strcmp(obj.hI.Visible, 'on')
          dPos = obj.hA.Position;
          dYPos = dPos(2);
        else
          dYPos = 0.618.*dFigureSize(4) - dHeight/2; % Awww... the golden ratio!
        end
        set(obj.hA, ...
          'Position'  , [dXPos, dYPos, iWidth, dHeight], ...
          'XLim'      , [0.5, iWidth + 0.5], ...
          'YLim'      , [0.5, dHeight + 0.5]);
        
        % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        % Update the image data and the alpha mask
        dMask = 0.75.*[dBGMask, ones(dHeight, iWidth - 2*size(dBGMask, 2)), flip(dBGMask, 2)];
        dImg = repmat(permute(obj.dBGCol, [3 1 2]), [dHeight, iWidth, 1]);
        set(obj.hI, ...
          'CData'     , dImg, ...
          'AlphaData' , dMask, ...
          'Visible'   , 'on');
        
        % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
        % Update the text
        set(obj.hT, ...
          'String'    , sString, ...
          'Visible'   , 'on');
      end
      
      stop(obj.hTimer);
      start(obj.hTimer);
    end
    
    function hide(obj, ~, ~)
      stop(obj.hTimer);
      
      set(obj.hI, ...
        'Visible'   , 'off');
      
      set(obj.hT, ...
        'Visible'   , 'off', ...
        'String'    , '');
    end
    
    function checkOver(obj, ~, ~)
      % -------------------------------------------------------------------------
      % If over the tooltip, move it out of the way
      hOver = hittest();
      if obj.hI == hOver || obj.hT == hOver
        
        dTooltipPos = get(obj.hA, 'Position');
        dFigureSize = get(obj.hParent, 'Position');
        dNormalHeight = 0.618.*dFigureSize(4) - dTooltipPos(4)/2;
        
        if dTooltipPos(2) <= dNormalHeight
          dHeight = iGlobals.fExpAnimation(10, dTooltipPos(2), dTooltipPos(2) + 1.2.*dTooltipPos(4));
        else
          dHeight = iGlobals.fExpAnimation(10, dTooltipPos(2), dTooltipPos(2) - 1.2.*dTooltipPos(4));
        end
        
        for iI = 1:length(dHeight)
          dTooltipPos(2) = dHeight(iI);
          set(obj.hA, 'Position', dTooltipPos);
          pause(0.01);
        end
        
        return
      end
    end
    
  end
  
  
  
  methods (Static)
    
    function dImg = getMaskImg
      
      persistent dBGMask
      
      if isempty(dBGMask)
        sPath = fileparts(mfilename('fullpath'));
        [~, ~, dBGMask] = imread([sPath, filesep(), 'mask.png']);
        dBGMask = double(dBGMask)/255;
      end
      dImg = dBGMask;
    end
    
  end
  
end