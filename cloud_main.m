% Add paths
addpath(genpath('/opt/psychtoolbox/'))
addpath(genpath('jsonlab-1.5'))

conf = loadjson('conf/example.json');

subjectNum = 100;
projectName = 'rtAttenPenn';
imgDirHeader = conf.imgDirHeader;
subjectRun = 1;
subjectName = [datestr(now,5) datestr(now,7) datestr(now,11) num2str(subjectRun) '_' projectName];

% **** types of stimuli to train/show to subjects *******
NEUTRAL = 1;
SAD = 2;
HAPPY = 3;
% *******************************************************
typeNum = HAPPY;
matchNum = 0;
realtimeData = 1;
KbName('UnifyKeyNames')

%% Generate expt sequence
GenerateExptSequence(subjectNum, subjectName, typeNum)

%% Run file process
runNum = 2;
fMRI = 16;

[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)

