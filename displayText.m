%% display some text
function startTime = displayText(mainWindow,text,duration,horiz,COLOR,WRAPCHARS,timespec)

    DrawFormattedText(mainWindow,text,'center',horiz,COLOR,WRAPCHARS);
    if ~exist('timespec', 'var')
        timespec = 0;
    end
      
    startTime = Screen('Flip',mainWindow, timespec);
    elapsedTime = 0;
    while (elapsedTime < duration)
        pause(0.005)
        elapsedTime = GetSecs()-startTime;
    end
           
return
