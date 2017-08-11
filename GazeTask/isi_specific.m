%% inter-stimulus interval, exit on trigger
function [onset_time] = isi_specific(window,fontColor,timespec)

    if ~exist('timespec', 'var')
        timespec = GetSecs;
    end
    DrawFormattedText(window,'+','center','center',fontColor,2);
    onset_time = Screen('Flip',window, timespec);

        
return
