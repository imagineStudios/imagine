classdef iView < handle
    
    properties
        hData            = iData.empty  % The data series associated with the view
        
        OldZoom
        OldDrawCenter
        
        hParent = imagine.empty
    end
    
    properties(SetObservable = true)
        Ind             = 1     % Index of the view (global)
%         Position
        Mode            = '2D'
        
        Zoom            = 1     % Zoom level
        DrawCenter      = []    % Coordinates of the central point
    end
    
    properties (Access = private)
        
        hA              = matlab.graphics.axis.Axes.empty
        hI              = matlab.graphics.primitive.Image.empty% Image components
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
        
        setAxes(obj)
        
        function delete(obj, ~, ~)
            delete([obj.hA]);
            delete([obj.hListeners]);
            delete@handle(obj)
        end
        
        function NoBottomLeftText(obj)
            for iI = 1:length(obj)
                if ~isempty(obj(iI).hT)
                    set(obj(iI).hT(2, 1, :), 'String', '');
                end
            end
        end
        
        draw(obj, ~, ~)
        position(obj, ~, ~)
        setMapping(obj, ~, ~)
        setData(obj, l3D, cData)
        [iView, iDimInd] = isOver(obj, hOver)
        iDivider = isOverDevider(obj, dCoord_px)
        
        function backup(obj)
            for iI = 1:length(obj)
                obj(iI).OldZoom = obj(iI).Zoom;
                obj(iI).OldDrawCenter = obj(iI).DrawCenter;
            end
        end
        
        function setMode(obj, l3D)
            for iI = 1:numel(obj)
                if l3D
                    obj(iI).Mode = '3D';
                else
                    obj(iI).Mode = '2D';
                end
                obj(iI).setAxes;
            end
        end
        
        setPosition(obj, iX, iY, iWidth, iHeight)
        
    end
    
    methods(Access = private)

    end
    
end
