function [ data ] = absmean_norm( npts, data, halfwinlen, ...
    delta, freqlow, freqhigh, filter_order )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

loop = 3;
trun_times = 10;
winlen = 2 * halfwinlen + 1;
rms_d = rms(data);

if freqhigh >= 0.5 / delta
    ME = MException(...
        'arguSetting:exceedingNyquist', ...
        'Corner freq. %f greater than Nyquist %f!', ...
        freqhigh, 0.5 / delta);
    throw(ME)
end

[b, a] = butter(filter_order, [freqlow, freqhigh] .* delta .* 2);

while loop
    trun_bool = bsxfun(@gt, data, 1.5 * rms_d);
    trun_bool = ...
        trun_bool + ...
        (trun_bool == 0) .* 1 + ...
        (trun_bool == 1) .* (1 / trun_times - 1);
    data = bsxfun(@times, data, trun_bool);
    
    lbd = halfwinlen + 1;
    rbd = npts - halfwinlen;
    weight = ones(npts, 1);
    
    dtemp = filter(b, a, data);
    
    for ii = lbd: rbd
        weight(ii) = ...
            sum(abs(dtemp(ii - halfwinlen: ii + halfwinlen))) / winlen;
    end
    
    data = data ./ weight;
    rms_d_new = rms(data);
    
    loop = loop - (rms_d_new > rms_d);
    rms_d = rms_d_new;
end

end