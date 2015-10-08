%preconditions for raw ambient noise data
clear;
distcomp.feature( 'LocalUseMpiexec', false );

raw_dir = './seis_data/raw_data/';
prestack_dir = './seis_data/pre_stack/';
discard_dir = './seis_data/discard_data/';
outpre = [prestack_dir, 'outpre.temp'];

sta_file = dir([raw_dir, '*.SAC']);
num_file = length(sta_file);
nsta = num_file;
segn = Inf;

seg_seconds = 86400;
freq_low = 0.01;
freq_high = 0.333;
filter_order = 4;
freq_low_absm = 0.0166;
freq_high_absm = 0.2000;

winlen = floor(0.5 / freq_low);
halfwinlen = floor((winlen - 1) / 2);

parfor ii = 1: num_file
    dfname = [raw_dir, sta_file(ii).name];
    S = readsac(dfname);
    [t, d] = getsacdata(S);
    if check_zero(S)
        nsta = nsta - 1;
        movefile(dfname, [discard_dir, S.FILENAME]);
        continue
    end
    
    if freq_high >= 0.5 / S.DELTA
        ME = MException(...
            'arguSetting:exceedingNyquist', ...
            'Corner freq. %f greater than Nyquist %f!', ...
            freq_high, 0.5 / S.DELTA);
        throw(ME)
    end
    
    [b, a] = butter(filter_order, [freq_low, freq_high] .* S.DELTA .* 2);
    d = filter(b, a, d);
    
    try
        d = absmean_norm(S.NPTS, d, halfwinlen, S.DELTA,...
            freq_low_absm, freq_high_absm, filter_order);
    catch ME
        if (strcmp(ME.identifier, 'arguSetting:exceedingNyquist'))
            msg = 'RESET ''freq_high_absm''';
            causeException = ...
                MException('arguSetting:exceedingNyquist', msg);
            ME = addCause(ME, causeException);
        end
        rethrow(ME)
    end
    
    d = spectral_norm(d);
    
    seg = floor(S.NPTS * S.DELTA / seg_seconds);
    segn = min(seg, segn);
    
    S.FILENAME = dfname;
    S.DATA1 = d;
    writesac(S);
end
close(hh)

sta_file = dir([raw_dir, '*.SAC']);
outpreID = fopen(outpre, 'w');
fprintf(outpreID, '%d\n%d\n', nsta, segn);
fclose(outpreID);

parfor ii = 1: nsta
    dfname = [raw_dir, sta_file(ii).name];
    S = readsac(dfname);
    Snew = S;
    Snew.NPTS = floor(seg_seconds / S.DELTA);
    Snew.E = seg_seconds;
    
    outpreID = fopen(outpre, 'a');
    for jj = 1: segn
        Snew.DATA1 = S.DATA1((jj - 1) * Snew.NPTS + 1: jj * Snew.NPTS);
        name = ...
            [S.KNETWK, '_', S.KSTNM, '_', S.KCMPNM, '_', ...
            num2str(jj), '.SAC'];
        Snew.FILENAME = ...
            [prestack_dir, name];
        fprintf(outpreID, '%s\n', name);
        status = writesac(Snew);
    end
    fclose(outpreID);
end