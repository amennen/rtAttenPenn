%% first specify things that change
subjectNum = 1;
subjectRun = 1; % run number for the day
subjectDay = 1; % this will determine which mask the RT thing will use VERY IMPORTANT AND COUNTERBALANCING
%imgDirHeader = '/Data1/subjects/';
% for testing code at Princeton
% for Penn
imgDirHeader = '/mnt/rtexport/RTexport_Current/';
realtimeData = 1;
debug = 0;
%% specify everything else
projectName = 'rtAttenPenn';
subjectName = [datestr(now,5) datestr(now,7) datestr(now,11) num2str(subjectRun) '_' projectName];

%subjDate = '4-5-17';
%subjectName = [datestr(subjDate,5) datestr(subjDate,7) datestr(subjDate,11) num2str(subjectRun) '_' projectName];

% **** types of stimuli to train/show to subjects *******
NEUTRAL = 1;
SAD = 2;
HAPPY = 3;
% *******************************************************
typeNum = SAD;
addpath(genpath('/opt/psychtoolbox/'))
KbName('UnifyKeyNames')
%% Generate expt sequence

runNum = 1;
rtfeedback = 0;
[blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum,subjectDay)

runNum = 2;
% changing it here for behavioral have rtfeedback = 0
rtfeedback = 1;
[blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum,subjectDay)

runNum = 3;
rtfeedback = 1;
[blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum,subjectDay)

runNum = 4;
rtfeedback = 1;
[blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum,subjectDay)

runNum = 5;
rtfeedback = 1;
[blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum,subjectDay)

runNum = 6;
rtfeedback = 1;
[blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum,subjectDay)



%% Run 1 file process
runNum = 1;
fMRI = 10;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,runNum,fMRI,realtimeData,subjectDay)

%% Run 2 file process

runNum = 2;
fMRI = 12;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,runNum,fMRI,realtimeData,subjectDay)

%%

runNum = 3;
fMRI = 13;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,runNum,fMRI,realtimeData,subjectDay)


%%

runNum = 4;
fMRI = 17;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,runNum,fMRI,realtimeData,subjectDay)


%%

runNum = 5;
fMRI = 18;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,runNum,fMRI,realtimeData,subjectDay)


%%

runNum = 6;
fMRI = 20;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,runNum,fMRI,realtimeData,subjectDay)


%%

runNum = 7;
fMRI = 20;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,runNum,fMRI,realtimeData,subjectDay)


%%

runNum = 8;
fMRI = 22;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,runNum,fMRI,realtimeData,subjectDay)

%%

runNum = 9;
fMRI = 24;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,runNum,fMRI,realtimeData,subjectDay)
