classdef CImagine < handle
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
        sVERSION                = '3.0 Alpha';          % Figure title
        iMAXVIEWS               = 6;                    % Maximum number of views per dimension
        iCOLORMAPLENTGH         = 2^10;
        iICONPADDING            = 8;
    end
    
    
    properties      
        
        % -----------------------------------------------------------------
        % Graphic object handle containers and other handles
        hF             = matlab.ui.Figure.empty()% The main figure
        STimers     % Timers to realize delayed actions
        
        % -----------------------------------------------------------------
        % Data and Views (custom classes)
        hTooltip        = CTooltip.empty()
        hViews          = CView.empty()
        
        % -----------------------------------------------------------------
        % GUI state
        SAction         = []        % Structure to store information for mouse actions
        SMenu                       % A menu item structure
        
        dGrid           = 0         % Distance between grid lines, 0 = off, -1 = show axes center for 3D view
        lRuler          = false
        dMinRes         = 1        % The minimum resolution in any of the datasets (used to determine what 100% is)
        
        SColormaps      = struct
        
        sTheme          = 'default'
        SColors
        
        sBasePath
    end
    
    properties(SetObservable = true)
        iActiveView     = 1;
        l3D             = false;
        hData           = CData.empty()  % Structure with image data and properties
    end
    
    
    properties (Access = private)
        hExplorer       = CExplorer.empty()
        SAxes       % Miscellaneous axes
        SImgs       % Miscellaneous images
        sPath           = pwd % The working directory
        iAxes           = [1, 1]
        dColWidth       = [1 1 1 1 1 1]
        dRowHeight      = [1 1 1 1 1 1]
        iIconSize       = 64
        sROIMode        = 'none'
    end
    % =====================================================================
    
    
    % =====================================================================
    methods (Access = public)
        
        % -----------------------------------------------------------------
        function obj = CImagine(varargin)
            %IMAGINE Constructor
            
            obj.sBasePath = fileparts(mfilename('fullpath'));
                        
            try
                obj.SColormaps = obj.getColormaps(obj.sBasePath, obj.iCOLORMAPLENTGH);
                
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Get the input data
                obj.parseInputs(varargin{:});
                
                if ~isempty(obj.hData)
                    iNViews = max(cell2mat({obj.hData.iViews}));
                    dRoot = sqrt(iNViews);
                    iViewsN = ceil(dRoot);
                    iViewsM = ceil(dRoot);
                    while iViewsN*iViewsM >= iNViews
                        iViewsN = iViewsN - 1;
                    end
                    iViewsN = iViewsN + 1;
                    iViewsN = min([4, iViewsN]);
                    iViewsM = min([4, iViewsM]);
                    obj.iAxes = [iViewsM, iViewsN];
                end
                
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Create all the GUI elements
                obj.createGUIElements;
                obj.setViews(obj.iAxes);
                
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Do final steps for figure drawing
                if strcmp(get(obj.hF, 'WindowStyle'), 'docked')
                    obj.SMenu(strcmp({obj.SMenu.Name}, 'dock')).Active = 1;
                end
                obj.updateActivation;
                set(obj.hF, 'Visible', 'on'); % Triggers the resize function, notifies the views
                
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % If docked, return focus to console
                if strcmp(get(obj.hF, 'WindowStyle'), 'docked')
                    pause(0.3);
                    commandwindow;
                end
                
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % Init the action structure
                obj.SAction.lShift = false;
                obj.SAction.lControl = false;
                obj.SAction.lAlt = false;
                obj.SAction.sSelectionType = 'normal';
                obj.SAction.lMoved = false;
                obj.SAction.iOldToolInd = 0;
                
                %             start(obj.STimers.hDraw);
            catch me
                
                % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
                % In case anything goes wrong, make sure the created
                % objects are deleted properly
                if ~isempty(obj.STimers)
                    csTimers = fieldnames(obj.STimers);
                    for iI = 1:length(csTimers)
                        stop(obj.STimers.(csTimers{iI}));
                        delete(obj.STimers.(csTimers{iI}));
                    end
                end
                delete(obj.hF); % Data and Views listen to destruction
                rethrow(me);
            end
            
        end
        % END IMAGINE Constructor
        % -----------------------------------------------------------------
        
        % -----------------------------------------------------------------
        % Some more public functions
        plus(obj, varargin)
        minus(obj, iInd)
        times(obj, dFactor)
        rdivide(obj, dDivisor)
        mtimes(obj, dFactor)
        mdivide(obj, dDivisor)
        close(obj, hObject, eventdata)
        setViews(obj, iCols, iRows)
        disp(obj)
        % -----------------------------------------------------------------
        
        SData = exportData(obj, iInd)
        
        dVal  = getSlider(obj, sName)
        sMode = getDrawMode(obj)
        lHD   = getHDMode(obj)
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
        
        viewDrag(obj, hObject, eventdata)
        dividerDrag(obj, hObject, eventdata)
        
        viewUp(obj, hObject, eventdata)
        dividerUp(obj, hObject, eventdata)
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Keyboard callbacks
        keyPress(obj, hObject, eventdata)
        keyRelease(obj, hObject, eventdata)
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        changeImg(obj, hObject, iCnt)
        % -----------------------------------------------------------------
        
        loadFiles(obj)
        
        % -----------------------------------------------------------------
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Rendering core
        draw(obj, ~, ~)
        contextMenu(obj, iInd, eventdata)
                
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % GUI state helpers
        sTool = getTool(obj)
        lOn   = isOn(obj, sTag)
        
        updateData(obj, hObject, eventdata)
        
        iImg = screenshot(obj)
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Conversion helpers
        parseInputs(obj, varargin)
        createGUIElements(obj)
        restoreGrid(obj, hObject, eventdata)
        updateActivation(obj)
        % -------------------------------------------------------------
        
    end
    % =====================================================================
    
    
    
    % =====================================================================
    methods (Static)
        csColormaps = getColormaps(sPath, iLength)
        csRegistrations = getRegistrations(obj)
    end
    % =====================================================================
    
end
