function plus(obj, xImg, varargin)
%PLUS Add a new series to the data structure
% PLUS(OBJ, DIMG, VARARGIN) Adds the data in structure SNEWDATA to the
% GUI's data structure. Depending on the dimensions of SNEWDATA.dIMG, it
% decides wether the data is to be interpretet as RGB of scalar data. It is
% treated as RGB, if size(SNEWDATA.dImg, 3) == 3. If not 3 but greater than
% 1, the third dimension is treated as the 3rd dimension.


% if isa(xImg, 'debugImg')
%     iDataInd = length(obj.SData) + 1;
%     if iDataInd == 1
%         obj.SData = xImg;
%     else
%         obj.SData(iDataInd) = xImg;
%     end
%     iMappingInd = size(obj.iMapping, 1) + 1;
%     obj.iMapping(iMappingInd, :) = [iDataInd, 0];
%     return
% end


% -------------------------------------------------------------------------
% If input is a struct, try to interpret the different fields
if isstruct(xImg)
    [dImg, cAdditionalInputs] = fStructToInput(xImg);
    varargin = [cAdditionalInputs varargin];
else
    dImg = xImg;
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Prepare template data structure for new entry
iDataInd = length(obj.SData) + 1;
SNewData = fInitData(dImg, iDataInd);
iDataMapping = length(obj.cMapping) + 1;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Parse for additional parameters
iI = 1;
while length(varargin) > iI % Only proceed if current field (name) is followed by another (value) field
    
    if ~ischar(varargin{iI}), error('Unexpected input found. Expected parameter name (string)!'); end
    xVal = varargin{iI + 1};
    
    switch lower(varargin{iI})
        
        case {'d', 'data'}
            iDataMapping = xVal;
            
        case {'m', 'mode'}
            SNewData.sMode = xVal;
            
        case {'s', 'source'}
            SNewData = fInitData(evalin('base', xVal), iDataInd);
            SNewData.sSource = xVal;
            SNewData.sName = sprintf('*%s @ base', xVal);

        case {'n', 'name'}
            if ~ischar(xVal), error('Name property must be a string!'); end
            SNewData.sName = xVal;
            
        case {'u', 'units'}
            if ~ischar(xVal), error('Units property must be a string!'); end
            SNewData.sUnits = xVal;
            
        case {'a', 'aspect', 'r', 'res', 'resolution'}
            if ~isnumeric(xVal) || numel(xVal) ~= 3, error('Voxelsize property must be a [3x1] or [1x3] numeric vector!'); end
            xVal = xVal(:)';
            SNewData.dRes = [xVal([1 2 3 3]) 1];
            
        case {'o', 'origin'}
            if ~isnumeric(xVal), error('Origin of data must be numeric!'); end
            if length(xVal) > 3, error('Origin of data cannot have more than 3 entries (x-y-z)!'); end
            xVal = xVal(:)';
            SNewData.dOrigin = [xVal([1 2 3 3]) 1];
                        
        case {'z', 'zoom'}
            if ~isnumeric(xVal), error('Zoom property must be a numeric scalar!'); end
            SNewData.dZoom = xVal;
            
        case {'w', 'window'}
            if ~isnumeric(xVal) || numel(xVal) ~= 2, error('Window limits property must be a [2x1] or [1x2] numeric vector!'); end
            SNewData.dWindowCenter = double(mean(xVal));
            SNewData.dWindowWidth  = double(abs(diff(xVal)));
            
        case {'orient', 'orientation'}
            if ~ischar(xVal), error('Orientation property must be a string (e.g. "tra")!'); end
            switch(lower(xVal))
                
                case {'t', 'tra', 'transversal'}
                    SNewData.iDims = [1 2 4; 4 2 1; 4 1 2];
                    SNewData.lInvert = [0 0 0 1];
                    
                case {'c', 'cor', 'coronal', 'p', 'phys', 'physical'}
                    SNewData.iDims = [1 2 4; 1 4 2; 4 2 1];
                    SNewData.lInvert = [0 0 0 0];
                    
                case {'s', 'sag', 'sagittal'}
                    SNewData.iDims = [1 2 4; 1 4 2; 2 4 1];
                    SNewData.lInvert = [0 0 0 0];
                    
                otherwise error('Orientation must be either "tra", "cor" or "sag"!');
            end
                        
        case {'v', 'views'}
            if ~isnumeric(xVal) || numel(xVal) > 2, error('Panel size must be a scalar of a [2x1] or [1x2] numeric vector!'); end
            if isscalar(xVal), xVal = repmat(xVal, [2 1]); end
            obj.iViews = xVal(:)';
            
        otherwise
            error('Unknown property ''%s''!', varargin{iI});
            
    end
    iI = iI + 2;
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Supplement the coordinate system data according to what's been supplied
if isempty(SNewData.dRes)
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % No resolution supplied -> set to ones
    SNewData.dRes = ones(1, 5);
    if isempty(SNewData.dOrigin)
        SNewData.dOrigin = ones(1, 5); % Set the MATLAB coordinate systen starting at 1 instead of 0
    end
    if isempty(SNewData.sUnits)
        SNewData.sUnits = 'px';
    end
