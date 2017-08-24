%exptDir = '~/code/rtAttenPenn/';
%cd(exptDir)
subjectNum = 100;
projectName = 'rtAttenPenn';
Screen('Preference', 'SkipSyncTests', 1);
% **** types of stimuli to train/show to subjects *******

matchNum = 0;
useTobii=0;
realtimeData = 0;
debug=0;
KbName('UnifyKeyNames')
addpath(genpath('/opt/psychtoolbox/'))
addpath(genpath('~/Tobii/'))

%%
runNum=1;
useTobii=0;
RealTimeGazeDisplay(subjectNum,matchNum,useTobii,debug)


