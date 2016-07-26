function S = initData(dData, iInd)

if ~isnumeric(dData) && ~islogical(dData)
    error('Data must be numeric or logical!');
end

S.dImg          = [];
S.iMask         = 0;
S.sUnits        = 'px';
S.dRes          = [];
S.dOrigin       = [];
S.dZoom         = 1;
S.sName         = sprintf('Input %d', iInd);
S.lInvert       = [0 0 0 0];
S.iDims         = [1 2 4; 1 4 2; 4 2 1];


% -------------------------------------------------------------------------
% Determine dynamic range
if isreal(dData)
    if numel(dData) > 1E6
        dMin = min(dData(1:100:end));
        dMax = max(dData(1:100:end));
    else
        dMin = min(dData(:));
        dMax = max(dData(:));
    end
else
    if numel(dData) > 1E6
        dMin = min(abs(dData(1:100:end)));
        dMax = max(abs(dData(1:100:end)));
    else
        dMin = min(abs(dData(:)));
        dMax = max(abs(dData(:)));
    end
end
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