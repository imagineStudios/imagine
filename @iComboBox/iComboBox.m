classdef iComboBox < handle
  
  properties
    Imgs
    Ind         = 0
    Parent      = matlab.graphics.axis.Axes.empty
    Position    = [1 1]
    Callback    = function_handle.empty()
  end
  
  properties (Access = private)
    
    
    hI          = matlab.graphics.primitive.Image.empty                 % Line components
    hA          = matlab.graphics.axis.Axes.empty
    
    iWidth      = 16
    iHeight     = 16
    
    hListeners
  end
  
  methods
    
    function obj = iComboBox(varargin)
      
      % -------------------------------------------------------------------------
      % Parse optional parameter-value pairs
      hP = inputParser();
      
      hP.addParameter('Parent', matlab.graphics.axis.Axes.empty, @(x) isa(x, 'matlab.graphics.axis.Axes'));
      %             hValidFcn = @(x) validateattributes(x, {'numeric'});
      hP.addParameter('Imgs', 0, @(x) isnumeric(x));
      hValidFcn = @(x) validateattributes(x, {'numeric'}, {'scalar'});
      hP.addParameter('Ind', 1, hValidFcn);
      hValidFcn = @(x) validateattributes(x, {'numeric'}, {'numel', 2});
      hP.addParameter('Position', [1 1], hValidFcn);
      hP.addParameter('Callback', function_handle.empty, @(x) isa(x, 'function_handle'));
      
      hP.parse(varargin{:});
      
      cFN = fieldnames(hP.Results);
      for iI = 1:length(cFN)
        obj.(cFN{iI}) = hP.Results.(cFN{iI});
      end
      % -------------------------------------------------------------------------
      
      if isempty(obj.Parent)
        obj.Parent = gca;
      end
      obj.iWidth = size(obj.Imgs, 2);
      obj.iHeight = size(obj.Imgs, 1);
      
      hF = get(obj.Parent, 'Parent');
      
      obj.hA = axes( ...
        'Parent'            , hF, ...
        'Visible'           , 'off', ...
        'YDir'              , 'reverse', ...
        'XLim'              , [0, obj.iWidth] + 0.5, ...
        'Units'             , 'pixels', ...
        'Hittest'           , 'off');
      obj.hI(1) = image(...
        'Parent'            , obj.Parent, ...
        'CData'             , 0);
      
      % Create a stacked version of the icons and display in hidden
      % image for selection
      dImg = reshape(permute(obj.Imgs, [1, 4, 2, 3]), [], size(obj.Imgs, 2), size(obj.Imgs, 3));
      obj.hI(2) = image( ...
        'Parent'            , obj.hA, ...
        'CData'             , dImg, ...
        'Visible'           , 'off');
      
      obj.drawIcon;
      obj.setPosition;
      
      obj.hListeners    = addlistener(get(obj.Parent, 'Parent'), 'WindowMousePress'  , @obj.mouseDown);
      obj.hListeners(2) = addlistener(get(obj.Parent, 'Parent'), 'WindowMouseMotion' , @obj.mouseMove);
      obj.hListeners(2).Enabled = false;
      obj.hListeners(3) = addlistener(obj.Parent, 'ObjectBeingDestroyed' , @obj.delete);
    end
    
    
    function delete(obj, ~, ~)
      delete([obj.hI]);
      delete([obj.hListeners]);
      delete@handle(obj)
    end
    
    function setInd(obj, iInd)
      if ~isempty(iInd)
        if iInd > 0 && iInd <= size(obj.Imgs, 4)
          obj.Ind = iInd;
          obj.drawIcon();
        else
          error('Index exceeds combobox options!');
        end
      end
    end
    
  end
  
  
  methods (Access = private)
    
    function mouseDown(obj, ~, ~)
      hOver = hittest;
      
      if hOver == obj.hI(1)
        
        uistack(obj.hA, 'top');
        hF = obj.Parent.Parent;
        
        dYLimTarget = [0, size(obj.Imgs, 1).*size(obj.Imgs, 4)] + 0.5;
        dYLimStart  = [0.5, 1.5];
        
        dPos = obj.Parent.Position;
        
        dYStart = - obj.Position(2) + dPos(2) + dPos(4) - obj.iHeight;
        
        dStartHeight  = 1;
        dTargetHeight = diff(dYLimTarget);
        
        if dTargetHeight > dYStart
          dFigureSize = get(hF, 'Position');
          dYEnd = min(dTargetHeight, dFigureSize(4));
        else
          dYEnd = dYStart;
        end
        
        dPos = [obj.Position(1) + dPos(1), dYStart, obj.iWidth, 1];
        set(obj.hI(2), 'Visible', 'on', 'AlphaData', 1);
        
        for dVal = fExpAnimation(20, 1, 0);
          dYLim = (1 - dVal)*dYLimTarget + dVal*dYLimStart;
          iHeight = (1 - dVal)*dTargetHeight + dVal*dStartHeight;
          iY = (1 - dVal)*dYEnd + dVal*dYStart;
          dPos(2) = iY - iHeight;
          dPos(4) = iHeight;
          set(obj.hA, 'Position', dPos, 'YLim', dYLim + 0.5);
          drawnow update
          pause(0.01);
        end
        
      elseif hOver == obj.hI(2)
        dPos = get(obj.hA, 'CurrentPoint');
        obj.Ind = ceil(dPos(1, 2)/obj.iHeight);
        obj.drawIcon();
        obj.Callback();
        
        dAlphaData = 1;
        for dAlpha = 0.8:-0.1:0
          set(obj.hI(2), 'AlphaData', dAlpha.*dAlphaData);
          drawnow update
          pause(0.01);
        end
        
        set(obj.hI(2), 'Visible', 'off');
        
      else
        if strcmp(get(obj.hI(2), 'Visible'), 'on')
          dAlphaData = 1;
          for dAlpha = 0.8:-0.1:0
            set(obj.hI(2), 'AlphaData', dAlpha.*dAlphaData);
            drawnow update
            pause(0.01);
          end
          
          set(obj.hI(2), 'Visible', 'off');
        end
      end
    end
    
    function mouseMove(obj, ~, ~)
      disp('Hallo');
    end
    
    function setPosition(obj)
      set(obj.hI(1), 'XData', obj.Position(1), 'YData', obj.Position(2));
    end
    
    function drawIcon(obj)
      dImg = obj.Imgs(:,:,:,obj.Ind);
      dArrow = obj.getArrowImg;
      dPrePad = floor( (obj.iHeight - size(dArrow, 1))./2 );
      dPostPad = obj.iHeight - size(dArrow, 1) - dPrePad;
      dArrow = padarray(dArrow, [dPrePad, 0, 0], 0, 'pre');
      dArrow = padarray(dArrow, [dPostPad, 0, 0], 0, 'post');
      set(obj.hI(1), 'CData', [dImg, dArrow]);
    end
    
  end
  
  methods (Static)
    
    function dImg = getArrowImg
      
      persistent dArrowImg
      
      %             dArrowImg = [];
      if isempty(dArrowImg)
        sPath = fileparts(mfilename('fullpath'));
        [~, ~, iImg] = imread([sPath, filesep, 'arrow.png']);
        dArrowImg = repmat(double(iImg)./255, [1 1 3]);
      end
      
      dImg = dArrowImg;
      
    end
    
  end
  
end
