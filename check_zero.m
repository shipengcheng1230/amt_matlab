function [ flag ] = check_zero( npts, data )
%CHECK_ZERO Summary of this function goes here
%   Detailed explanation goes here

evl = 1e-9;
eper = 0.15;

rej_bool = bsxfun(@lt, abs(data), evl);
num_zero = sum(rej_bool);

flag = (num_zero > (npts * eper));

end

