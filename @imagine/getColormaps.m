function SColormaps = getColormaps(iLength)

persistent SMaps

% SMaps = [];
% -------------------------------------------------------------------------
% On first startup, determine the installed colormaps
if isempty(SMaps)
    
    SDir = dir([fileparts(mfilename('fullpath')), filesep, ...
        'private', filesep, 'cmap*.m']);
    
%     dImg = zeros(length(csColormaps), 32, 3);
    for iI = 1:length(SDir)
        [~, sName] = fileparts(SDir(iI).name);
        SMaps(iI).sName = sName(5:end);
        SMaps(iI).hFcn  = str2func(sName);
        SMaps(iI).dMap  = SMaps(iI).hFcn(iLength, 1);
    end
end
% -------------------------------------------------------------------------

SColormaps = SMaps;
