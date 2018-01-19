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

% set the parameters for which day you're on
dayNum = 1;
% RANDOMIZE THE ORDER!!!! NOT COUNTERBALANCED!!!

% now counterbalance orders of testing
dayMap = mod(subjectNum-1,4)+1;
% randomize order order
seed = sum(100*clock); %get random seed
RandStream.setGlobalStream(RandStream('mt19937ar','seed',seed));%set seed
% could be perfectly counterbalnced or just randomized for each subject
% what their order is
%%
runNum=1;
RealTimeGazeDisplay(subjectNum,matchNum,useTobii,debug)
close all;
Screen('CloseAll')

%%