else
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Resolution given
    if isempty(SNewData.dOrigin) % Assume user wants 0 as data origin
        SNewData.dOrigin = zeros(1, 5);
        SNewData.dOrigin(5) = 1; % Time origin is always 1
    end
    if isempty(SNewData.sUnits) % Assume mm resolution
        SNewData.sUnits = 'mm';
    end
end

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Center image and use first time point
SNewData.dDrawCenter = fSize(SNewData.dImg, 1:5).*SNewData.dRes/2 + SNewData.dOrigin;
SNewData.dDrawCenter(5) = 1;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Add new data to the mapping structure
if iDataMapping > length(obj.cMapping)
    obj.cMapping{iDataMapping} = iDataInd;
else
    if isempty(obj.cMapping{iDataMapping})
        obj.cMapping{iDataMapping} = iDataInd;
    else
        iMapping = [obj.cMapping{iDataMapping}, iDataInd];
        
        if all(fSize(obj.SData(iMapping(1)).dImg, [1 2 4]) == fSize(SNewData.dImg, [1 2 4])) && ...
                all(SNewData.dRes == 1) && all(SNewData.dOrigin == 1) && strcmp(SNewData.sUnits, 'px')
            
            % If no coordinate system is supplied for the new data and
            % data dimension matches, copy coordinate system of the first
            % data in mapping.
            SNewData.sUnits  = obj.SData(iMapping(1)).sUnits;
            SNewData.dRes    = obj.SData(iMapping(1)).dRes;
            SNewData.dOrigin = obj.SData(iMapping(1)).dOrigin;
            SNewData.lInvert = obj.SData(iMapping(1)).lInvert;
            SNewData.iDims   = obj.SData(iMapping(1)).iDims;
        end
        
        obj.cMapping{iDataMapping} = iMapping;
    end
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Add to the data structure
if iDataInd == 1
    obj.SData = SNewData;
else
    obj.SData(iDataInd) = SNewData;
end
% -------------------------------------------------------------------------

if strcmp(get(obj.hF, 'Visible'), 'on')
    if obj.isOn('2d') && size(obj.SView, 1) == 3 && size(obj.SView, 2) < 6
        obj.setViews(size(obj.SView, 1), size(obj.SView, 2) + 1);
    else
        obj.setViewMapping;
    end
end



function S = fInitData(dData, iInd)

if ~isnumeric(dData) && ~islogical(dData) && ~ischar(dData)
    error('Data must be numeric or logical!');
end

S.sSource       = '';
S.sName         = sprintf('Input %d', iInd);
S.sMode         = 'scalar';
S.dImg          = [];
S.sUnits        = [];
S.dRes          = [];
S.dOrigin       = [];
S.dZoom         = 1;
S.lInvert       = [0 0 0 0];
S.iDims         = [1 2 4; 1 4 2; 4 2 1];
    
