function dDist = strdist(sStr1, xStr2, lCaseSensitive)

%d=strdist(r,b,krk,cas) computes Levenshtein and editor distance 
%between strings r and b with use of Vagner-Fisher algorithm.
%   Levenshtein distance is the minimal quantity of character
%substitutions, deletions and insertions for transformation
%of string r into string b. An editor distance is computed as 
%Levenshtein distance with substitutions weight of 2.
%d=strdist(r) computes numel(r);
%d=strdist(r,b) computes Levenshtein distance between r and b.
%If b is empty string then d=numel(r);
%d=strdist(r,b,krk)computes both Levenshtein and an editor distance
%when krk=2. d=strdist(r,b,krk,cas) computes a distance accordingly 
%with krk and cas. If cas>0 then case is ignored.
%
%Example.
% disp(strdist('matlab'))
%    6
% disp(strdist('matlab','Mathworks'))
%    7
% disp(strdist('matlab','Mathworks',2))
%    7    11
% disp(strdist('matlab','Mathworks',2,1))
%    6     9

if nargin < 3, lCaseSensitive = false; end
if nargin < 2
    dDist = numel(sStr1);
    return
end

if ischar(xStr2)
    xStr2 = {xStr2};
end

if ~lCaseSensitive
    sStr1 = lower(sStr1);
end

lima = numel(sStr1);

dDist = zeros(size(xStr2));
for iK = 1:length(xStr2)
    
    sStr2 = xStr2{iK};
    
    if ~lCaseSensitive
        sStr2 = lower(sStr2);
    end

    luma = numel(sStr2);
    
    lu1  = luma + 1;
    
    dl = zeros([lu1, lima + 1]);
    dl(1,:) = 0:lima;
    dl(:,1) = 0:luma;
    
    %Distance
    for iI = 2:lu1
        bbi = sStr2(iI-1);
        for iJ = 2:(lima + 1)
            kr = 1;
            if strcmp(sStr1(iJ-1), bbi)
                kr = 0;
            end
            dl(iI, iJ) = min([dl(iI-1, iJ-1) + kr, dl(iI-1, iJ)+1, dl(iI, iJ-1) + 1]);
        end
    end
    dDist(iK) = dl(end, end);
end

