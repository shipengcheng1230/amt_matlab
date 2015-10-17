function [ subfold, substr ] = foldfind( parenfold, regexpr, opt )
%FOLDFIND Summary of this function goes here
%   Detailed explanation goes here
opt = (strcmp(opt, 'match')) * 0 + (strcmp(opt, 'unmatch')) * 1;
content = dir(parenfold);
foldname = {content([content.isdir] == 1).name};
foldname = foldname(3: end);

targfold = regexp(foldname, regexpr, 'match');
targfold = cell2mat(cellfun(@isempty, targfold, 'UniformOutput', false));

substr = foldname(targfold == opt);
subfold = fullfile(parenfold, substr, filesep);
end