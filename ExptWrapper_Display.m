%exptDir = '~/code/rtAttenPenn/';
%cd(exptDir)
subjectNum = 6;
projectName = 'rtAttenPenn';
Screen('Preference', 'SkipSyncTests', 1);
subjectRun = 1;
subjectDay = 1;
% **** types of stimuli to train/show to subjects *******
NEUTRAL = 1;
SAD = 2;
HAPPY = 3;
% *******************************************************
typeNum = SAD;

subjectName = [datestr(now,5) datestr(now,7) datestr(now,11) num2str(subjectRun) '_' projectName];
matchNum = 0;
useButtonBox=1;
realtimeData = 1;
debug=0;
KbName('UnifyKeyNames')
addpath(genpath('/opt/psychtoolbox/'))

% SETTING: ALWAYS GOING TO SAVE IN THE FOLDER WHERE IT IS--AFTER CAN COPY
% TO AN ELSEWHERE LOCATION BUT IT'S SET FOR GIT IGNORE
%% DO THIS AT THE END: COPY ALL FILES INTO SUBJECT FOLDER
copyallfilesforsubject(subjectNum,subjectDay)
%%
runNum=1;
% today's scanning number
fMRI = 6;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)

%%
runNum=6;
fMRI = 16;
useButtonBox = 1
realtimeData = 1
debug = 1
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)


%%
runNum = 3;
fMRI = 14;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)


%%
runNum = 4;
fMRI = 16;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)


%%
runNum = 5;
fMRI = 18;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)

%%
runNum = 6;
fMRI = 20;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)


%%

runNum = 7;
fMRI = 20;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)


%%

runNum = 8;
fMRI = 22;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)


%%

runNum = 9;
fMRI = 24;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)
