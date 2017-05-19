exptDir = '~/code/rtAttenPenn/';
cd(exptDir)
subjectNum = 3;
projectName = 'rtAttenPenn';
Screen('Preference', 'SkipSyncTests', 1);
runNum = 1;
% **** types of stimuli to train/show to subjects *******
NEUTRAL = 1;
SAD = 2;
HAPPY = 3;
% *******************************************************
typeNum = NEUTRAL;

subjectName = [datestr(now,5) datestr(now,7) datestr(now,11) num2str(runNum) '_' projectName];
matchNum = 0;
useButtonBox=1;
realtimeData = 1;
debug=0;
KbName('UnifyKeyNames')
addpath(genpath('/opt/psychtoolbox/'))

%%
runNum=1;
fMRI = 5;

% today's scanning number
fMRI = 10

[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)


%%
runNum=2;
fMRI = 12;
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
