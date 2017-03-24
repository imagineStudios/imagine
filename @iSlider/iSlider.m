classdef iSlider < handle
    
    properties
        Name        = 'Slider'
        Value       = 0
        Lim         = [0 1]
        Ticks       = []
        Snap        = 0
        Position    = [1 1 100 10]
        Callback    = function_handle.empty()
        Format      = '';
    end
    
    properties (Access = private)
        Parent      = matlab.graphics.axis.Axes.empty()
        
        hL          = matlab.graphics.primitive.Line.empty()               % Line components
        hS          = matlab.graphics.chart.primitive.Scatter.empty()      % Scatter components
        hT          = matlab.graphics.primitive.Text.empty()
        
        dTextWidth  = 50
        dSliderWidth= 50
        
        dColor      = [1 1 1]
        
        hListeners
    end
    
    methods
        
        function obj = iSlider(varargin)
            
            % -------------------------------------------------------------------------
            % Parse optional parameter-value pairs
            hP = inputParser();
            
            hP.addParameter('Parent', matlab.graphics.axis.Axes.empty, @(x) isa(x, 'matlab.graphics.axis.Axes'));
            hP.addParameter('Name', '', @ischar);
            hValidFcn = @(x) validateattributes(x, {'numeric'}, {'scalar'});
            hP.addParameter('Value', 0, hValidFcn);
            hP.addParameter('Snap', 0, hValidFcn);
            hValidFcn = @(x) validateattributes(x, {'numeric'}, {'numel', 2});
            hP.addParameter('Lim', [0 1], hValidFcn);
            hValidFcn = @(x) validateattributes(x, {'numeric'}, {'vector'});
            hP.addParameter('Ticks', [0 1], hValidFcn);
            hValidFcn = @(x) validateattributes(x, {'numeric'}, {'numel', 4});
            hP.addParameter('Position', [1 1 100 10], hValidFcn);
            hP.addParameter('Callback', function_handle.empty, @(x) isa(x, 'function_handle'));
            hP.addParameter('Format', '', @ischar);
            
            hP.parse(varargin{:});
            
            cFN = fieldnames(hP.Results);
            for iI = 1:length(cFN)
                obj.(cFN{iI}) = hP.Results.(cFN{iI});
            end
            % -------------------------------------------------------------------------
            
            if isempty(obj.Parent)
                obj.Parent = gca;
            end
            
            obj.hT = text(1, 1, obj.Name, ...
                'Parent'                , obj.Parent, ...
                'Color'                 , 'w', ...
                'FontSize'              , 14, ...
                'HorizontalAlignment'   , 'left', ...
                'VerticalAlignment'     , 'middle');
            
            obj.hL = line(...
                'Parent'                , obj.Parent, ...
                'XData'                 , [], ...
                'YData'                 , [], ...
                'LineWidth'             , 2, ...
                'Color'                 , 'w');
            try set(obj.hL, 'AlignVertexCenters', 'on'); end
            
            obj.hS = scatter([1, 2], [1, 0], 144, 'o', ...
                'Parent'                , obj.Parent, ...
                'MarkerEdgeColor'       , 'none', ...
                'MarkerFaceColor'       , obj.dColor, ...
                'Visible'               , 'on', ...
                'Hittest'               , 'on');
            
            set(obj.hS.MarkerHandle, ...
                'FaceColorBinding'      , 'interpolated', ...
                'FaceColorData'         , uint8([255 0; 255 0; 255 0; 255 64]));
            
            obj.dTextWidth = 14.*length(obj.Name).*0.6;
            
            obj.position;
            obj.draw;
            drawnow
            obj.draw;
            
            obj.hListeners = addlistener(get(obj.Parent, 'Parent'), 'WindowMousePress'  , @obj.mouseDown);
            obj.hListeners(2) = addlistener(get(obj.Parent, 'Parent'), 'WindowMouseMotion'  , @obj.mouseMove);
            obj.hListeners(3) = addlistener(get(obj.Parent, 'Parent'), 'WindowMouseRelease'  , @obj.mouseUp);
            obj.hListeners(2).Enabled = false;
            obj.hListeners(3).Enabled = false;
            obj.hListeners(4) = addlistener(obj.Parent, 'ObjectBeingDestroyed' , @obj.delete);
        end
        
        
        function delete(obj, ~, ~)
            delete([obj.hListeners]);
            delete@handle(obj)
        end
        
        
        function position(obj)
            obj.dSliderWidth = obj.Position(3) - obj.dTextWidth;
            
            set(obj.hT, 'Position', [obj.Position(1), obj.Position(2) + 2]);
            set(obj.hL, ...
                'XData'                 , obj.Position(1) + obj.dTextWidth + [0, obj.dSliderWidth], ...
                'YData'                 , [obj.Position(2), obj.Position(2)]);
        end
        
        
        function draw(obj)
            dPos = obj.val2Pos(obj.Value);
            set(obj.hS, 'XData', dPos(1) + [2, 0], 'YData', dPos(2) + [2, 0]);
            set(obj.hS.MarkerHandle, ...
                'FaceColorBinding'      , 'interpolated', ...
                'FaceColorData'         , uint8([0 255; 0 255; 0 255; 96 255]));
        end
        
        
        function enableCallbacks(obj, lEnable)
            obj.hListeners(1).Enabled = lEnable;
        end
        
    end
    
    
    methods (Access = private)
        
        function mouseDown(obj, ~, ~)
            hOver = hittest();
            if hOver == obj.hS || hOver == obj.hL
                obj.hListeners(3).Enabled = true;
                obj.hListeners(2).Enabled = true;
            end
        end
        
        function mouseMove(obj, ~, ~)
            dVal = obj.pos2Val(get(obj.Parent, 'CurrentPoint'));
            obj.Value = min(obj.Lim(2), max(obj.Lim(1), dVal));
            
            if diff(obj.Lim > 10), obj.Value = round(obj.Value); end
            
            if isempty(obj.Format)
                if diff(obj.Lim) <= 10
                    sValue = num2str(obj.Value);
                elseif diff(obj.Lim) <= 1000
                    sValue = sprintf('%d', obj.Value);
                else
                    sValue = sprintf('%2.1e', obj.Value);
                end
            else
                sValue = sprintf(obj.Format, obj.Value);
            end
            obj.hT.String = sValue;
            
            obj.draw();
            if ~isempty(obj.Callback)
                obj.Callback();
            end
        end
        
        function mouseUp(obj, ~, ~)
            obj.hListeners(2).Enabled = false;
            obj.hListeners(3).Enabled = false;
            obj.hT.String = obj.Name;
        end
        
        function dPos = val2Pos(obj, dVal)
            dPosRange = get(obj.hL, 'XData');
            
            dX = dPosRange(1) + dVal./diff(obj.Lim).*diff(dPosRange);
            
            dPos = [dX, obj.Position(2)];
        end
        
        function dVal = pos2Val(obj, dPos)
            dX = dPos(1);
            dPosRange = get(obj.hL, 'XData');
            
            dVal = (dX - dPosRange(1)).*diff(obj.Lim)./diff(dPosRange);
            
        end
    end
    
end
