function [ data ] = spectral_norm( data )
%SPECTRAL_NORM Summary of this function goes here
%   Detailed explanation goes here

lpc_order = 8;

cof_lpc = lpc(data, lpc_order);
data = filter(cof_lpc, 1, data);

end

