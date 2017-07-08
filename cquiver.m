classdef cquiver < handle
%CQUIVER Quiver with individual colors and great performance
%
% CQUIVER(x, y, u, v, c)
%   Create quiver plot in current axes as arrows with components (u, v) at
%   the points (x, y). x, y, u and v need to have the same number of elements.
%   Parameter c can either contain individual color data in RGB true-color
%   format, i.e. size(c) = [numel(x) x 3], or can be either one of the
%   following strings (which set the CDataMode property):
%       'Mag'       : Chose color according to vector magnitude, mapped to
%                     the figure's colormap
%       'Angle'     : Chose color according to vector direction
%                     (x = red, y = green)
%
% CQUIVER(u, v, c)
%   Same as above but creates an equally spaced mesh to show the arrows
%   according to the size of u
%
% CQUIVER(..., scale)
%   Automatically scales the arrows to fit within the grid and then
%   stretches them by the factor scale.
%
% CQUIVER(..., 'PropertyName', 'PropertyValue')
%   specifies property name and property value pairs. See class properties
%   for overview of user-accessible properties
%
% CQUIVER(axes_handle, ...)
%   plots into the axes with the handle axes_handle instead of the current
%   axes (gca)
%
% h = CQUIVER(...)
%   returns the handle to the cquiver object
%
% (c) 2016 Christian Wuerslin, Stanford University
%
% See also: quiver, line
    
    % =====================================================================
    % Class properties
    properties (SetObservable = true)
        UData                           % x-component of velocity vectors
        VData                           % y-component of velocity vectors
        XData                           % x-coordinate of vector origins
        YData                           % y-coordinate of vector origins
        CData               = []        % RGB color data for each vector (for CDataMode = 'direct')
        CDataMode           = 'direct'  % Determines coloring mode ('mag', 'angle' or 'direct')
        CDataMapping        = 'scaled'  % Determines colormap scaling for CDataMode = 'mag'
        AlphaData           = 1;        % Opacity of the arrows
        LineWidth           = 0.5       % Thickness of the vectors
        ShowArrowHead       = 'on'      % Arrowhead display
        MaxHeadSize         = 0.3       % As fraction of arrow length
        AutoScale           = 'on'      % If on, scales vectors to fit into the grid
        AutoScaleFactor     = 0.9       % Factor to modify the vector length (1 means minimum grid spacing)
        AlignVertexCenters  = 'off'     % Sharp vertical and horizontal lines
        Visible             = 'on'      % Visibility of quiver series
        DisplayName         = ''        % Text used by legend
        Parent                          % Parent of quiver series
        ButtonDownFcn       = ''        % Mouse-click callback
        UIContextMenu                   % Conext menu
        Selected            = 'off'     % Selection state
        SelectionHighlight  = 'on'      % Display of selection handles when selected
        PickableParts       = 'visible' % Ability to capture mouse clicks
        HitTest             = 'on'      % Response to captured mouse clicks
        Interruptible       = 'on'      % Callback interruption
        BusyAction          = 'queue'   % Callback queuing
        
    end
    
    properties
        Tag                 = ''        % User-specified tag
        UserData            = []        % Data associated with quiver series
    end
    
    properties (Constant)
        Type                = 'cquiver' % Type of graphics object
    end
    
    properties (Access = private)
        hL                              % The line object to draw the arrows
        dLineX                          % The underlying line data
        dLineY
        iCData
        hListeners
        sColorType          = 'truecolor'
    end
    % END of properties
    % =====================================================================
    
    % =====================================================================
    % Class methods
    methods
        
        function obj = cquiver(varargin)
            % Constructor. See class description for syntax.
            
            % -------------------------------------------------------------
            % Process the input data and set properties accordingly
            obj.parseInputs(varargin);
            
            % -------------------------------------------------------------
            % Determine the drawing axes and figure
            if isempty(obj.Parent)
                obj.Parent = gca;
            end
            hF = obj.Parent.Parent; % TODO: Will not work if axes on a panel
            
            % -------------------------------------------------------------
            % Create the line object used for drawing the vectors
            obj.hL = line('XData'               , [], ...
                          'YData'               , [], ...
                          'LineWidth'           , obj.LineWidth, ...
                          'Parent'              , obj.Parent, ...
                          'AlignVertexCenters'  , obj.AlignVertexCenters, ...
                          'Visible'             , obj.Visible, ...
                          'DisplayName'         , obj.DisplayName, ...
                          'ButtonDownFcn'       , obj.ButtonDownFcn, ...
                          'UIContextMenu'       , obj.UIContextMenu, ...
                          'Selected'            , obj.Selected, ...
                          'SelectionHighlight'  , obj.SelectionHighlight, ...
                          'PickableParts'       , obj.PickableParts, ...
                          'HitTest'             , obj.HitTest, ...
                          'Interruptible'       , obj.Interruptible, ...
                          'BusyAction'          , obj.BusyAction);
            drawnow expose
            
            % -------------------------------------------------------------
            % Add listeners so graph gets updated when properties change
            obj.hListeners = addlistener(obj, {'UData', 'VData'}, 'PostSet', @obj.changeUVData);
            obj.hListeners(2) = addlistener(obj, {'XData', 'YData'}, 'PostSet', @obj.changeArrows);
            obj.hListeners(3) = addlistener(obj, 'CData', 'PostSet', @obj.changeCData);
            obj.hListeners(4) = addlistener(obj, {'CDataMode', 'CDataMapping', 'AlphaData'}, 'PostSet', @obj.changeColor);
            obj.hListeners(5) = addlistener(obj, {'MaxHeadSize', 'AutoScale', 'AutoScaleFactor'}, 'PostSet', @obj.changeArrows);
            obj.hListeners(6) = addlistener(obj, 'ShowArrowHead', 'PostSet', @obj.changeArrowsAndColor);
           
            % These properties are directly forwarded to the line object
            obj.hListeners(7) = addlistener(obj, ...
                {'Parent', 'LineWidth', 'AlignVertexCenters', 'Visible', 'DisplayName', 'ButtonDownFcn', ...
                 'UIContextMenu', 'Selected', 'SelectionHighlight', 'PickableParts', 'HitTest', ...
                 'Interruptible', 'BusyAction'}, ...
                 'PostSet', @obj.changeLineProperty);
            
            % -------------------------------------------------------------
            % Add listeners for parent properties that influence appearance
            obj.hListeners(8) = addlistener(hF, 'Colormap', 'PostSet', @obj.changeColor);
            obj.hListeners(9) = addlistener(obj.Parent, 'CLim', 'PostSet', @obj.changeColor);
            obj.hListeners(10) = addlistener(obj.Parent, 'ObjectBeingDestroyed', @obj.delete);
            
            % -------------------------------------------------------------
            % Draw the cquiver plot
            obj.getLineData;
            obj.getCData;
            obj.draw;
        end
        
        function delete(obj, ~, ~)
            % Destructor
            delete(obj.hL);
            delete(obj.hListeners);
            delete@handle(obj);
        end
        
        function set(obj, sName, xValue)
            % Use to set properties using set(...) syntax
            obj.(sName) = xValue;
        end
        
        function xVal = get(obj, sName)
            % Use to get properties using get(...) syntax
            xVal = obj.(sName);
        end
    end
    % =====================================================================
    
    
    % =====================================================================
    methods (Access = private)
        
        function draw(obj)
            % Applies the private properties dLineX, dLineY and iCData to
            % the line object
            
            set(obj.hL, ...
                'XData'         , obj.dLineX, ...
                'YData'         , obj.dLineY, ...
                'LineWidth'     , obj.LineWidth);
            
            set(obj.hL.Edge, ...
                'ColorBinding'  , 'interpolated', ...
                'ColorType'     , obj.sColorType, ...
                'ColorData'     , obj.iCData)
            
        end
        
        
        function getLineData(obj)
            % Calculate the arrows (dLineX and dLineY) from the public
            % properties
            
            % -------------------------------------------------------------
            % Pre-process the vector data
            dU = obj.UData(:)';
            dV = obj.VData(:)';
            
            dU(isnan(dU)) = 0;
            dV(isnan(dV)) = 0;
            
            % -------------------------------------------------------------
            % Scale the vectors if desired
            if strcmp(obj.AutoScale, 'on')
                dD = min(abs([diff(unique(obj.XData(:))); diff(unique(obj.YData(:)))]));
                if isempty(dD), dD = 1; end
                dLength = sqrt(max(dU.^2 + dV.^2));
                dScaleFactor = dD./dLength.*obj.AutoScaleFactor;
                dU = dU.*dScaleFactor;
                dV = dV.*dScaleFactor;
            end
            
            % -------------------------------------------------------------
            % Calculate dLineX and dLineY
            if strcmp(obj.ShowArrowHead, 'on')
            
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Create the arrowhead end points
                dUV = [dU; dV]';
                dArrow1 = obj.MaxHeadSize.*(dUV*obj.fRotation(20/180.*pi))';
                dArrow2 = obj.MaxHeadSize.*(dUV*obj.fRotation(-20/180.*pi))';
                
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Create the line data of the arrows, such that it can be
                % displayed using a single line
                dL = numel(obj.XData);
                dX = repmat(obj.XData(:)', [7, 1]) + ...
                     [zeros(1, dL); dU; dU - dArrow1(1, :); ...
                        nan(1, dL); dU; dU - dArrow2(1, :); ...
                        nan(1, dL)];
                
                dY = repmat(obj.YData(:)', [7, 1]) + ...
                     [zeros(1, dL); dV; dV - dArrow1(2, :); ...
                        nan(1, dL); dV; dV - dArrow2(2, :); ...
                        nan(1, dL)];
            else
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % No arrowheads
                dX = [obj.XData(:), obj.XData(:) + dU', nan(numel(obj.XData), 1)]';
                dY = [obj.YData(:), obj.YData(:) + dV', nan(numel(obj.YData), 1)]';
            end
            obj.dLineX = dX(:);
            obj.dLineY = dY(:);
        end
        
        
        function getCData(obj)
            % Calculate the colordata (iCData) from the public properties
            
            dU = obj.UData(:);
            dV = obj.VData(:);
            
            switch lower(obj.CDataMode)
                
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Angle: Chose color according to vector orientation
                % (x = red, y = green)
                case 'angle'
                    dLength = sqrt(dU.^2 + dV.^2);
                    dLength(dLength == 0) = 1;
                    dC = [abs(dU), abs(dV), zeros(size(dU))]./repmat(dLength, [1 3]);
                
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Mag: Chose color according to vector length
                case 'mag'
                    dLength = sqrt(dU.^2 + dV.^2);
                    
                    % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
                    % Determine the normalized color for colormap lookup
                    if strcmpi(obj.CDataMapping, 'direct')
                        % Use axes' CLim to determine color
                        dCLim = obj.Parent.CLim;
                        dLength = dLength - dCLim(1);
                        dLength = dLength./dCLim(2);
                        dLength(dLength < 0) = 0;
                        dLength(dLength > 1) = 1;
                    else
                        % Auto-scaled (0..1)
                        dLength = dLength - min(dLength);
                        dLength = dLength./max(dLength);
                    end
                    
                    % -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
                    % Lookup corresponding colors in figure's colormap
                    dColormap = obj.Parent.Parent.Colormap;
                    iInd = round(dLength.*(length(dColormap) - 1)) + 1;
                    iInd(isnan(iInd)) = 1;
                    dC = dColormap(iInd, :);
                
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Direct: User supplies color of each location in CData
                case 'direct'
                    dC = obj.CData;
                    
            end
            
            dAlpha = obj.AlphaData;
            if isscalar(dAlpha)
                dAlpha = dAlpha.*ones(size(dC, 1), 1);
            end
            
            if isscalar(obj.AlphaData) && obj.AlphaData == 1
                obj.sColorType = 'truecolor';
            else
                obj.sColorType = 'truecoloralpha';
            end
            
            dC = [dC, dAlpha]';
            if strcmp(obj.ShowArrowHead, 'on')
                dC = reshape(repmat(dC, [5 1]), 4, []);
            else
                dC = reshape(repmat(dC, [2 1]), 4, []);
            end
            dC(dC < 0) = 0;
            dC(dC > 1) = 1;
            obj.iCData = uint8(dC*255);
            
        end
        
        
        function autoMesh(obj)
            dX = 1:iMeshSize(2);
            dY = 1:iMeshSize(1);
            [obj.XData, obj.YData] = meshgrid(dX, dY);
        end
        
        
        function changeLineProperty(obj, property, ~)
            obj.hL.(property.Name) = obj.(property.Name);
        end
        
        
        function changeUVData(obj, ~, ~)
            obj.getLineData;
            if ~strcmp(obj.CDataMode, 'direct')
                obj.getCData;
            end
            obj.draw;
        end
        
        
        function changeCData(obj, ~, ~)
            obj.CDataMode = 'direct';
            obj.getCData;
        end
        
        
        function changeArrows(obj, ~, ~)
            obj.getLineData;
            obj.draw;
        end
                
        
        function changeColor(obj, ~, ~)
            obj.getCData;
            obj.draw;
        end
        
        
        function changeArrowsAndColor(obj, ~, ~)
            obj.getLineData;
            obj.getCData;
            obj.draw;
        end
        
        
        function parseInputs(obj, cParams)

            if length(cParams) < 3, error('At least 3 inputs required!'); end
            
            iOffset = 1;
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Check for the syntax supplying an axes handle
            if numel(cParams{1}) == 1
                if isobject(cParams{1})
                    
                    % Return axes handle in hA
                    obj.Parent = cParams{iOffset};
                    iOffset = 2;
                    if ~isa(obj.Parent, 'matlab.graphics.axis.Axes')
                        error('First input argument is not an axes object!');
                    end
                    
                    if length(cParams) < 3, error('When supplying an axes handle, at least 4 inputs required!'); end
                end
            end
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Check the first two input required arguments: either x, y or u, v
            obj.XData = cParams{iOffset}; % assume x, y for now
            obj.YData = cParams{iOffset + 1};
            
            validateattributes(obj.XData, {'numeric'}, {'2d', 'real'}, iOffset);
            validateattributes(obj.YData, {'numeric'}, {'size', size(obj.XData), 'real'}, iOffset + 1);
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Check for syntax ommiting x and y (next argument is colordata)
            if ischar(cParams{iOffset + 2})  ||  numel(cParams{iOffset + 2}) ~= numel(cParams{iOffset})
                % Input 3 is color data: Generate the mesh data
                obj.UData = obj.XData;
                obj.VData = obj.YData;
                
                obj.autoMesh;
                
                iOffset = iOffset + 2; % Now iOffset points to color data
            else
                % Inputs 3 and 4 are vector data
                obj.UData = cParams{iOffset + 2};
                obj.VData = cParams{iOffset + 3};
                
                validateattributes(obj.UData, {'numeric'}, {'numel', numel(obj.XData), 'real'}, iOffset + 2);
                validateattributes(obj.VData, {'numeric'}, {'numel', numel(obj.XData), 'real'}, iOffset + 3);
                
                iOffset = iOffset + 4; % Now iOffset points to color data
            end            
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Check the colordata - set colordata mode
            obj.CData = cParams{iOffset};
            
            if ischar(obj.CData)
                if ~any(strcmpi(obj.CData, {'mag', 'angle'}))
                    error('Colordata must be either RGB data, ''mag'', or ''angle''!');
                end
                obj.CDataMode = lower(obj.CData);
            else
                validateattributes(obj.CData, {'double', 'single'}, {'size', [numel(obj.XData), 3], 'real'}, iOffset);
            end
            iOffset = iOffset + 1;
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Check for scale data - set scale mode
            if iOffset <= length(cParams)
                if isnumeric(cParams{iOffset})
                    
                    obj.AutoScaleFactor = cParams{iOffset};
                    if obj.AutoScaleFactor == 0, obj.AutoScale = 'off'; end
                    
                    iOffset = iOffset + 1;
                end
            end
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Check additional param-value pairs
            if iOffset <= length(cParams)
                p = inputParser();
                addParameter(p, 'LineWidth', 0.5);
                addParameter(p, 'Parent', obj.Parent);
                addParameter(p, 'AlignVertexCenters', 'off');
                addParameter(p, 'Visible', 'on');
                addParameter(p, 'DisplayName', '');
                addParameter(p, 'ButtonDownFcn', '');
                addParameter(p, 'UIContextMenu', '');
                addParameter(p, 'Selected', 'off');
                addParameter(p, 'SelectionHighlight', 'on');
                addParameter(p, 'PickableParts', 'visible');
                addParameter(p, 'HitTest', 'on');
                addParameter(p, 'Interruptible', 'on');
                addParameter(p, 'BusyAction', 'queue');
                parse(p, cParams{iOffset:end});
                cFN = fieldnames(p.Results);
                for iI = 1:length(cFN)
                    obj.(cFN{iI}) = p.Results.(cFN{iI});
                end
            end
            
        end        
        
    end
    
    methods (Static, Access = private)
        
        function dRot = fRotation(dAlpha)
            %fROTATION Creates a 2D rotation matrix of angle dALPHA
            
            dRot = [cos(dAlpha), -sin(dAlpha)
                    sin(dAlpha), cos(dAlpha)];
        end
        
    end
    % END of class methods
    % =====================================================================
        
end