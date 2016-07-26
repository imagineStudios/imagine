function csColormaps = getColormaps

persistent csMaps

% -------------------------------------------------------------------------
% On first startup, determine the installed colormaps
if isempty(csMaps)
    SDir = dir([fileparts(mfilename('fullpath')), filesep, 'private', filesep, 'cmap_*.m']);
    iNColormaps = length(SDir);
    csMaps = cell(iNColormaps, 1);
    for iI = 1:iNColormaps
        [~, sName] = fileparts(SDir(iI).name);
        csMaps{iI} = sName(6:end);
    end
end
% -------------------------------------------------------------------------

csColormaps = csMaps;
