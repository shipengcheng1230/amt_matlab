function [ status ] = precond( data_dir, discard_dir, component )
%PRECOND Summary of this function goes here
%   Detailed explanation goes here

sta_file = dir([data_dir, '*.SAC']);
sta_file = {sta_file.name};
sta_file = strjoin(sta_file);
component = unique([lower(component), upper(component)]);
comexpr = ['[\w.]*_[', component, '][\w.]*'];
sta_file = regexp(sta_file, comexpr, 'match');
num_file = length(sta_file);
nsta = num_file;

para_initial(1);
global FREQ_LOW
global FREQ_HIGH
global FILTER_ORDER
global FREQ_LOW_ABSM
global FREQ_HIGH_ABSM
global WINLEN_ABSM
global SEG_SECONDS
global TAPER_PERCENTILE

freq_low = FREQ_LOW;
freq_high = FREQ_HIGH;
filter_order = FILTER_ORDER;
freq_low_absm = FREQ_LOW_ABSM;
freq_high_absm = FREQ_HIGH_ABSM;
winlen = WINLEN_ABSM;
seg_seconds = SEG_SECONDS;
taper_percentile = TAPER_PERCENTILE;
para_initial(0);

for ii = 1: num_file
    dfname = strcat(data_dir, sta_file(ii));
    S = readsac(dfname);
    d = S.DATA1;
    d = hampel(detrend(d), floor(0.001 * S.NPTS));
    wintaper = tukeywin(S.NPTS, taper_percentile);
    d = d .* wintaper;
    
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
    numNaN = numel(find(isnan(d)));
    if  numNaN > 0
        ME = MException(...
            'filterError:NaN', ...
            'Filtered data contain %d NaN!\n', numNaN);
        throw(ME)
    end
    
    try
        d = absmean_norm(d, S.NPTS, S.DELTA,...
            winlen, freq_low_absm, freq_high_absm, filter_order);
    catch ME
        if (strcmp(ME.identifier, 'arguSetting:exceedingNyquist'))
            msg = 'RESET ''freq_high_absm''';
            causeException = ...
                MException('arguSetting:exceedingNyquist', msg);
            ME = addCause(ME, causeException);
        end
        rethrow(ME)
    end
    
     d = spectral_norm(d, S.NPTS, S.DELTA);
    
    seg = floor(S.NPTS * S.DELTA / seg_seconds);
    
    S.FILENAME = ['a', char(dfname)];
    S.DATA1 = d;
    writesac(S);
end

status(1) = nsta;
status(2) = seg;
end