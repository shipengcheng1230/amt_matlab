function [ Snew ] = precond( data_dir, component )
%PRECOND Summary of this function goes here
%   Detailed explanation goes here

sta_file = dir([data_dir, '*.SAC']);
sta_file = {sta_file.name};
sta_file = strjoin(sta_file);
component = unique([lower(component), upper(component)]);
comexpr = ['[\w.]*_[', component, '][\w.]*'];
sta_file = regexp(sta_file, comexpr, 'match');
num_file = length(sta_file);
Snew = sacstruct(num_file);

para_initial('precond');
global FREQ_LOW
global FREQ_HIGH
global FILTER_ORDER
global TAPER_PERCENTILE
global HAMPEL_WIN

freq_low = FREQ_LOW;
freq_high = FREQ_HIGH;
filter_order = FILTER_ORDER;
taper_percentile = TAPER_PERCENTILE;
hampel_win = HAMPEL_WIN;
para_initial('clear');

for ii = 1: num_file
    dfname = fullfile(data_dir, sta_file(ii));
    S = readsac(dfname);
    
    if check_zero(S)
        continue
    end
    
    d = S.DATA1;
%     S.DATA1 = [];
%     d = hampel(detrend(d), floor(hampel_win / S.DELTA));
%     wintaper = tukeywin(S.NPTS, taper_percentile);
%     d = d .* wintaper;    
%     
%     if freq_high >= 0.5 / S.DELTA
%         ME = MException(...
%             'arguSetting:exceedingNyquist', ...
%             'Corner freq. %f greater than Nyquist %f!', ...
%             freq_high, 0.5 / S.DELTA);
%         throw(ME)
%     end
%     
%     [b, a] = butter(filter_order, [freq_low, freq_high] .* S.DELTA .* 2);
%     d = filter(b, a, d);
%     numNaN = numel(find(isnan(d)));
%     if  numNaN > 0
%         ME = MException(...
%             'filterError:NaN', ...
%             'Filtered data contain %d NaN!\n', numNaN);
%         throw(ME)
%     end
%     
%     try
%         d = absmean_norm(d, S.DELTA);
%     catch ME
%         if (strcmp(ME.identifier, 'arguSetting:exceedingNyquist'))
%             msg = 'RESET ''freq_high_absm''';
%             causeException = ...
%                 MException('arguSetting:exceedingNyquist', msg);
%             ME = addCause(ME, causeException);
%         end
%         rethrow(ME)
%     end
%     
%     d = spectral_norm(d, S.NPTS, S.DELTA);
%     d = d / max(abs(d));
    
    Snew(ii) = S;
    Snew(ii).DATA1 = d;
end
end