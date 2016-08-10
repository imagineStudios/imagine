classdef imagine < handle
%IMAGINE IMAGe visualization and evaluation engINE
%
%   IMAGINE starts the IMAGINE user interface without initial data
%
%   IMAGINE(DATA) Starts the IMAGINE user interface with one (DATA is 3D)
%   or multiple panels (DATA is 4D).
%
%   IMAGINE(DATA, PROPERTY1, VALUE1, ...)) Starts the IMAGINE user
%   interface with data DATA plus supplying some additional information
%   about the dataset in the usual property/value pair format. Possible
%   combinations are:
%
%       PROPERTY        VALUE
%       -------------------------------------------------------------------
%       'Name'          String: A name for the dataset
%       'Resolution'    [3x1] or [1x3] double: The voxel size of the first
%                       three dimensions of DATA.
%       'Units'         String: The physical unit of the pixels (e.g. 'mm')
%       'Mask'          A mask overlay for the image data. If size(4) of
%                       the mask is 1, the same mask is used for all
%                       timepoints (if more than one) of DATA.
%                       If a dfferent mask is supplied for each timepoint,
%                       the number of timepoints in mask and DATA have to
%                       be the same.
%       'Zoom'          Initial zoom level for DATA (scalar)
%       'Window'        [1x2] double vector indicating the initial lower
%                       and upper intensity values used for the scaling of 
%                       intensity.
%
%   IMAGINE(DATA1, DATA2, ...) Starts the IMAGINE user interface with
%   multiple panels, where each input can be either a 3D- or 4D-array. Each
%   dataset can be defined more detailedly with the properties above. 
%
%
% Examples:
%
% 1. >> load mri % Gives variable D
%    >> imagine(squeeze(D)); % squeeze because D is in rgb format
%
% 2. >> load mri % Gives variable D
%    >> imagine(squeeze(D), 'Name', 'Head T1', 'Resolution', [2.2 2.2 2.2*2.7], 'Orient', 'tra');
% This syntax gives a more realistic aspect ration if you rotate the data.
%
% For more information about the IMAGINE functions refer to the user's
% guide file in the documentation folder supplied with the code.
%
% Copyright 2016 Christian Wuerslin
% Contact: c.wuerslin@gmail.com
    
    % =====================================================================
    properties (Constant)
        sVERSION                = '3.0 Alpha';
        dFGCOLOR                = [0.18 0.20 0.25];       % Color scheme
        dBGCOLOR                = [0.18 0.20 0.25];       % Color scheme
        iMAXVIEWS               = 6;
        lWIP                    = false;                   % Show work-in-progress features
    end
    % =====================================================================
    
    
    
    % =====================================================================
    properties        
        % -----------------------------------------------------------------
        % Graphic object handle containers and other handles
        hF          % The main figure
        SView       % The views and its components
        SSidebar    % The sidebar and its components
        STooltip    % The tooltip and its components
        SAxes       % Miscellaneous axes
        SImgs       % Miscellaneous images
        STimers     % Timers to realize delayed actions
        % -----------------------------------------------------------------
        
        
        % -----------------------------------------------------------------
        % Data structures
        SData    = [];      % Structure with image date and its properties
        cMapping = {};      % Mapping between data in SData and views  
        SAction  = [];      % Structure to store information for mouse actions
        SMenu               % A menu item structure
        SSliders            % A slider structure
        % -----------------------------------------------------------------
        
        
        % -----------------------------------------------------------------
        iIconSize       = 64;
        iViews          = 0;
        iStartSeries    = 1;
        dGrid           = 0;        % Distance between grid lines, 0 = off, -1 = show axes center for 3D view
        lRuler          = false;
        dColWidth       = [1 1 1 1 1 1];
        dRowHeight      = [1 1 1 1 1 1];
        iSidebarWidth   = 0;
        sPath           = pwd;
        dColormap
        sColormap
        iBoxPermutation = 1:3;
        sROIMode        = 'none';
    end
    % =====================================================================
    
    
    
    % =====================================================================
    methods (Access = public)
        
        % -----------------------------------------------------------------
        function obj = imagine(varargin)
        %IMAGINE Constructor    

            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Get the input data
            if ~isempty(varargin)
                obj.parseInputs(varargin{:});
            end

            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Create all the GUI elements
            obj.createGUIElements;
            obj.setColormap('Gray');
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % Do final steps for figure drawing
            if strcmp(get(obj.hF, 'WindowStyle'), 'docked')
                obj.SMenu(strcmp({obj.SMenu.Name}, 'dock')).Active = 1;
            end
            obj.SMenu(strcmp({obj.SMenu.Name}, 'sidebar')).Active = obj.iSidebarWidth > 0;
            obj.updateActivation;
            set(obj.hF, 'Visible', 'on'); % Triggers the resize function
            obj.draw;
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % If docked, return focus to console
            if strcmp(get(obj.hF, 'WindowStyle'), 'docked')
                pause(0.3);
                commandwindow;
            end
            
            obj.SAction.lShift = false;
            obj.SAction.lControl = false;
            obj.SAction.lAlt = false;
            obj.SAction.sSelectionType = 'normal';
            obj.SAction.lMoved = false;
            obj.SAction.iOldToolInd = 0;
            
            start(obj.STimers.hDraw);
            
        end
        % END IMAGINE Constructor
        % -----------------------------------------------------------------
        
        % -----------------------------------------------------------------
        % Some more public functions
        plus(obj, xImg, varargin)
        minus(obj, iInd)
        times(obj, dFactor)
        rdivide(obj, dDivisor)
        mtimes(obj, dFactor)
        mdivide(obj, dDivisor)
        close(obj, hObject, eventdata)
        setViews(obj, iCols, iRows)
        colon(obj, varargin)
        disp(obj)
        % -----------------------------------------------------------------
        
        SData = exportData(obj, iInd)
    end
    % =====================================================================
    
    
    
    % =====================================================================
    methods (Access = private)
        
        % -----------------------------------------------------------------
        % Figure callbacks
        resize(obj, hObject, eventdata);
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Mouse callbacks
        mouseMove(obj, hObject, eventdata)
        utilMove(obj, hObject, eventdata)
        
        viewDown(obj, hObject, eventdata)
        utilDown(obj, hObject, eventdata)
        iconDown(obj, hObject, eventdata)
        dividerDown(obj, hObject, eventdata)
        sliderDown(obj, hObject, eventdata)
        
        viewDrag(obj, hObject, eventdata)
        dividerDrag(obj, hObject, eventdata)
        sliderDrag(obj, hObject, eventdata)
        
        viewUp(obj, hObject, eventdata)
        dividerUp(obj, hObject, eventdata)
        sliderUp(obj, hObject, eventdata)
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Keyboard callbacks
        keyPress(obj, hObject, eventdata)
        keyRelease(obj, hObject, eventdata)
        
        changeImg(obj, hObject, iCnt)
        % -----------------------------------------------------------------
        
        loadFiles(obj)
        
        % -----------------------------------------------------------------
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Rendering core
        draw(obj, hObject, eventdata)
        position(obj)
        grid(obj)
        
        showPosition(obj, sMode)
        
        drawFocus(obj, dCoord_mm)
        drawGraph(obj)
        drawHistogram(obj, iView)
        
        tooltip(obj, sString, eventdata)
        contextMenu(obj, iInd, eventdata)
        
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Data access helpers
        dZLim = get3Lim(obj, iSeries, iDim)
        iSliceInd = getSliceInd(obj, d3Lim_mm, iSeries, iDim)
        [dImg, dXData, dYData] = getData(obj, SView, lMask, lHD)
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % GUI state helpers
        iView = getView(obj)
        sTool = getTool(obj)
        sMode = getSidebarMode(obj)
        sMode = getDrawMode(obj)
        dVal  = getSlider(obj, sName)
        lOn   = isOn(obj, sTag)
        
        updateData(obj, hObject, eventdata)
        
        setViewMapping(obj)
        setColormap(obj, sName)
        
        iImg = screenshot(obj)
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Conversion helpers
        dCoord_mm = pixel2Phys(obj, dCoord_px, iSeries, iDims)
        dCoord_px = phys2Pixel(obj, dCoord_mm, iSeries, iDims)
        
        parseInputs(obj, varargin)
        createGUIElements(obj)
        restoreGrid(obj, hObject, eventdata)
        updateActivation(obj)
        % -------------------------------------------------------------
        
    end
    % =====================================================================
    
    
    
    % =====================================================================
    methods (Static)
        csColormaps = getColormaps
        dColormapImg = getColormapImg(csColormaps)
        csRegistrations = getRegistrations
    end
    % =====================================================================
    
end
