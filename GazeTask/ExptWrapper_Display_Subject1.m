%exptDir = '~/code/rtAttenPenn/';
%cd(exptDir)
addpath(genpath('/Applications/Psychtoolbox/'))
addpath(genpath('~/Tobii/'))

subjectNum = 100;
projectName = 'rtAttenPenn';
Screen('Preference', 'SkipSyncTests', 1);
% **** types of stimuli to train/show to subjects *******

matchNum = 0;
useTobii=1;
realtimeData = 0;
debug=0;
KbName('UnifyKeyNames')

%%
runNum=1;
RealTimeGazeDisplay(subjectNum,matchNum,useTobii,debug)
close all;
Screen('CloseAll')
