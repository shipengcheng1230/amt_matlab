function [ subfold, substr ] = foldfind( parenfold, regexpr, opt, casesen )
%FOLDFIND Summary of this function goes here
%   Detailed explanation goes here
if nargin < 2
    ME = MException(...
        'arguNum:LessThanRequired', ...
        'Need at least 2 arguments, received %d!\n', nargin);
    throw(ME)
end

if nargin >4
    ME = MException(...
        'arguNum:MoreThanRequired', ...
        'Need at most 4 arguments, received %d!\n', nargin);
    throw(ME)
end

if nargin == 2
    opt = 0;
    casesen = true;
elseif nargin == 3;
    casesen = true;
end

opt = (strcmp(opt, 'match')) * 0 + (strcmp(opt, 'unmatch')) * 1;

if casesen == true
    fun_regexp = @regexp;
elseif casesen == false
    fun_regexp = @regexpi;
else
    ME = MException(...
        'arguInput:WrongType', ...
        'Input #4 has a wrong type, received %s!\n', ...
        'Must be ''true'' or ''false''', casesen);
    throw(ME)
end

try
    content = dir(parenfold);
catch err
    disp(err);
    ME = MException(...
        'arguInput:WrongType', ...
        'Input #1 %s has wrong type!\n', ...
        'Please convert from cell to string!\n', cell2mat(parenfold));
    throw(ME)
end

foldname = {content([content.isdir] == 1).name};
foldname = foldname(3: end);

targfold = fun_regexp(foldname, regexpr, 'match');
targfold = cell2mat(cellfun(@isempty, targfold, 'UniformOutput', false));

substr = foldname(targfold == opt);
subfold = fullfile(parenfold, substr, filesep);
end