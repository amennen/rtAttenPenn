% tobii file is located in annemennen/Tobii

% first manual config
% (1) first go to that File --> Applications --> Eyetracker Browser
% you should see the eyetrakcer pop up
% click config tool
% put in measuremensts
% click save to eye tracker

% HandleCalibWorkflow is literally what puts up the points
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
d = load('gazedata_20180228T112516.mat');
% saves a different array for each of the trials--left, right, remote
% now look for indiividual trial
trial = 3;
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
(d.timing.gaze.off(1) - d.timing.gaze.pic(1))/(1E6);
d.timing.actualOnsets.preITI(2)-  d.timing.startEye(1); % this is longer than 5 second because it waits to flip screen
% which is 40 ms longer than the start and stop eyetrakcing but that's
% okay it matches mostly
% all timing point recorded: 
%tetio_remoteToLocalTime(d.GazeData.Timing.Remote{1}(1))
%t1 = d.GazeData.Timing.Remote{1};
%tp1 = t1(1);
%tetio_remoteToLocalTime(int(tp1))
%temp = typecast(tp1, 'int64')
%loctime = tetio_remoteToLocalTime(temp);
%%
trial = 20;
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


%now look at coordinates--which pos are you looking ats
screenX = 1280;
screenY = 1024;
centerX = screenX/2; centerY = screenY/2;
imageSize2 = imageSize;
actual_imageSize = [400 400];
imageRect = [0 0 actual_imageSize(1) actual_imageSize(2)];
% placeholder for images
%border = screenX/20;
% try to scale border to area of screen
% maybe make a little bigger?
%border = (screenY - imageSize(2)*2)/2;
border = (screenY - imageSize(2)*2)/1.5;
% try 2/28 make border bigger
borderH = border/2;

% for upper right
X1 = centerX + borderH;
X2 = X1 + imageSize2(1);
Y2 = centerY - borderH;
Y1 = Y2 - imageSize2(2);
imPos(1,:) = [X1,Y1,X2,Y2];

% for upper left
X2 = centerX - borderH;
X1 = X2 - imageSize2(1);
Y2 = centerY - borderH;
Y1 = Y2 - imageSize2(2);
imPos(2,:) = [X1,Y1,X2,Y2];

% for lower left
X2 = centerX - borderH;
X1 = X2 - imageSize2(1);
Y1 = centerY + borderH;
Y2 = Y1 + imageSize2(2);
imPos(3,:) = [X1,Y1,X2,Y2];

% for lower right
X1 = centerX + borderH;
X2 = X1 + imageSize2(1);
Y1 = centerY + borderH;
Y2 = Y1 + imageSize2(2);
imPos(4,:) = [X1,Y1,X2,Y2];
resvec = [screenX screenY screenX screenY];
pos_1 = imPos(1,:)./resvec;
pos_2 = imPos(2,:)./resvec;
pos_3 = imPos(3,:)./resvec;
pos_4 = imPos(4,:)./resvec;

% now test to see what comes where
% take mean of x and y

rightEyeAll = d.GazeData.Right{trial}(trial_rows,:);
leftEyeAll = d.GazeData.Left{trial}(trial_rows,:);
rightGazePoint2d.x = rightEyeAll(:,7);
rightGazePoint2d.y = rightEyeAll(:,8);
leftGazePoint2d.x = leftEyeAll(:,7);
leftGazePoint2d.y = leftEyeAll(:,8);
gaze.x = mean([rightGazePoint2d.x, leftGazePoint2d.x],2);
gaze.y = mean([rightGazePoint2d.y, leftGazePoint2d.y],2);
% so ignore any negatives (will do that anyway)
% find points in area one
% when you have both left and right eye (later can just use one)
n_points = length(find(gaze.x > 0 & gaze.y >0));
n_pos1 = find((gaze.x >= pos_1(1) & gaze.x<=pos_1(3)) & (gaze.y >= pos_1(2) & gaze.y<=pos_1(4)));
n_pos2 = find((gaze.x >= pos_2(1) & gaze.x<=pos_2(3)) & (gaze.y >= pos_2(2) & gaze.y<=pos_2(4)));
n_pos3 = find((gaze.x >= pos_3(1) & gaze.x<=pos_3(3)) & (gaze.y >= pos_3(2) & gaze.y<=pos_3(4)));
n_pos4 = find((gaze.x >= pos_4(1) & gaze.x<=pos_4(3)) & (gaze.y >= pos_4(2) & gaze.y<=pos_4(4)));

r_pos1 = length(n_pos1)/n_points
r_pos2 = length(n_pos2)/n_points
r_pos3 = length(n_pos3)/n_points
r_pos4 = length(n_pos4)/n_points
