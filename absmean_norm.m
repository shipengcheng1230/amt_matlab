function [ data ] = absmean_norm( data, delta )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

para_initial(2);
global FREQ_LOW_ABSM
global FREQ_HIGH_ABSM
global FILTER_ORDER
global WATER_LEVEL
global WINLEN_ABSM
global HAMPEL_WIN
global MAX_ITER

freqlow = FREQ_LOW_ABSM;
freqhigh = FREQ_HIGH_ABSM;
filter_order = FILTER_ORDER;
water_level = WATER_LEVEL;
winlen = WINLEN_ABSM;
hampel_win = HAMPEL_WIN;
max_iter = MAX_ITER;
para_initial(0);

hampel_npts = floor(hampel_win / delta);

if freqhigh >= 0.5 / delta
    ME = MException(...
        'arguSetting:exceedingNyquist', ...
        'Corner freq. %f greater than Nyquist %f!', ...
        freqhigh, 0.5 / delta);
    throw(ME)
end

[b, a] = butter(filter_order, [freqlow, freqhigh] .* delta .* 2);

while max_iter
    data = data / max(abs(data));
    dtemp = filter(b, a, data);
    weight = smooth(abs(dtemp), winlen);
    data = data ./ weight;
    data(isnan(data)) = 0;
    data = hampel(data, hampel_npts);
    
    trun_bool = abs(data) > (water_level * rms(data));
    num_above = sum(trun_bool);
    trun_bool = trun_bool + ...
        (trun_bool == 0) .* 1 + ...
        (trun_bool == 1) .* (1 / water_level - 1);
    data = data .* trun_bool;

    if num_above == 0
        break
    else
        max_iter = max_iter - 1;
    end
end
end