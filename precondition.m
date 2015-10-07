%preconditions for raw ambient noise data
clear;
distcomp.feature( 'LocalUseMpiexec', false );

raw_dir = './seis_data/raw_data/';
prestack_dir = './seis_data/pre_stack/';
outpre = [prestack_dir, 'outpre.temp'];

sta_file = dir([raw_dir, '*.SAC']);
num_file = length(sta_file);
nsta = num_file;

seg_seconds = 86400;
freq_low = 0.01;
freq_high = 0.333;
filter_order = 4;

winlen = floor(0.5 / freq_low);
halfwinlen = floor((winlen - 1) / 2);

parfor ii = 1: num_file
    S = readsac([raw_dir, sta_file(ii).name]);
    [t, d] = getsacdata(S);
    
    if check_zero(S.NPTS, d) == 1
        nsta = nsta - 1;
        continue
    end
    
    [b, a] = butter(filter_order, [freq_low, freq_high] .* S.DELTA .* 2);
    d = filter(b, a, d);
    
    d = absmean_norm(S.NPTS, d, halfwinlen);
    
    d = spectral_norm(d);
    
    seg = floor(S.NPTS * S.DELTA / seg_seconds);
    S.NPTS = floor(seg_seconds / S.DELTA);
    S.E = seg_seconds;
    if ii == 1
        outpreID = fopen(outpre, 'w');
        fprintf(outpreID, '%d\n%d\n', nsta, seg);
    else
        outpreID = fopen(outpre, 'a');
    end
    
    for jj = 1: seg
        S.DATA1 = d((jj - 1) * S.NPTS + 1: jj * S.NPTS);
        name = ...
            [S.KNETWK, '_', S.KSTNM, '_', S.KCMPNM, '_', ...
            num2str(jj), '.SAC'];
        S.FILENAME = ...
            [prestack_dir, name];
        fprintf(outpreID, '%s\n', name);
        status = writesac(S);
    end
    fclose(outpreID);
end