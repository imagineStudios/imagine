function SData = fNifTiRead(sFilename)

% Try big endian first
fid = fopen(sFilename, 'r', 'b');
if(fid < 0)
    error('Could not open the file ''%s''!\n', sFilename);
end

SHeader = fReadNIIHeader(fid);

if isempty(SHeader)
    
    % Try little endian'
    fclose(fid);
    fid = fopen(sFilename, 'r', 'l');
    
    SHeader = fReadNIIHeader(fid);
    
    if isempty(SHeader)
        error('File contents makes no sense!');
    end
end

SHeader
% -------------------------------------------------------------------------
% Read volume data
switch SHeader.iType
    case     1, dImg = fread(fid, SHeader.iNumEl,    'bit1=>uint8');
    case     2, dImg = fread(fid, SHeader.iNumEl,    '*uint8');
    case     4, dImg = fread(fid, SHeader.iNumEl,    '*int16');
    case     8, dImg = fread(fid, SHeader.iNumEl,    '*int32');
    case    16, dImg = fread(fid, SHeader.iNumEl,    '*float');
    case    32, dImg = fread(fid, SHeader.iNumEl.*2, '*float'); %Complex
    case    64, dImg = fread(fid, SHeader.iNumEl,    '*float');
    case   128, dImg = fread(fid, SHeader.iNumEl.*3, '*uint8'); % RGB
    case   256, dImg = fread(fid, SHeader.iNumEl,    'int8');
    case   512, dImg = fread(fid, SHeader.iNumEl,    '*uint16');
    case   768, dImg = fread(fid, SHeader.iNumEl,    '*uint32');
    case  1024, dImg = fread(fid, SHeader.iNumEl,    '*int64');
    case  1280, dImg = fread(fid, SHeader.iNumEl,    '*uint64');
    case  1792, dImg = fread(fid, SHeader.iNumEl.*2, '*float'); %Complex
    otherwise, error('Format not suported');
end
fclose(fid);
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Get the image into the right format
dImg = dImg.*SHeader.dSlope + SHeader.dIntercept;
switch SHeader.iType
    case {32, 1792} % Complex
        dImg = complex(dImg(1:2:end), dImg(2:2:end));
    case 128 % TODO: RGB
