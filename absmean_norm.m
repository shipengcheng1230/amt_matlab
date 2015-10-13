function [ data ] = absmean_norm( data, npts, delta, ...
     winlen, freqlow, freqhigh, filter_order )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

iter = 5;
water_level = 6;

if freqhigh >= 0.5 / delta
    ME = MException(...
        'arguSetting:exceedingNyquist', ...
        'Corner freq. %f greater than Nyquist %f!', ...
        freqhigh, 0.5 / delta);
    throw(ME)
end

[b, a] = butter(filter_order, [freqlow, freqhigh] .* delta .* 2);

while iter
    dtemp = filter(b, a, data);
    weight = smooth(abs(dtemp), winlen);
    data = data ./ weight;
    data(isnan(data)) = 0;
    
    trun_bool = abs(data) > (water_level * rms(data));
    trun_times = max(abs(data));
    trun_bool = trun_bool + ...
        (trun_bool == 0) .* 1 + ...
        (trun_bool == 1) .* (1 / trun_times - 1);
    data = data .* trun_bool;
    
    if sum(abs(data) > (water_level * rms(data))) < 0.001 * npts
        break
    else
        iter = iter - 1;
    end
end

end