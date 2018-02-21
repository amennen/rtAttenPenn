% tobii file is located in annemennen/Tobii

% first manual config
% (1) first go to that File --> Applications --> Eyetracker Browser
% you should see the eyetrakcer pop up
% click config tool
% put in measuremensts
% click save to eye tracker


%% checking it's okay
try
    Tobii_Initialize;
    isEyeTracking=1;
catch
    warning('EYE TRACKER NOT FOUND');
    isEyeTracking=0;
end
%Calibrate the eye tracker
if isEyeTracking==1
    Continue=0;
    while Continue==0
        Calib=Tobii_Calibration;
        Continue=Tobii_Eyetracking_Feedback(0, Calib, 0);
    end
end
%%
% TIMING: THE LOCALTOREMOTE TIME TELLS THE TIME IN MICROSECONDS!!!
T1=GetSecs;
Temp = tetio_localTimeNow;
Temp/(1E6)
% local time = client computer (in micorseconds--will be the same as the
% GetSecs command)
% remote time = eye tracker -- higher res numbers

%% looking at data
% the gaze data will go from when you call tetio_startTracking --> tetio_stopTracking
% tetiostartEyetracking: 
%time = timing.startEye (GetSecs time)
% timing.actualonsets.pic
% and then timing.gaze.pic(itrial) % this is when it actually flips though


% 1. start eyetracking
%   TIMING: 
    % LOCAL: timing.startEye 
% 2. flip screen to show picture
%   % LOCAL: timing.actualOnsets.pic
    % REMOTE: timing.gaze.pic
% 3. show ISI
%   %LOCAL: timing.actualOnsets.preITI(t+1)
    %REMOTE: timing.gaze.off(t)
% 4. stop eyetracking (probably just timing.gaze.off)
    %LOCAL: timing.actualOnsets(trial+1) (GetSecs time)
    % and then we have timing.gaze.off

% so there's two different recorded timing for the trial--we'll just need
% to go back to get the proper time points
% check that the time isn't too far apart

%%
d = load('gazedata_20180219T103925.mat');
% saves a different array for each of the trials--left, right, remote
% now look for indiividual trial
trial = 1;
GazeX.Left = d.GazeData.Left{trial}(:,7);
GazeY.Left = d.GazeData.Left{trial}(:,8);
GazeX.Right = d.GazeData.Right{trial}(:,7);
GazeY.Right = d.GazeData.Right{trial}(:,8);
GazeStatus.Left = d.GazeData.Left{trial}(:,13);
GazeStatus.Right = d.GazeData.Left{trial}(:,13);
nPts = size(d.GazeData.Left{trial},1);
deltaTime = nPts/120
% check that the same time is the same difference for the other saved time
onstim = d.timing.actualOnsets.pic(1);
offstim = d.timing.actualOnsets.preITI(2);
(d.timing.gaze.off(1) - d.timing.gaze.pic(1))/(1E6)
d.timing.actualOnsets.preITI(2)-  d.timing.startEye(1) % this is longer than 5 second because it waits to flip screen
% which is 40 ms longer than the start and stop eyetrakcing but that's
% okay it matches mostly
% all timing point recorded: 
tetio_remoteToLocalTime(d.GazeData.Timing.Remote{1}(1))
t1 = d.GazeData.Timing.Remote{1};
%tp1 = t1(1);
%tetio_remoteToLocalTime(int(tp1))
%temp = typecast(tp1, 'int64')
%loctime = tetio_remoteToLocalTime(temp);
%%
trial = 9;
remote_start = d.timing.gaze.pic(trial);
remote_stop = d.timing.gaze.off(trial);
(remote_stop-remote_start)/(1E6)
% now find the data between these time points
time_trial = d.GazeData.Timing.Remote{trial}; % 709 points
trial_rows = intersect(find(time_trial>=remote_start), find(time_trial<=remote_stop));

GazeX.Left = d.GazeData.Left{trial}(trial_rows,7);
GazeY.Left = d.GazeData.Left{trial}(trial_rows,8);
GazeX.Right = d.GazeData.Right{trial}(trial_rows,7);
GazeY.Right = d.GazeData.Right{trial}(trial_rows,8);

DisplayData(d.GazeData.Left{trial}(trial_rows,:),d.GazeData.Right{trial}(trial_rows,:) );
