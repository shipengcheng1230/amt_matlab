function [ flag ] = incision( S, prestack_dir, stanet_name, radius )
%INCISION Summary of this function goes here
%   Detailed explanation goes here

para_initial(4)
global SEG_SECOND

num_seg = SEG_SECOND;
para_initial(0)

num_file = numel(S);

prestacknet_dir = fullfile(prestack_dir, stanet_name, filesep);
if exist(prestacknet_dir, 'dir') ~= 7
    mkdir(prestacknet_dir)
end


if isinf(num_seg)
    for ii = 1: num_file
        

end

