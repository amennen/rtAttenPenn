exptDir = '~/rtAttenPenn/GazeTask/';
cd(exptDir)
addpath(genpath('/Applications/Psychtoolbox/'))
addpath(genpath('~/Tobii/'))

subjectNum = 1;
subjectDay=1;
projectName = 'rtAttenPenn';
Screen('Preference', 'SkipSyncTests', 2);
% **** types of stimuli to train/show to subjects *******

useTobii=0;
debug=0;
KbName('UnifyKeyNames')

% randomize order order
seed = sum(100*clock); %get random seed
RandStream.setGlobalStream(RandStream('mt19937ar','seed',seed));%set seed

%% make randomized order
if subjectDay==1
    ndays = 4;
    testOrder = randperm(ndays);
    dataHeader = ['data/subject' num2str(subjectNum)];
    if ~exist(dataHeader)
        mkdir(dataHeader)
    end
    save([dataHeader '/' 'subjorder'], 'testOrder');
end

%%
runNum=1;
RealTimeGazeDisplay(subjectNum,subjectDay,useTobii,debug)
close all;
Screen('CloseAll')

%%
copyallfilesforsubject(subjectNum,subjectDay)