% -------------------------------------------------------------------------
% Determine dynamic range
if isinteger(dData)
    if numel(dData) > 1E6
        [S.dHist, S.dHistCenter] = hist(double(dData(1:100:end)), 256);
    else
        [S.dHist, S.dHistCenter] = hist(double(dData(:)), 256);
    end
else
    if isreal(dData)
        if numel(dData) > 1E6
            [S.dHist, S.dHistCenter] = hist(dData(1:100:end), 256);
        else
            [S.dHist, S.dHistCenter] = hist(dData(:), 256);
        end
    else
        if numel(dData) > 1E6
            [S.dHist, S.dHistCenter] = hist(abs(dData(1:100:end)), 256);
        else
            [S.dHist, S.dHistCenter] = hist(abs(dData(:)), 256);
        end
    end
end
dMin = S.dHistCenter(1);
dMax = S.dHistCenter(end);
S.dWindowCenter = double(dMin + dMax)./2;
S.dWindowWidth  = double(dMax - dMin);
if S.dWindowWidth == 0, S.dWindowWidth = 1; end
S.dDynamicRange = [dMin, dMax];
% -------------------------------------------------------------------------



% -------------------------------------------------------------------------
if size(dData, 3) == 3 || size(dData, 3) == 1
    if ndims(dData) > 5, error('Too many input dimensions!'); end
else
    if ndims(dData) > 4, error('Too many input dimensions!'); end
    dData = permute(dData, [1 2 5 3 4]);
end
S.dImg = dData;
% -------------------------------------------------------------------------

if ~isempty(dData)
    if isfloat(dData)
        if size(dData, 3) == 3
            if ~isreal(dData), error('Vector/rgb data must be real!'); end
        end
    else
        if ~isreal(dData), error('Integer data must be real!'); end
        if S.dDynamicRange(2) <= 16
            S.sMode = 'categorical';
        end
    end
end






function [dImg, cAdditionalInputs] = fStructToInput(SImg)
dImg = [];
cAdditionalInputs = {};
csFields = fieldnames(SImg);
for iI = 1:length(csFields)
    
    xData = SImg.(csFields{iI});
    sName = lower(csFields{iI});
    
    % Check for image data
    if strdist(sName, 'img') < 2 || ...
       strdist(sName, 'image') < 2 || ...
       strdist(sName, 'data') < 2
        if isnumeric(xData) || islogical(xData)
            fprintf('Interpreting field ''%s'' as image data.\n', csFields{iI});
            dImg = xData;
            continue
        end
    end
    
    % Check for resolution
    if strdist(sName, 'res') < 2 || strdist(sName, 'resolution') < 2 || ...
            strdist(sName, 'aspect') < 2 || strdist(sName, 'voxelsize') < 2
        if isnumeric(xData) && numel(xData) < 5
            fprintf('Interpreting field ''%s'' as resolution data.\n', csFields{iI});
            cAdditionalInputs = [{'aspect'} {xData} cAdditionalInputs];
            continue
        end
    end
    
    % Check for origin
    if strdist(sName, 'org') < 2 || strdist(sName, 'origin') < 2
        if isnumeric(xData) && numel(xData) < 5
            fprintf('Interpreting field ''%s'' as origin data.\n', csFields{iI});
            cAdditionalInputs = [{'origin'} {xData} cAdditionalInputs];
            continue
        end
    end
    
    % Check for orientation
    if strdist(sName, 'orientation') < 2 || strdist(sName, 'orient') < 2
        if ischar(xData) && any(strcmp(xData, {'p','c','t','s','phys','tra','sag','cor','physical','transversal','sagittal','coronal'}))
            fprintf('Interpreting field ''%s'' as orientation data.\n', csFields{iI});
            cAdditionalInputs = [{'orientation'} {xData} cAdditionalInputs];
            continue
        end
    end
    
    fprintf('Could not interpret field ''%s''. Skipping...\n', csFields{iI});
end

if isempty(dImg)
    error('Could not identify any image data in struct input!');
end
