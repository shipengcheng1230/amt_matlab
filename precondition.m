%preconditions for raw ambient noise data

distcomp.feature( 'LocalUseMpiexec', false );

raw_dir = './seis_data/raw_data/';
sta_file = dir([raw_dir, '*.SAC']);
num_file = length(sta_file);

seg_seconds = 86400;
freq_low = 0.01;
freq_high = 0.333;
filter_order = 4;
xcorr_winlen = 1800;
xcorr_overlap = 0.75;

parfor ii = 1: num_file
    S = readsac([raw_dir, sta_file(ii).name]);
    [t, d] = getsacdata(S);
    
    if check_zero(S.NPTS, d) == 1
        continue
    end
    
    [b, a] = butter(filter_order, [freq_low, freq_high] .* S.DELTA .* 2);
    d = filter(b, a, d);
    
    winlen = floor(0.5 / freq_low);
    halfwinlen = floor((winlen - 1) / 2);
    
    d = absmean_norm(S.NPTS, d, halfwinlen);
    
    d = spectral_norm(d);
end