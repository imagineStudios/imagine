classdef iView < handle
    
    properties
        hData            = iData.empty  % The data series associated with the view
        
        OldZoom
        OldDrawCenter
        
        hParent         = imagine.empty
    end
    
    properties(SetObservable = true)
        Ind             = 1     % Index of the view (global)
        
        Mode            = '2D'
        
        Zoom            = 1     % Zoom level
        DrawCenter      = []    % Coordinates of the central point
    end
    
    properties (Access = private)
        
        hA          = matlab.graphics.axis.Axes.empty
        hI          = matlab.graphics.primitive.Image.empty% Image components
        hQ              
        hL          % Line components
        hS          = matlab.graphics.chart.primitive.Scatter.empty% Quiver components
        hT          % Text components
        hP          % Patch component
        
        dColor
        hListeners
    end
    
    methods
        
        function obj = iView(hImagine, iInd)
            
            obj.hParent = hImagine;
            obj.Ind = iInd;
            obj.hListeners = addlistener(obj.hParent, 'ObjectBeingDestroyed', @obj.delete);
            
            dColors = lines(iInd);
            obj.dColor = dColors(end, :);
            
            obj.setAxes;
        end
        
        function delete(obj, ~, ~)
            delete([obj.hA]);
            delete([obj.hListeners]);
            delete@handle(obj)
        end
                
        draw(obj, ~, ~)
        position(obj, ~, ~)
        
        setAxes(obj)
        setPosition(obj, iX, iY, iWidth, iHeight)
        setData(obj, l3D, cData)
        setMode(obj, l3D)
        [iView, iDimInd] = isOver(obj, hOver)
        iDivider = isOverDevider(obj, dCoord_px)
        backup(obj)
        
%         function NoBottomLeftText(obj)
%             for iI = 1:length(obj)
%                 if ~isempty(obj(iI).hT)
%                     set(obj(iI).hT(2, 1, :), 'String', '');
%                 end
%             end
%         end

        
    end
    
    methods(Access = private)

    end
    
end
