%correlation and stacking for ambient noise data after preconditioning
clear;
distcomp.feature( 'LocalUseMpiexec', false );

prestack_dir = './seis_data/pre_stack/';
poststack_dir = './seis_data/post_stack/';
outpre = [prestack_dir, 'outpre.temp'];

outpreID = fopen(outpre, 'r');
stacksize = fscanf(outpreID, '%d\n');
num_sta = stacksize(1);
num_seg = stacksize(2);
stackname = textscan(outpreID, '%s\n');
stackname = stackname{1, 1};
fclose(outpreID);

xcorr_winlen = repmat({1800}, num_seg, 1);
xcorr_overlap = repmat({0.75}, num_seg, 1);
xcorr_wintype = repmat({'hann'}, num_seg, 1);

addpre = @(name) [prestack_dir, name];
stackname = cellfun(addpre, stackname, 'UniformOutput', false);
stackname = reshape(stackname, num_seg, num_sta);

for ii = 1: num_sta - 1
    name1 = stackname(:, ii);
    S1 = cellfun(@readsac, name1, 'UniformOutput', false);
    for jj = ii + 1: num_sta   
        name2 = stackname(:, jj);        
        S2 = cellfun(@readsac, name2, 'UniformOutput', false);
        corrdate = cellfun(@xcorr_welch, ...
            S1, S2, xcorr_winlen, xcorr_overlap, xcorr_wintype, ...
            'UniformOutput', false);
        corrdate = cell2mat(corrdate);
        corrdate = reshape(...
            corrdate, floor(numel(corrdate)/num_seg), num_seg);
        corrdate = sum(corrdate, 2);
        
        snew = S1{1, 1};
        filename = ...
            [S1{1, 1}.KNETWK, '_', S1{1, 1}.KSTNM, '--', ...
            S2{1, 1}.KNETWK, '_', S2{1, 1}.KSTNM, '.SAC'];
        snew.DATA1 = corrdate;
        snew.NPTS = length(corrdate);
        snew.FILENAME = [poststack_dir, filename];
        snew.DELTA = S1{1, 1}.DELTA;
        snew.B = 0;
        snew.E = snew.NPTS * snew.DELTA;
        snew.NVHDR = S1{1, 1}.NVHDR;
        snew.USER0 = distance(...
            S1{1, 1}.STLA, S1{1, 1}.STLO, ...
            S2{1, 1}.STLA, S2{1, 1}.STLO) / 180 * pi * earthRadius('km');
        writesac(snew);
    end
end