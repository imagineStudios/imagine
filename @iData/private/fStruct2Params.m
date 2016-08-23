function [dImg, cAdditionalInputs] = fStruct2Params(SImg)

dImg = [];
cAdditionalInputs = {};

if ~isscalar(SImg)
    error('So far only scalar struct inputs supported - sorry!');
end

% -------------------------------------------------------------------------
% Define a mapping structure for fields
% SMapping = struct('Source', 'Target', 'Tolerance');

SMapping(1).Source = {'aspect', 'res', 'resolution'};
SMapping(1).Target = 'resolution';
SMapping(1).Tolerance = 2;

SMapping(2).Source = {'org', 'origin'};
SMapping(2).Target = 'origin';
SMapping(2).Tolerance = 2;

SMapping(3).Source = {'units'};
SMapping(3).Target = 'units';
SMapping(3).Tolerance = 2;
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Parse all fields of the struct
csFields = fieldnames(SImg);
for iI = 1:length(csFields)
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Check for image data
    if any(strdist(csFields{iI}, {'img', 'image', 'data'}, false) < 2)
        dImg = SImg.(csFields{iI});
        continue
    end
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Check for properties defined in the mappign structure
    for iJ = 1:length(SMapping)
        if any(strdist(csFields{iI}, SMapping(iJ).Source, false) < SMapping(iJ).Tolerance)
            xVal = SImg.(csFields{iI});
            cAdditionalInputs = [cAdditionalInputs, SMapping(iJ).Target, xVal];
            break
        end
    end
    
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Throw error if no image data could be identified
if isempty(dImg)
    error('Could not identify any image data in struct input!');
end