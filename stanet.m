function [ status ] = stanet( net_dir, prestack_dir, discard_dir )
%STANET Summary of this function goes here
%   Detailed explanation goes here
stanet= dir(net_dir);
regexpr_sac = '\w*(SAC)\w*';
regexpr_centre = '[\w-]*[0-9]+(m)';
regexpr_dist = '[0-9]+m';
precondtemp = 'precond.temp';

for ii = 3: length(stanet)
    if stanet(ii).isdir == 0
        continue
    end
    
    prestacknet_dir = fullfile(prestack_dir, stanet(ii).name, filesep);
    if exist(prestacknet_dir, 'dir') ~= 7
        mkdir(prestacknet_dir)
    end
    precondtemp_name = strcat(prestacknet_dir, precondtemp);
    
    equip_dir = fullfile(net_dir, stanet(ii).name, filesep);
    equip = dir(equip_dir);
    equip_name = {equip([equip.isdir]==1).name};
    equip_name = equip_name(3: end);
    
    comexpr_centre = [stanet(ii).name, regexpr_centre];
    equip_prepheral = regexp(equip_name, comexpr_centre, 'match');
    equip_prepheral = cell2mat ...
        (cellfun(@isempty, equip_prepheral, 'UniformOutput', false));
    equip_centre = equip_name(equip_prepheral == 1);
    equip_prepheral = equip_name(equip_prepheral == 0);
    
    data_centre_dir = fullfile(equip_dir, char(equip_centre), filesep);
    data_centre = dir(data_centre_dir);
    data_centre_dir_next = ...
        regexpi({data_centre(:).name}, regexpr_sac, 'match');
    data_centre_dir_next = data_centre_dir_next(cell2mat(cellfun(...
        @isempty, data_centre_dir_next, ...
        'UniformOutput', false)) == 0);
    data_centre_dir = fullfile( ...
        data_centre_dir, char(data_centre_dir_next{:}), filesep);
    
    num_prepheral = numel(equip_prepheral);
    radius = zeros(num_prepheral, 1);
    
    tempID = fopen(precondtemp_name, 'w');
    fprintf(tempID, '%s\n', data_centre_dir);
    
    for jj = 1: num_prepheral
        dist = regexp(equip_prepheral(jj), regexpr_dist, 'match');
        dist = char(dist{:});
        radius(jj) = str2double(dist(1: end - 1));
        equip_rad_dir = ...
            fullfile(equip_dir, char(equip_prepheral(jj)), filesep);
        equip_seq = dir(equip_rad_dir);
        equip_seq = {equip_seq([equip_seq.isdir] == 1).name};
        equip_seq = equip_seq(3: end);
        num_seq = numel(equip_seq);
        
        for kk = 1: num_seq
            equip_seq_dir = ...
                fullfile(equip_rad_dir, char(equip_seq(kk)), filesep);
            data_centre = dir(equip_seq_dir);
            equip_seq_dir_next = ...
                regexpi({data_centre(:).name}, regexpr_sac, 'match');
            equip_seq_dir_next = equip_seq_dir_next(cell2mat(cellfun(...
                @isempty, equip_seq_dir_next, ...
                'UniformOutput', false)) == 0);
            equip_seq_dir = fullfile( ...
                equip_seq_dir, char(equip_seq_dir_next{:}), filesep);
            fprintf(tempID, '%s\n', equip_seq_dir);
        end
    end       
    fclose(tempID);
end

end