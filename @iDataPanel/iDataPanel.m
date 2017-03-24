classdef iDataPanel < handle
    
    properties
        hData        = iData.empty                                     % The data series associated with the view
        dBGCOLOR     = [0.18 0.20 0.25];     % Background color
    end
    
    properties (Access = private)
        hParent     = iDataWindow.empty
        
        hA          = matlab.graphics.axis.Axes.empty
        hI
        hT          = matlab.graphics.primitive.Text.empty                 % Text components
        
        iRandColor
        hListeners
    end
    
    methods
        
        function obj = iDataPanel(hDataWindow, hData)
            
            obj.hParent = hDataWindow;
            obj.hData = hData;
            
            obj.hA = axes( ...
                'Parent'            , obj.hParent.hF, ...
                'Visible'           , 'off', ...
                'XTick'             , {}, ...
                'YTick'             , {}, ...
                'YDir'              , 'reverse', ...
                'Units'             , 'pixels');
            hold on
            
            obj.hI.hBG = image(...
                'CData'             , 1, ...
                'XData'             , [1, 400], ...
                'YData'             , [1, 72]);

            obj.hI.hThumb = image(...
                'CData'             , 1);
            
            obj.hT = text(74, 60, 'Name', ...
                'Parent'            , obj.hA, ...
                'Units'             , 'pixels', ...
                'FontSize'          , 14, ...
                'FontName'          , 'Aleo', ...
                'FontWeight'        , 'bold', ...
                'Hittest'           , 'on', ...
                'Color'             , 'w');
                
            obj.hListeners = addlistener(obj.hParent, 'ObjectBeingDestroyed', @obj.delete);
            obj.hListeners(2) = addlistener(obj.hParent.hF, 'WindowMousePress'  , @obj.mouseDown);
            
            obj.draw;
        end
        
        function setColor(obj, dColor)
            dBGImg = dColor'*obj.getRand;
            dBGImg = repmat(permute(dBGImg, [2 3 1]), [1 2 1]);
            set(obj.hI.hBG, 'CData', dBGImg);
        end
        
        function delete(obj, ~, ~)
            delete([obj.hA]);
            delete([obj.hListeners]);
            delete@handle(obj)
        end
        
        function setPosition(obj, iX, iY, iWidth, iHeight)
            for iI = 1:length(obj)
                set(obj(iI).hA, ...
                    'Position'      , [iX(iI), iY(iI), iWidth(iI), iHeight(iI)], ...
                    'XLim'          , [0, iWidth(iI)] + 0.5, ...
                    'YLim'          , [0, iHeight(iI)] + 0.5);
            end
        end        
        
        function fill(obj)
            set(obj.hT, 'String', obj.hData.Name);
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
        
        [iView, iDimInd] = isOver(obj, hOver)
        
    end
    
    methods (Access = private)
        
        function mouseDown(obj, ~, ~)
            hOver = hittest();
            switch hOver
                case obj.hI.hBG
                    
                    % Change the active panel
                    obj.hParent.hActivePanel = obj;
                    obj.hParent.updateActivation();

                case obj.hT
                    if strcmp(obj.hParent.hF.SelectionType, 'open')
                        obj.hT.Editing = 'on';
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
