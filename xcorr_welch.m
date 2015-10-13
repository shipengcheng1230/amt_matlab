function [ cor_data ] = xcorr_welch( ...
    S1, S2, winlen, overlap, wintype )
%XCORR_WELCH Summary of this function goes here
%   Detailed explanation goes here

if abs(S1.DELTA - S2.DELTA) > 1e-9
    ME = MException(...
        'dataMismatch:SampletimeMismatch', ...
        'sample time:\n %f\n %f\n', ...
        S1.DELTA, S2.DELTA);
    throw(ME)
end

pstride = floor(winlen / S1.DELTA * (1 - overlap));
winpoint = floor(winlen / S1.DELTA);
winlen = 2 * winpoint - 1;
cor_data = zeros(winlen, 1);
winfun = eval([wintype, '(', num2str(winpoint), ')']);
S1.NPTS = min(S1.NPTS, S2.NPTS);

for ii = 1: pstride: S1.NPTS
    if ii + winpoint > S1.NPTS
        dtemp1 = ...
            (S1.DATA1(S1.NPTS - winpoint + 1: S1.NPTS) .* winfun);
        dtemp2 = ...
            (S2.DATA1(S1.NPTS - winpoint + 1: S1.NPTS) .* winfun);
    else
        dtemp1 = ...
            (S1.DATA1(ii: ii + winpoint - 1) .* winfun);
        dtemp2 = ...
            (S2.DATA1(ii: ii + winpoint - 1) .* winfun);
    end
    cor_data = cor_data + xcorr(dtemp1, dtemp2);
end

end