%exptDir = '~/code/rtAttenPenn/';
%cd(exptDir)
subjectNum = 100;
projectName = 'rtAttenPenn';
Screen('Preference', 'SkipSyncTests', 1);
% **** types of stimuli to train/show to subjects *******

matchNum = 0;
useTobii=0;
realtimeData = 0;
debug=1;
KbName('UnifyKeyNames')
addpath(genpath('/opt/psychtoolbox/'))

%%
if useTobii
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
end

%%
runNum=1;
RealTimeGazeDisplay(subjectNum,matchNum,useTobii,debug)


