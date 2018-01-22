%ExptWrapper_FileProcess_Subject9
addpath(genpath('jsonlab-1.5'))
addpath(genpath('/opt/psychtoolbox/'))

%exptDir = '~/code/punisher02/';
%cd(exptDir);
%addpath(genpath('/opt/psychtoolbox/'))
%addpath(genpath('jsonlab-1.5'))

%%
%conf = loadjson('conf/example.json');
subjectNum = 6;
projectName = 'rtAttenPenn';
%imgDirHeader = conf.imgDirHeader;
subjectRun = 1; % run number for the day
subjectDay = 1; % this will determine which mask the RT thing will use VERY IMPORTANT AND COUNTERBALANCING
subjectName = [datestr(now,5) datestr(now,7) datestr(now,11) num2str(subjectRun) '_' projectName];
%subjectName = [datestr(subjDate,5) datestr(subjDate,7) datestr(subjDate,11) num2str(subjectRun) '_' projectName];
% **** types of stimuli to train/show to subjects *******
NEUTRAL = 1;
SAD = 2;
HAPPY = 3;
% *******************************************************
typeNum = SAD;
matchNum = 0;
realtimeData = 1;
KbName('UnifyKeyNames')

addpath(genpath('/opt/psychtoolbox/'))
% for testing code at Princeton
imgDirHeader = '/Data1/subjects/';
% for Penn
imgDirHeader = '/mnt/';
%% Generate expt sequence

if matchNum ==0
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
end


%% Run 1 file process
% make sure you're putting in the MOCO one!!
runNum = 1;
fMRI = 8;
%today's testing 3/7
%testing file processing
realtimeData = 1;
debug = 0;
% put this in to test:fMRI = 2;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData,subjectDay)

%% Run 2 file process

runNum = 2;
fMRI = 16;

[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData,subjectDay)

%%

runNum = 3;
fMRI = 14;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData,subjectDay)


%%

runNum = 4;
fMRI = 16;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData,subjectDay)


%%

runNum = 5;
fMRI = 18;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData,subjectDay)


%%

runNum = 6;
fMRI = 20;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData,subjectDay)


%%

runNum = 7;
fMRI = 20;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData,subjectDay)


%%

runNum = 8;
fMRI = 22;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData,subjectDay)

%%

runNum = 9;
fMRI = 24;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData,subjectDay)
