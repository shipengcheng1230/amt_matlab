function [ subfold, substr ] = foldfind( parenfold, regexpr, opt )
%FOLDFIND Summary of this function goes here
%   Detailed explanation goes here
if nargin < 2
    ME = MException(...
        'arguNum:LessThanRequired', ...
        'Need at least 2 arguments, received %d!\n!', nargin);
    throw(ME)
end

if ~exist(opt, 'var')
    opt = 0;
end

opt = (strcmp(opt, 'match')) * 0 + (strcmp(opt, 'unmatch')) * 1;

try
    content = dir(parenfold);
catch err
    disp(err);
    disp('Please convert cell to string array!')
end

foldname = {content([content.isdir] == 1).name};
foldname = foldname(3: end);

targfold = regexp(foldname, regexpr, 'match');
targfold = cell2mat(cellfun(@isempty, targfold, 'UniformOutput', false));

substr = foldname(targfold == opt);
subfold = fullfile(parenfold, substr, filesep);
end