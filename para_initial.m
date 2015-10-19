function [ status ] = para_initial( step )
%PARA_INITIAL Summary of this function goes here
%   Detailed explanation goes here

setGlobalstr = @(var, num) (strjoin({...
    ['global ', var, ';'], ...
    [var, '=', num2str(num), ';']}));

freq_low = 0.1;
freq_high = 6;
filter_order = 4;
taper_percentile = 0.01;
hampel_win = 0.5;

freq_low_absm = 0.5;
freq_high_absm = 5;
water_level = 10;
winlen_absm = floor(0.5 / freq_low);
winlen_absm = winlen_absm - (mod(winlen_absm, 2) == 0);
max_iter = 15;

seg_seconds = 1200;

xcorr_winlen = 1800;
xcorr_overlap = 0.75;
xcorr_wintype = 'hann';

try
    switch step
        case 'clear'
            clear global
            status = 0;
        case 'precond'
            eval(setGlobalstr('FREQ_LOW', freq_low));
            eval(setGlobalstr('FREQ_HIGH', freq_high));
            eval(setGlobalstr('FILTER_ORDER', filter_order));
            eval(setGlobalstr('TAPER_PERCENTILE', taper_percentile));
            eval(setGlobalstr('HAMPEL_WIN', hampel_win));
            status = 0;
        case 'absmean'
            eval(setGlobalstr('FREQ_LOW_ABSM', freq_low_absm));
            eval(setGlobalstr('FREQ_HIGH_ABSM', freq_high_absm));
            eval(setGlobalstr('FILTER_ORDER', filter_order));
            eval(setGlobalstr('WINLEN_ABSM', winlen_absm));
            eval(setGlobalstr('WATER_LEVEL', water_level));
            eval(setGlobalstr('HAMPEL_WIN', hampel_win));
            eval(setGlobalstr('MAX_ITER', max_iter));
        case 'specnorm'
            eval(setGlobalstr('FREQ_LOW_ABSM', freq_low_absm));
            eval(setGlobalstr('FREQ_HIGH_ABSM', freq_high_absm));
            eval(setGlobalstr('TAPER_PERCENTILE', taper_percentile));
        case 'incisise'
            eval(setGlobalstr('SEG_SECOND', seg_seconds));
            status = 0;
        case 'xcorr'
            eval(setGlobalstr('XCORR_WINLEN', xcorr_winlen));
            eval(setGlobalstr('XCORR_OVERLAP', xcorr_overlap));
            eval(setGlobalstr('XCORR_WINTYPE', xcorr_wintype));
            status = 0;
        otherwise
            status = 1;
    end
catch ME
    rethrow(ME)
end
end