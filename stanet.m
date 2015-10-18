function [ status ] = stanet( ...
    net_dir, prestack_dir, discard_dir, component )
%STANET Summary of this function goes here
%   Detailed explanation goes here
stanet= dir(net_dir);
regexpr_sac = '\w*(SAC)\w*';
regexpr_peripheral = '[\w-]*[0-9]+(m)';
regexpr_dist = '[0-9]+m';
regexpr_with_dash = '[\w-]*';
precondtemp_name = 'precond.temp';
stalist_name = 'stalist';

num_stanet = length(stanet);
for ii = 3: num_stanet
    if stanet(ii).isdir == 0
        continue
    end
    
    prestacknet_dir = fullfile(prestack_dir, stanet(ii).name, filesep);
    if exist(prestacknet_dir, 'dir') ~= 7
        mkdir(prestacknet_dir);
    end
    
    stalist = fullfile(prestack_dir, stanet(ii).name, stalist_name);
    stalistID = fopen(stalist, 'w');
    fclose(stalistID);
    
    equip_dir = fullfile(net_dir, stanet(ii).name, filesep);
    comexpr_prepheral = [stanet(ii).name, regexpr_peripheral];
    
    [equip_centre_dir, ~] = ...
        foldfind(equip_dir, comexpr_prepheral, 'unmatch');
    [equip_centre_dir, ~] = ...
        foldfind(char(equip_centre_dir), regexpr_sac, 'match', false);
    
    S_centre = precond(char(equip_centre_dir), discard_dir, component);
    numseg = incision( ...
        S_centre, prestack_dir, discard_dir, stanet(ii).name, ...
        stalist, 'centre');
    
    precondtemp = strcat(prestacknet_dir, precondtemp_name);
    tempID = fopen(precondtemp, 'w');
    fprintf(tempID, '%d\n', numseg);
    
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
                precond(char(sac_fold), discard_dir, component);
            incision( ...
                S_peripheral, prestack_dir, discard_dir, ...
                stanet(ii).name, stalist, equip_seq(kk));
        end
    end
    fprintf(tempID, '%d\n', num_sta);
    fclose(tempID);
end
status = 0;
end