classdef iView < handle
    
    properties
        Parent = imagine.empty
    end
    
    properties(SetObservable = true)
        Position
        Zoom            = 1
        DrawCenter      = []
        iDimInd         = 1;
        hData           = [];
    end
    
    properties (Access = private)
        hA          % Axes
        hI          % Image components
        hQ          % Quiver components
        hL          % Line components
        hS          % Scatter components
        hT          % Text components
        
        iInd        = 0
        
    end
    
    methods
        function obj = iView(hImagine, iInd)
            
            obj.Parent = hImagine;
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % View axes and its children
            obj.hA = axes(...
                'Parent'            , hImagine.hF, ...
                'Layer'             , 'top', ...
                'Units'             , 'pixels', ...
                'Color'             , 'k', ...
                'FontSize'          , 12, ...
                'XTickMode'         , 'manual', ...
                'YTickMode'         , 'manual', ...
                'XColor'            , [0.5 0.5 0.5], ...
                'YColor'            , [0.5 0.5 0.5], ...
                'XTickLabelMode'    , 'manual', ...
                'YTickLabelMode'    , 'manual', ...
                'XAxisLocation'     , 'top', ...
                'YDir'              , 'reverse', ...
                'Box'               , 'on', ...
                'HitTest'           , 'on', ...
                'XGrid'             , 'off', ...
                'YGrid'             , 'off', ...
                'XMinorGrid'        , 'off', ...
                'YMinorGrid'        , 'off');
            hold on
            
            obj.hI = image( ...
                'Parent'                , obj.hA, ...
                'CData'                 , zeros(1, 1, 3), ...
                'HitTest'               , 'off');
            
            try set(obj.hA, 'YTickLabelRotation', 90); end
            
            obj.iInd = iInd;
            
            uistack(obj.hA, 'bottom');
            
            addlistener(obj, {'Position', 'DrawCenter', 'Zoom'}, 'PostSet', @obj.setPosition);
            addlistener(obj, 'DrawCenter', 'PostSet', @obj.draw);
            addlistener(hImagine, 'viewImageChange', @obj.draw);
            addlistener(hImagine, 'ViewMapping', 'PostSet', @obj.updateMapping);
            addlistener(obj.Parent, 'ObjectBeingDestroyed', @obj.delete);
            
            obj.updateMapping;
        end
        
        function delete(obj, ~, ~)
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
    end
    
    methods(Access = private)
        
        setPosition(obj, ~, ~)
        position(obj, ~, ~)
        
        function updateMapping(obj, ~, ~)
            obj.hData = obj.Parent.hData(obj.Parent.ViewMapping{obj.iInd});
            if isempty(obj.DrawCenter) && ~isempty(obj.hData)
                obj.DrawCenter = obj.hData(1).getSize./2;
                obj.DrawCenter = padarray(obj.DrawCenter, [0, 5 - length(obj.DrawCenter)], 1, 'post');
            end
        end
        
        function iOrient = getOrientation(obj)
            
        end
        
        
    end
end
