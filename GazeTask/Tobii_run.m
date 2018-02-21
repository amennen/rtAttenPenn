%%
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
    
tetio_startTracking;

T1=GetSecs;
Temp = tetio_localTimeNow;
timing.frames.remote = tetio_localToRemoteTime(Temp);
WaitSecs(10)
% so T1 and Time2 should be the same time
tetio_stopTracking;


[GazeData.Left, GazeData.Right, GazeData.Timing.Remote] = tetio_readGazeData; %Pull data off the eyetracker



% now look for indiividual trial
GazeX.Left = GazeData.Left{trial}(:,7);
GazeY.Left = GazeData.Left{trial}(:,8);
GazeX.Right = GazeData.Right{trial}(:,7);
GazeY.Right = GazeData.Right{trial}(:,8);
GazeStatus.Left = GazeData.Left{trial}(:,13);
GazeStatus.Right = GazeData.Left{trial}(:,13);
nPts = size(GazeData.Left{trial},1);
deltaTime = nPts/120
nTrial=20;
for trial = 1:nTrial
    DisplayData(z.GazeData.Left{trial},z.GazeData.Right{trial} );
end
% 120 samples/s so nPts/120 gives time
tetio_disconnectTracker;
tetio_cleanUp;

%% how to look at the eye tracking data saved-- check it seems okay
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
gaze = (d.timing.gaze.pic(1) - d.timing.gaze.off(1))/1000
nTrial=20;
for trial = 1:nTrial
    DisplayData(z.GazeData.Left{trial},z.GazeData.Right{trial} );
end

