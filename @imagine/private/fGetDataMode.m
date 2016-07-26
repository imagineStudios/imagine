function sMode = fGetDataMode(xVar, sName)

sMode = 'scalar';

if isstruct(xVar)

    csFields = fieldnames(xVar);
    for iI = 1:length(csFields)
        sName = lower(csFields{iI});    
        if strdist(sName, 'img') < 2 || strdist(sName, 'image') < 2 || strdist(sName, 'data') < 2
            if isnumeric(xVar.(csFields{iI})) || islogical(xVar.(csFields{iI}))
                % OK, it's data so check the mode
                
                iSize = size(xVar.(csFields{iI}));
                if iSize(3) == 3 % RGB of vector
                    sString = sprintf('Is %s RGB of vector data?', sName);
                    sMode = questdlg(sString, 'Imagine', 'RGB', 'Vector', 'RGB');
                else
                    if isinteger(xVar.(csFields{iI}))
                        sString = sprintf('Is %s categoriacl data?', sName);
                        sMode = questdlg(sString, 'Imagine', 'Yes', 'No', 'No');
                    end
                end
                
                continue
            end
        end
    end
    
else
    iSize = size(xVar);
    if iSize(3) == 3 % RGB of vector
        sString = sprintf('Is %s RGB of vector data?', sName);
        sMode = questdlg(sString, 'Imagine', 'RGB', 'Vector', 'RGB');
    else
        if isinteger(xVar)
            sString = sprintf('Is %s categorical data?', sName);
            sMode = questdlg(sString, 'Imagine', 'Yes', 'No', 'No');
        end
    end
end

if strcmp(sMode, 'Yes'), sMode = 'categorical'; end
if strcmp(sMode, 'No'),  sMode = 'scalar'; end
sMode = lower(sMode);