end
SData.dImg = reshape(dImg(:), SHeader.iDim');
SData.dAspect = SHeader.dAspect(1:ndims(SData.dImg));
SData.dOrigin = SHeader.dOrigin;

dInc = diag(SHeader.dS);
for iI = 1:size(SHeader.dS, 1)
    if dInc(iI) < 0
        SData.dImg = flip(SData.dImg, iI);
    end
end

SData.dImg = flip(SData.dImg, 1); % Because nifti uses RAS


SData.dImg = flip(permute(SData.dImg, [2 1 3 4])); % First NiFTi dimension is x
SData.dAspect(1:2) = SData.dAspect([2 1]);
SData.dOrigin(1:2) = SData.dOrigin([2 1]);
SData.dOrientation = 'transversal'; % This is nifti's standard view
SData.Name = strtrim(SHeader.sDescription);
% -------------------------------------------------------------------------%



function SHeader = fReadNIIHeader(fid)

% -------------------------------------------------------------------------
% Read the relevant hearder data
SHeader.iHdrSize = fread(fid, 1, 'uint32');
if SHeader.iHdrSize > 2^10
    SHeader = [];
    return
end

fseek(fid, 39, 'bof');
SHeader.iDimInfo = fread(fid, 1, 'uint8');
SHeader.iNDims = fread(fid, 1, 'uint16');
if SHeader.iNDims > 7
    SHeader = [];
    return
end
SHeader.iDim = fread(fid, 7, 'uint16');
SHeader.iDim(SHeader.iDim == 0) = 1;

fseek(fid, 68, 'bof');
SHeader.iIntentCode = fread(fid, 1, 'uint16');
SHeader.iType = fread(fid, 1, 'uint16');
SHeader.iBitPix = fread(fid, 1, 'uint16');

fseek(fid, 74, 'bof');
SHeader.iStartSlice = fread(fid, 1, 'uint16');

fseek(fid, 80, 'bof');
SHeader.dAspect = fread(fid, 7, 'float');

SHeader.dOffset = fread(fid, 1, 'float');

SHeader.dSlope = fread(fid, 1, 'float');
SHeader.dIntercept = fread(fid, 1, 'float');
if SHeader.dSlope == 0, SHeader.dSlope = 1; end

SHeader.iEndSlice = fread(fid, 1, 'uint16');
SHeader.iSliceCode = fread(fid, 1, 'uint8');

SHeader.iXYZTUnits = fread(fid, 1, 'uint8');

SHeader.dCalMax = fread(fid, 1, 'float');
SHeader.dCalMin = fread(fid, 1, 'float');

fseek(fid, 136, 'bof');
SHeader.dTOffset = fread(fid, 1, 'float');

fseek(fid, 148, 'bof');
SHeader.sDescription = fread(fid, 80, 'uint8=>char')';

fseek(fid, 252, 'bof');
SHeader.iQFormCode = fread(fid, 1, 'uint16');
SHeader.iSFormCode = fread(fid, 1, 'uint16');
dQ = fread(fid, 3, 'float');
SHeader.dQuatern = [sqrt(1 - dQ(1).^2 - dQ(2).^2 - dQ(3).^2); dQ];
SHeader.dOffsetXYZ = fread(fid, 3, 'float');
SHeader.dS = reshape(fread(fid, 12, 'float'), [4, 3])';

if SHeader.iSFormCode > 0
%     SHeader.dOrigin = sign(diag(SHeader.dS)).*SHeader.dS(:,4);
    SHeader.dOrigin = SHeader.dS(:,4);
    dInc = diag(SHeader.dS);
    for iI = 1:size(SHeader.dS, 1)
        if dInc(iI) < 0
            SHeader.dOrigin(iI) = SHeader.dOrigin(iI) + dInc(iI).*(SHeader.iDim(iI) - 1);
        end
    end
else
    SHeader.dOrigin = zeros(3, 1);
end
% -------------------------------------------------------------------------

SHeader.sSpatialUnits = fNum2Unit(bitand(SHeader.iXYZTUnits, uint8(7)));
SHeader.sTimeUnits = fNum2Unit(bitand(SHeader.iXYZTUnits, uint8(7*8)));

% -------------------------------------------------------------------------
% Find start of volume data and read magic string
SHeader.iNumEl = prod(SHeader.iDim);
switch SHeader.iType
    case 1,                     dBytesPerVoxel = 1./8;
    case {2, 256},              dBytesPerVoxel = 1;
    case {4, 512},              dBytesPerVoxel = 2;
    case {128},                 dBytesPerVoxel = 3;
    case {8, 16, 768, 2304},    dBytesPerVoxel = 4;
    case {32, 64, 1024, 1280},  dBytesPerVoxel = 8;
    case {1536, 1792},          dBytesPerVoxel = 16;
    case {2048},                dBytesPerVoxel = 32;
    otherwise,                  error('Unknown datatype');
end
SHeader.dBytersPerVoxel = dBytesPerVoxel;

fseek(fid, SHeader.iHdrSize - 4, 'bof');
SHeader.sMagicString = fread(fid, 4, 'uint8=>char')';
fseek(fid, SHeader.dOffset, 'bof');
% -------------------------------------------------------------------------


function sUnit = fNum2Unit(sNum)

switch(sNum)
    case  0,    sUnit = 'px';
    case  1,    sUnit = 'm';
    case  2,    sUnit = 'mm';
    case  3,    sUnit = 'um';
    case  8,    sUnit = 's';
    case 16,    sUnit = 'ms';
    case 24,    sUnit = 'us';
    case 32,    sUnit = 'Hz';
    case 40,    sUnit = 'ppm';
    case 48,    sUnit = 'rad/s';
end