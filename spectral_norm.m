function [ d_whiten ] = spectral_norm( data, npts, delta )
%SPECTRAL_NORM Summary of this function goes here
%   Detailed explanation goes here

para_initial(2);
global FREQ_LOW_ABSM
global FREQ_HIGH_ABSM
global TAPER_PERCENTILE

freq_low = FREQ_LOW_ABSM;
freq_high = FREQ_HIGH_ABSM;
taper_percentile = TAPER_PERCENTILE;
para_initial(0);

npow2 = 2^nextpow2(npts);
n_centre = npow2 / 2;

Y = fft(data, npow2);

k_lb = round(freq_low * npow2 * delta); 
k_rb = round(freq_high * npow2 * delta);

num_k = k_rb - k_lb + 1;
num_taper = round(num_k * taper_percentile);
k_lb = k_lb - num_taper;
k_rb = k_rb + num_taper;
if k_lb < 2
    k_lb = 2;
end
if k_rb > n_centre
    k_rb = n_centre;
end
num_k = k_rb - k_lb + 1;

k2_lb = npow2 - (k_lb - 2);
k2_rb = npow2 - (k_rb - 2);

P = abs(Y);
Y = Y / max(P);
P = abs(Y);

sect_data = P(k_lb: k_rb) .* tukeywin(num_k, taper_percentile);
envo_data = envelope(sect_data, round(num_k / 10), 'peak');
Y(k_lb: k_rb) = Y(k_lb: k_rb) ./ envo_data;
Y(k2_rb: k2_lb) = Y(k2_rb: k2_lb) ./ flip(envo_data);

d_whiten = ifft(Y);
d_whiten = d_whiten(1: npts);
end