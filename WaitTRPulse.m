function varargout = WaitTRPulse(DEVICE)
% code written by mdB, ACM to wait for scanner triggers
recorded = false;
TRIGGER_keycode = '5%';
secs = -1;
loop_delay = .0005;
TIMEOUT = 0.050; % 50 ms waiting period for trigger
TRlength = 2;
if ~exist('timeToWait', 'var')
    timeToWait = inf;
end
% figure out how you want to set device names
if ~exist('DEVICE', 'var')
    DEVICE = -1;
end
timeToWait = GetSecs + TIMEOUT;
while (GetSecs<timeToWait)
    WaitSecs(loop_delay);
    if timeToWait < inf % if set a time, make sure it's within 1 TR
        if GetSecs > timeToWait - (TRlength - TRlength/2) %only look if within a TR
            [keyIsDown,secs,keyCode] = KbCheck(DEVICE);
            if keyIsDown && any(ismember(TRIGGER_keycode,find(keyCode)))
                recorded = true;
                break;
            end
        end
    else % if haven't set a time, just wait until the trigger is pressed
        [keyIsDown,secs,keyCode] = KbCheck(DEVICE);
        if keyIsDown && any(ismember(TRIGGER_keycode,find(keyCode)))
            recorded = true;
            break;
        end
    end
end
varargout{1} = secs;
varargout{2} = recorded;
end
