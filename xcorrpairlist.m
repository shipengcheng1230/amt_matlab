function [ flag ] = xcorrpairlist( stalist, staseg, component )
%XCORRPAIRLIST Summary of this function goes here
%   Detailed explanation goes here

pairlist_name = 'pair';

num_stalist = numel(stalist);

pairlist = cellfun(...
    @strcat, ...
    repmat({pairlist_name}, 1, num_stalist), ...
    repmat({'_'}, 1, num_stalist), ...
    num2cell(component), ...
    'UniformOutput', false);
[pathstr, ~, ~] = cellfun(@fileparts, stalist, 'UniformOutput', false);
pairlist = cellfun(@fullfile, pathstr, pairlist, 'UniformOutput', false);

stalistID = cellfun(@fopen, stalist, repmat({'r'}, 1, num_stalist));
stasegID = fopen(staseg, 'r');

seginfo = fscanf(stasegID, '%d');
stalistinfo = ...
    cellfun(...
    @textscan, num2cell(stalistID), repmat({'%s'}, 1, num_stalist), ...
    'UniformOutput', false);

arrayfun(@fclose, stalistID);
fclose(stasegID);

stalistinfo = vertcat(stalistinfo{:});
stalistinfo = horzcat(stalistinfo{:});

[total_file, ~] = size(stalistinfo);
minseg = min(seginfo(1: end - 1));
pair = cell(minseg * seginfo(end), num_stalist);
sel_bool = zeros(total_file, 1);
sel_bool(1: minseg) = 1;

for ii = 2: seginfo(end)
    bd = sum(seginfo(1: ii - 1));
    sel_bool(bd + 1: bd + minseg) = 1;
end

pair(:, :) = stalistinfo(sel_bool == 1, :);

num_pair = nchoosek(seginfo(end), 2);
pairlistID = cellfun(@fopen, pairlist, repmat({'w'}, 1, num_stalist));

for ii = 1: num_stalist
    pairname = nchoosek(pair(1: minseg: end, ii), 2);
    cellfun(...
        @fprintf, ...
        num2cell(ones(num_pair, 1) * pairlistID(ii)), ...
        repmat({'%s %s\n'}, num_pair, 1), ...
        pairname(:, 1), pairname(:, 2));
end

arrayfun(@fclose, pairlistID);
flag = 0;
end