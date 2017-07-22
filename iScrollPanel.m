classdef iScrollPanel < handle
  
  properties
    Parent
    Children
    Position
    Padding = 10
  end
  
  properties(Access = private)
    hA
    hPatch
    
    dBarHeight = 0.1
    dBarCenter = 0.5
    
    dYMin = 0
    dYMax = 1
    
    iDelta = 0
    
    hListeners
    
    SAction
  end
  
  methods
    
    function obj = iScrollPanel(varargin)
      
      hParser = inputParser();
      
      hParser.addParameter('Parent', gcf, @(x) isa(x, 'matlab.ui.Figure'));
      hParser.addParameter('Position', [100 100 100 200], @isnumeric);
      hParser.addParameter('Color', [0.2 0.2 0.2], @isnumeric);
      
      hParser.parse(varargin{:});
      
      obj.Parent = hParser.Results.Parent;  
      obj.Position = hParser.Results.Position;
      
      obj.hA = axes(...
        'Parent'        , obj.Parent, ...
        'Units'         , 'pixels', ...
        'XTickMode'     , 'manual', ...
        'YTickMode'     , 'manual', ...
        'XTick'         , [], ...
        'YTick'         , [], ...
        'Color'         , hParser.Results.Color, ...
        'XColor'        , hParser.Results.Color, ...
        'YColor'        , hParser.Results.Color, ...
        'Position'      , [obj.Position(3) - 10, 1, 10, obj.Position(4)], ...
        'XLim'          , [0 1], ...
        'YLim'          , [0 1]);
      
      obj.hPatch = patch( ...
        'XData'         , [0 0 1 1], ...
        'YData'         , [0 1 1 0], ...
        'FaceColor'     , [100 180 255]/255, ...
        'EdgeColor'     , 'none');
      
      obj.hListeners = addlistener(obj.Parent, 'ObjectBeingDestroyed', @obj.delete);
      obj.hListeners(2) = addlistener(obj.Parent, 'WindowMousePress', @obj.mouseDown);
      obj.hListeners(3) = addlistener(obj.Parent, 'WindowMouseMotion', @obj.mouseMove);
      obj.hListeners(4) = addlistener(obj.Parent, 'WindowMouseRelease', @obj.mouseUp);
      obj.hListeners(3).Enabled = false;
      
      if isempty(obj.Parent.WindowButtonMotionFcn)
        obj.Parent.WindowButtonMotionFcn = @obj.dummyFcn;
      end
    end
    
    function setPosition(obj, dPos)
      obj.Position = dPos;
      obj.hA.Position = [dPos(3) - 10, 1, 10, dPos(4)];
      obj.fUpdateBar();
    end
    
    function delete(obj, ~, ~)
      delete(obj.hA);
      delete(obj.hListeners);
      delete@handle(obj);
    end
    
    function dummyFcn(~, ~, ~)
      
    end
    
    function mouseDown(obj, ~, ~)
      if isempty(obj.Children), return, end;
      
      hOver = hittest();
      if hOver == obj.hPatch || hOver == obj.hA
        dPos = get(obj.hA, 'CurrentPoint');
        obj.SAction.dYStart = dPos(1, 2);
        obj.SAction.dStartCenter = obj.dBarCenter;
        obj.hListeners(3).Enabled = true;
      end
    end
    
    function mouseMove(obj, ~, ~)
      dPos = get(obj.hA, 'CurrentPoint');
      dDeltaY = dPos(1, 2) - obj.SAction.dYStart;
      
      dCenter = obj.SAction.dStartCenter + dDeltaY;
      obj.dBarCenter = min( max(dCenter, obj.dBarHeight./2), 1 - obj.dBarHeight./2 );
      obj.fDrawBar();
      obj.fApply();
    end
    
    function mouseUp(obj, ~, ~)
      obj.hListeners(3).Enabled = false;
    end
    
    function add(obj, hObj)
      if isempty(obj.Children)
        obj.Children = hObj;
      else
        obj.Children(end + 1, 1) = hObj;
      end
      obj.fUpdateBar();
      obj.fApply();
    end
    
    function remove(obj, hHandle)
      lMatch = find([obj.Children.hHandle] == hHandle);
      obj.Children = obj.Children(~lMatch);
      obj.fUpdateBar();
    end
  end
  
  methods (Access = private)
    
    function fUpdateBar(obj)
      
      obj.dYMin = 0;
      obj.dYMax = obj.Padding;
      
      for iI = 1:length(obj.Children)
        dPos = obj.Children(iI).getPosition();
        obj.dYMax = obj.dYMax + dPos(4) + obj.Padding;
      end
      
      dContentHeight = obj.dYMax - obj.dYMin;
      dPanelHeight = obj.Position(4);
      
      obj.dBarHeight = max( 0.2, min(1, dPanelHeight./dContentHeight) );
      obj.dBarCenter = obj.dBarHeight/2 - (obj.iDelta.*(1 - obj.dBarHeight))./(dContentHeight - dPanelHeight);
      
      obj.fDrawBar();
    end
    
    function fDrawBar(obj)
      set(obj.hPatch, 'YData', obj.dBarCenter + 0.5.*obj.dBarHeight.*[-1 1 1 -1]);
    end
    
    function fApply(obj)
      dContentHeight = obj.dYMax - obj.dYMin;
      dPanelHeight = obj.Position(4);
      if obj.dBarHeight < 1
        obj.iDelta = round((obj.dBarHeight/2 - obj.dBarCenter).*(dContentHeight - dPanelHeight)./(1 - obj.dBarHeight));
      else
        obj.iDelta = 0;
      end
      
      dY = obj.Padding + obj.iDelta;
      for iI = 1:length(obj.Children)
        dPos = obj.Children(iI).getPosition();
        dPos(2) = dY;
        obj.Children(iI).setPosition(dPos);
        dY = dY + dPos(4) + obj.Padding;
      end
    end
  end
  
end