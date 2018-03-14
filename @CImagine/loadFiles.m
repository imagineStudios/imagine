function loadFiles(obj)


% -------------------------------------------------------------------------
% Show an open file dialog, if right-click, open a folder
if strcmp(get(obj.hF, 'SelectionType'), 'normal')
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Open one or multiple files
    [csFilenames, sPath] = uigetfile( ...
        {'*.*', 'All Files'; ...
        '*.dcm; *.DCM; *.mat; *.MAT; *.jpg; *.jpeg; *.JPG; *.JPEG; *.tif; *.tiff; *.TIF; *.TIFF; *.gif; *.GIF; *.bmp; *.BMP; *.png; *.PNG; *.nii; *.NII; *.hdr; *.HDR; *.gipl; *.GIPL', 'All images'; ...
        '*.mat; *.MAT', 'Matlab File (*.mat)'; ...
        '*.jpg; *.jpeg; *.JPG; *.JPEG', 'JPEG-Image (*.jpg)'; ...
        '*.tif; *.tiff; *.TIF; *.TIFF;', 'TIFF-Image (*.tif)'; ...
        '*.gif; *.GIF', 'Gif-Image (*.gif)'; ...
        '*.bmp; *.BMP', 'Bitmaps (*.bmp)'; ...
        '*.png; *.PNG', 'Portable Network Graphics (*.png)'; ...
        '*.dcm; *.DCM', 'DICOM Files (*.dcm)'; ...
        '*.nii; *.NII', 'NifTy Files (*.nii)'; ...
        '*.hdr; *.HDR', 'ANALYZE Files (*.hdr)'; ...
        '*.gipl; *.GIPL', 'Guys Image Processing Lab Files (*.gipl)'}, ...
        'OpenLocation'  , obj.sPath, ...
        'Multiselect'   , 'on');
    
    if isnumeric(sPath), return, end; % Dialog aborted
    
else
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Open a folder
    sPath = uigetdir(obj.sPath);
    
    if isnumeric(sPath), return, end; % Dialog aborted
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Get all files in that folder (excluding sub-folders)
    sPath = [sPath, filesep];
    SFiles = dir(sPath);
    SFiles = SFiles(~[SFiles.isdir]);
    
    csFilenames = cell(length(SFiles), 1);
    for iI = 1:length(SFiles)
        csFilenames{iI} = SFiles(iI).name;
    end
    
end

obj.sPath = sPath;

if ~iscell(csFilenames), csFilenames = {csFilenames}; end % If only one file

csFilenames = fFilterAnalyze(csFilenames);

lLoaded = false(length(csFilenames), 1);


% -------------------------------------------------------------------------
% Go through all the files and load corresponding data
for i = 1:length(csFilenames)
    [~, sName, sExt] = fileparts(csFilenames{i}); %#ok<ASGLU>
    switch lower(sExt)
        
        % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        % Standard image data: Try to group according to size
        case {'.jpg', '.jpeg', '.tif', '.tiff', '.gif', '.bmp', '.png'}
            try
                dImg = double(imread([SState.sPath, csFilenames{i}]))./255;
                lLoaded(i) = true;
            catch %#ok<CTCH>
                disp(['Error when loading "', SState.sPath, csFilenames{i}, '": File extenstion and type do not match']);
                continue;
            end
            dImg = mean(dImg, 3);
            iInd = fServesSizeCriterion(size(dImg), SImageData);
            if iInd
                dImg = cat(3, SImageData(iInd).dImg, dImg);
                SImageData(iInd).dImg = dImg;
            else
                iLength = length(SImageData) + 1;
                SImageData(iLength).dImg = dImg;
                SImageData(iLength).sOrigin = 'Image File';
                SImageData(iLength).sName = csFilenames{i};
                SImageData(iLength).dPixelSpacing = [1 1 1];
            end
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % NifTi
        case '.nii'
            SData = fNifTiRead([sPath, csFilenames{i}]);
            if ndims(SData.dImg) > 4, error('Maximum of 4 dimensions supported'); end

            lLoaded(i) = true;
            obj.plus(SData);
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            
        case 'hdr'
            
            if isnitf(csFilenames{i})
                
            else
                
            end
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % GIPL
        case '.gipl'
            set(hF, 'Pointer', 'watch'); drawnow;
            [dImg, dDim] = fGIPLRead([SState.sPath, csFilenames{i}]);
            lLoaded(i) = true;
            fAddImageToData(dImg, csFilenames{i}, 'GIPL File', dDim, 'mm');
            set(hF, 'Pointer', 'arrow');
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
            % MATLAB file
        case '.mat'
            csVars = fMatRead([SState.sPath, csFilenames{i}]);
            lLoaded(i) = true;
            if isempty(csVars), continue, end   % Dialog aborted
            
            set(hF, 'Pointer', 'watch'); drawnow;
            for iJ = 1:length(csVars)
                S = load([SState.sPath, csFilenames{i}], csVars{iJ});
                eval(['dImg = S.', csVars{iJ}, ';']);
                fAddImageToData(dImg, sprintf('%s in %s', csVars{iJ}, csFilenames{i}), 'MAT File');
            end
            set(hF, 'Pointer', 'arrow');
            % - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    end
end

obj.position;
obj.draw





function csFilenames = fFilterAnalyze(csFilenames)
% Special treatment for this stupid file format which thinks it needs two
% files to store one thing! Sort out the img file if both files are opened.
% If only the img file is opened, replace with the corresponding hdr file.

iNameHash = zeros(size(csFilenames));
iExtHash = zeros(size(csFilenames));

% Hash the file extensions and names to make things more easy
for iI = 1:length(csFilenames)
    [~, sName, sExt] = fileparts(csFilenames{iI});
    iNameHash(iI) = iGlobals.fHash(sName);
    iExtHash(iI) = iGlobals.fHash(sExt);
end

% These are supposed to be analyze files
iHDRHash = iGlobals.fHash('.hdr');
iIMGHash = iGlobals.fHash('.img');
lAnalyze = iExtHash == iHDRHash | iExtHash == iIMGHash;

% These files will be kept
lKeep = true(size(csFilenames));

% First: Rule out that both header and image file of the same dataset are
% in the file list
for iI = 1:length(iNameHash)
    lThisHash = iNameHash(iI) == iNameHash;
    if nnz(lThisHash & lAnalyze & lKeep) == 2
        % Two files with the same name and analyze extension -> keep the
        % first (should be the hdr if alaphabetic ordering)
        lKeep(find((lThisHash & lAnalyze & lKeep), 1, 'last')) = false;
    end
end

% Second: Make sure, the .hdr file and not the .img file is in there
for iI = find(lAnalyze & lKeep & iExtHash == iIMGHash)
    [~, sName] = fileparts(csFilenames{iI});
    csFilenames{iI} = [sName, '.hdr'];
end

csFilenames = csFilenames(lKeep);