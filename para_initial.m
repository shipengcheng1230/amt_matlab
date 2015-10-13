function [ status ] = para_initial( step )
%PARA_INITIAL Summary of this function goes here
%   Detailed explanation goes here
status = 1;

setGlobalstr = @(var, num) (strjoin({...
    ['global ', var, ';'], ...
    [var, '=', num2str(num), ';']}));

freq_low = 0.1;
freq_high = 6;
filter_order = 4;
freq_low_absm = 0.5;
freq_high_absm = 5;
taper_percentile = 0.01;

seg_seconds = 86400;

winlen_absm = floor(0.5 / freq_low);
winlen_absm = winlen_absm - (mod(winlen_absm, 2) == 0);

xcorr_winlen = 1800;
xcorr_overlap = 0.75;
xcorr_wintype = 'hann';

switch step
    case 0
        clear global
        status = 0;
    case 1        
        eval(setGlobalstr('FREQ_LOW', freq_low));
        eval(setGlobalstr('FREQ_HIGH', freq_high));
        eval(setGlobalstr('FILTER_ORDER', filter_order));       
        eval(setGlobalstr('FREQ_LOW_ABSM', freq_low_absm));
        eval(setGlobalstr('FREQ_HIGH_ABSM', freq_high_absm));
        eval(setGlobalstr('WINLEN_ABSM', winlen_absm));
        eval(setGlobalstr('SEG_SECONDS', seg_seconds));
        eval(setGlobalstr('TAPER_PERCENTILE', taper_percentile));
        status = 0;
    case 2
        eval(setGlobalstr('FREQ_LOW_ABSM', freq_low_absm));
        eval(setGlobalstr('FREQ_HIGH_ABSM', freq_high_absm));
        eval(setGlobalstr('TAPER_PERCENTILE', taper_percentile));
    case 3 
        eval(setGlobalstr('SEG_SECOND', seg_seconds));
        status = 0;
    case 4
        eval(setGlobalstr('XCORR_WINLEN', xcorr_winlen));
        eval(setGlobalstr('XCORR_OVERLAP', xcorr_overlap));
        eval(setGlobalstr('XCORR_WINTYPE', xcorr_wintype));
        status = 0;
end