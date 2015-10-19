function [ flag ] = check_zero( S )
%CHECK_ZERO Summary of this function goes here
%   Detailed explanation goes here

evl = 1e-9;
eper = 0.15;

flag = (sum(abs(S.DATA1) < evl) > (S.NPTS * eper));
end

