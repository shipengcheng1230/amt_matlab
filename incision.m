function [ num_seg ] = incision( ...
    S, prestack_dir, discard_dir, stanet_name, stalist_name, equip )
%INCISION Summary of this function goes here
%   Detailed explanation goes here

if nargin == 5
    equip = 'centre';
elseif nargin < 5 || nargin > 6
    ME = MException(...
        'arguNum:MismatchRequired', ...
        'Need 4 necessary and one optional arguments.\n', ...
        'received %d!\n', nargin);
    throw(ME)
end

regexpr_num_dash = '[0-9-]*';

para_initial('incisise');
global SEG_SECOND
seg_second = SEG_SECOND;
para_initial('clear');

num_file = numel(S);

prestacknet_dir = fullfile(prestack_dir, stanet_name, filesep);
if exist(prestacknet_dir, 'dir') ~= 7
    mkdir(prestacknet_dir)
end


if strcmp(equip, 'centre') == 1
    prestacknet_dir = fullfile(prestacknet_dir, 'centre', filesep);
    if exist(prestacknet_dir, 'dir') ~= 7
        mkdir(prestacknet_dir)
    end
else
    nextname = regexp(equip, regexpr_num_dash, 'match');
    nextname = char(nextname{1, 1});
    prestacknet_dir = fullfile(prestacknet_dir, nextname, filesep);
    if exist(prestacknet_dir, 'dir') ~= 7
        mkdir(prestacknet_dir)
    end
end

oldfile = dir(prestacknet_dir);
num_oldfile = numel(oldfile) - 2;
if num_oldfile > 0
    trash_dir = fullfile(discard_dir, char(date), filesep);
    if exist(trash_dir, 'dir') ~= 7
        mkdir(trash_dir)
    end
    trash_dir = repmat({trash_dir}, 1, num_oldfile);
    oldname = repmat({prestacknet_dir}, 1, num_oldfile);
    oldfile = cellfun(@fullfile, ...
        oldname, {oldfile(3: end).name}, 'UniformOutput', false);
    cellfun(@movefile, oldfile, trash_dir);
end

stalistID = fopen(stalist_name, 'a');
if isinf(seg_second)
    writename = ...
        cellfun( ...
        @fullfile, ...
        repmat({prestacknet_dir}, 1, num_file), ...
        {S(:).FILENAME}, ...
        'UniformOutput', false);
    [S.FILENAME] = writename{:};
    for ii = 1: num_file
        fprintf(stalistID, '%s\n', S(ii).FILENAME);
        writesac(S(ii));
    end
    num_seg = 1;
else
    num_seg = min(floor(S(:).NPTS .* S(:).DELTA ./ seg_second));
    for ii = 1: num_file
        Snew = S(ii);
        Snew.DATA1 = [];
        Snew.NPTS = floor(seg_second / S(ii).DELTA);
        Snew.B = 0.0;
        Snew.E = seg_second;
        [~, name, ext] = fileparts(Snew.FILENAME);
        for jj = 1: num_seg
            Snew.DATA1 = ...
                S(ii).DATA1((jj - 1) * Snew.NPTS + 1: jj * Snew.NPTS);
            Snew.FILENAME = [name, '_', num2str(jj), '_', ext];
            Snew.FILENAME = fullfile(prestacknet_dir, Snew.FILENAME);
            fprintf(stalistID, '%s\n', Snew.FILENAME);
            writesac(Snew);
        end
    end
end
fclose(stalistID);
end