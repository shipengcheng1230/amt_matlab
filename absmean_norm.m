function [ data ] = absmean_norm( npts, data, halfwinlen )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

loop = 2;
trun_times = 10;
winlen = 2 * halfwinlen + 1;
rms_d = rms(data);

while loop    
    trun_bool = bsxfun(@gt, data, rms_d);
    trun_bool = ... 
        trun_bool + ...
        (trun_bool == 0) .* 1 + ...
        (trun_bool == 1) .* (1 / trun_times - 1);        
    data = bsxfun(@times, data, trun_bool);
    
    lbd = halfwinlen + 1;
    rbd = npts - halfwinlen;
    weight = ones(npts, 1);
    
    for ii = lbd: rbd
        weight(ii) = ... 
            sum(abs(data(ii - halfwinlen: ii + halfwinlen))) / winlen;
    end
  
    data = data ./ weight;
    rms_d_new = rms(data);
    
    loop = loop - (rms_d_new > rms_d);
    rms_d = rms_d_new;
end

end

