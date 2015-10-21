function [ status ] = stanet( ...
    net_dir, singledata_dir, discard_dir, component )
%STANET Summary of this function goes here
%   Detailed explanation goes here
stanet= dir(net_dir);
regexpr_sac = '\w*(SAC)\w*';
regexpr_peripheral = '[\w-]*[0-9]+(m)';
regexpr_dist = '[0-9]+m';
regexpr_with_dash = '[\w-]*';
sta_seg_name = 'staseg';
stalist_name = 'stalist';

component = sort(lower(component));
num_stanet = length(stanet);
num_component = numel(component);

for ii = 3: num_stanet
    if ~stanet(ii).isdir
        continue
    end
    
    prestacknet_dir = fullfile(singledata_dir, stanet(ii).name, filesep);
    if exist(prestacknet_dir, 'dir') ~= 7
        mkdir(prestacknet_dir);
    end
    
    stafile = cellfun(...
        @strcat, ...
        repmat({stalist_name}, 1, num_component), ...
        repmat({'_'}, 1, num_component), ...
        num2cell(component), ...
        'UniformOutput', false);
    stafile = fullfile(singledata_dir, stanet(ii).name, stafile);
    stalistID = cellfun(@fopen, stafile, repmat({'w'}, 1, num_component));
    arrayfun(@fclose, stalistID);
    
    equip_dir = fullfile(net_dir, stanet(ii).name, filesep);
    comexpr_prepheral = [stanet(ii).name, regexpr_peripheral];
    
    [equip_centre_dir, ~] = ...
        foldfind(equip_dir, comexpr_prepheral, 'unmatch');
    [equip_centre_dir, ~] = ...
        foldfind(char(equip_centre_dir), regexpr_sac, 'match', false);
    
    S_centre = precond(char(equip_centre_dir), component);
    numseg = incision( ...
        S_centre, singledata_dir, discard_dir, stanet(ii).name, ...
        stafile, 'centre');
    
    staseg = strcat(prestacknet_dir, sta_seg_name);
    stasegID = fopen(staseg, 'w');
    fprintf(stasegID, '%d\n', numseg);
    
    [equip_peripheral_dir, equip_peripheral] = ...
        foldfind(equip_dir, comexpr_prepheral, 'match');
    
    num_peripheral = numel(equip_peripheral);
    radius = zeros(num_peripheral, 1);
    num_sta = 1;
    
    for jj = 1: num_peripheral
        dist = regexp(equip_peripheral(jj), regexpr_dist, 'match');
        dist = char(dist{:});
        radius(jj) = str2double(dist(1: end - 1));
        
        [equip_seq_dir, equip_seq] = ...
            foldfind(equip_peripheral_dir{jj}, regexpr_with_dash, 'match');
        
        num_seq = numel(equip_seq_dir);
        num_sta = num_sta + num_seq;
        
        for kk = 1: num_seq
            [sac_fold, ~] = ...
                foldfind(equip_seq_dir{kk}, regexpr_sac, 'match', false);
            S_peripheral = ...
                precond(char(sac_fold), component);
            numseg = incision( ...
                S_peripheral, singledata_dir, discard_dir, ...
                stanet(ii).name, stafile, equip_seq(kk));
            fprintf(stasegID, '%d\n', numseg);
        end
    end
    fprintf(stasegID, '%d\n', num_sta);
    fclose(stasegID);
end

xcorrpairlist(stafile, staseg, component);
status = 0;
end