function [ output_args ] = xcorr_comb( ...
    pairname, segment, freqset, xcorrdata_dir )
%XCORR_COMB Summary of this function goes here
%   Detailed explanation goes here

para_initial('spacxcorr');
global FILTER_ORDER
global BANDWIDTH
filorder = FILTER_ORDER;
bandwidth = BANDWIDTH;
para_initial('clear');

[num_pair, num_component] = size(pairname);
num_pair = num_pair / 2;
num_freq = numel(freqset);
specstr = 'N,F0,BW';
spac_coef = zeros(num_freq, num_pair, num_component);

for ii = 1: num_freq
    fspec = ...
        fdesign.peak(specstr, filorder, freq(ii), bandwidth);
    peakfilter = design(fspec, 'SystemObject', true);
    for kk = 1: num_component
        for jj = 1: num_pair
            for ll = 1: segment
                s1 = readsac(pairname{jj * 2 - 1, kk});
                s2 = readsac(pairname{jj * 2, kk});
                npts = min(s1.NPTS, s2.NPTS);
                freq = freqset / 2 / s1.DELTA;                
                
                d1 = filter(peakfilter, s1.DATA1);
                d2 = filter(peakfilter, s2.DATA1);
                spac_coef(kk, jj, ii) = ...
                    sum(d1(1: npts) .* d2(1: npts)) * ...
                    s1.DELTA / (s1.E - s1.B);
            end
        end
    end
end
end