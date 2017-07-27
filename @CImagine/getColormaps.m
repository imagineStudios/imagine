function SColormaps = getColormaps(sPath, iLength)

persistent SMaps

% SMaps = [];
% -------------------------------------------------------------------------
% On first startup, determine the installed colormaps
if isempty(SMaps)
    
    SDir = dir([sPath, filesep(), '..', filesep(), '+iColormaps', filesep(), '*.m']);
    
    for iI = 1:length(SDir)
        [~, sName] = fileparts(SDir(iI).name);
        SMaps(iI).sName = sName;
        SMaps(iI).hFcn  = str2func(['iColormaps.', sName]);
        SMaps(iI).dMap  = SMaps(iI).hFcn(iLength, 1);
    end
end
% -------------------------------------------------------------------------

SColormaps = SMaps;
