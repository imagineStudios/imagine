classdef iView < handle
    
    properties
        hData            = iData.empty                                     % The data series associated with the view
        OldZoom
        OldDrawCenter
    end
    
    properties(SetObservable = true)
        Ind             = 1     % Index of the view (global)
        Zoom            = 1     % Zoom level
        DrawCenter      = []    % Coordinates of the central point
    end
    
    properties (Access = private)
        hParent     = imagine.empty
        
        hA          = matlab.graphics.axis.Axes.empty
        
        hI          = matlab.graphics.primitive.Image.empty                % Image components
%         hQ          = cquiver.empty                                        % The quiver component
        hL          = matlab.graphics.primitive.Line.empty                 % Line components
        hS          = matlab.graphics.chart.primitive.Scatter.empty        % Scatter components
        hT          = matlab.graphics.primitive.Text.empty                 % Text components
        hP          = matlab.graphics.primitive.Patch.empty                % Patch component
        
        sMode       = '2D'
        dColor      = [0.1 0.2 0.3]
        iRandColor
        hListeners
    end
        
    methods
        
        function obj = iView(hImagine, iInd)
            
            obj.hParent = hImagine;
            obj.Ind = iInd;
            obj.hListeners = addlistener(obj.hParent, 'ObjectBeingDestroyed', @obj.delete);
            
            dColors = lines(iInd);
            obj.dColor = dColors(end, :);
            
            dPattern = 1 - 0.7*rand(4096, 1);
            dBGImg = fBlend(obj.dColor, dPattern, 'multiply', 0.5);
            dBGImg = permute(dBGImg, [3 1 2]);
            obj.iRandColor = uint8([dBGImg; zeros(1, 4096) + 0.5].*255);
            
            obj.setAxes;
        end
        
        function delete(obj, ~, ~)
            delete([obj.hA]);
            delete([obj.hListeners]);
            delete@handle(obj)
        end
                
        draw(obj, lHD)
        position(obj, ~, ~)
        grid(obj)
        
        setAxes(obj)
        setPosition(obj, iX, iY, iWidth, iHeight)
        setData(obj, l3D, cData)
        setMode(obj, l3D)
        [iView, iDimInd] = isOver(obj, hOver)
        iDivider = isOverDevider(obj, dCoord_px)
        backup(obj)
        shift(obj, dDelta)
        zoom(obj, dFactor)
        showSlicePosition(obj)
        showSquare(obj)
        
        
        function dCoord = getCurrentPoint(obj, iDimInd)
            dCoord = get(obj.hA(iDimInd), 'CurrentPoint');
            dCoord = dCoord(1, 1:2);
        end
        
%         function NoBottomLeftText(obj)
%             for iI = 1:length(obj)
%                 if ~isempty(obj(iI).hT)
%                     set(obj(iI).hT(2, 1, :), 'String', '');
%                 end
%             end
%         end

        
    end
    
end
