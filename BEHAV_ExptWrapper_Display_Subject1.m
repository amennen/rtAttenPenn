%exptDir = '~/code/rtAttenPenn/';
%cd(exptDir)
subjectNum = 100;
projectName = 'rtAttenPenn';
subjectName = ['behav' num2str(subjectNum)];

Screen('Preference', 'SkipSyncTests', 1);
% **** types of stimuli to train/show to subjects *******
NEUTRAL = 1;
SAD = 2;
HAPPY = 3;
% *******************************************************
typeNum = HAPPY;

matchNum = 0;
useButtonBox=0;
realtimeData = 0;
debug=1;
fMRI = 0;
KbName('UnifyKeyNames')
addpath(genpath('/opt/psychtoolbox/'))

%%
runNum=1;

% today's scanning number
debug = 1
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)


