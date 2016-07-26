function csRegistrations = getRegistrations

persistent csRegs

if isempty(csRegs)
    sPath = [fileparts(mfilename('fullpath')), filesep, 'registration'];
    
    SDir = dir([sPath, filesep, 'register_*']);
    
    csRegs = cell(length(SDir), 1);
    
    for iI = 1:length(SDir)
        [~, sFilename] = fileparts(SDir(iI).name);
        csRegs{iI} = sFilename(10:end);
    end
end

csRegistrations = csRegs;