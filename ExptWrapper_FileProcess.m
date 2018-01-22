%ExptWrapper_FileProcess_Subject9
addpath(genpath('jsonlab-1.5'))
addpath(genpath('/opt/psychtoolbox/'))

%exptDir = '~/code/punisher02/';
%cd(exptDir);
%addpath(genpath('/opt/psychtoolbox/'))
%addpath(genpath('jsonlab-1.5'))

%%
%conf = loadjson('conf/example.json');
subjectNum = 500;
projectName = 'rtAttenPenn';
%imgDirHeader = conf.imgDirHeader;
subjectRun = 1;
%subjectName = 'rtAttenPenn1';
subjectName = [datestr(now,5) datestr(now,7) datestr(now,11) num2str(subjectRun) '_' projectName];
%subjDate = '8-11-17';
%subjectName = [datestr(subjDate,5) datestr(subjDate,7) datestr(subjDate,11) num2str(subjectRun) '_' projectName];
% **** types of stimuli to train/show to subjects *******
NEUTRAL = 1;
SAD = 2;
HAPPY = 3;
% *******************************************************
typeNum = SAD;
matchNum = 0;
realtimeData = 1;
expDay = 1; % important to say what day number it is so it counterbalances things right! things will alternate every other
KbName('UnifyKeyNames')

addpath(genpath('/opt/psychtoolbox/'))
imgDirHeader = '/Data1/subjects/';
%% Generate expt sequence

if matchNum ==0
    runNum = 1;
    rtfeedback = 0;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum,expDay)
    
    runNum = 2;
    % changing it here for behavioral have rtfeedback = 0
    rtfeedback = 1;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum,expDay)
    
    runNum = 3;
    rtfeedback = 1;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum,expDay)
    
    runNum = 4;
    rtfeedback = 1;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum,expDay)
    
    runNum = 5;
    rtfeedback = 1;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum,expDay)
    
    runNum = 6;
    rtfeedback = 1;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum,expDay)
end

%% Generate mask
% first localizer: 1 files
% then 5 is the first functional
scanNum = 3;
if scanNum < 10
    fn = ['/mnt/rtexport/RTexport_Current/' datestr(now,10) datestr(now,5) datestr(now,7) '.' subjectName '.' subjectName '/001_00000' num2str(scanNum) '_000006.dcm'];
else
    fn = ['/mnt/rtexport/RTexport_Current/' datestr(now,10) datestr(now,5) datestr(now,7) '.' subjectName '.' subjectName '/001_0000' num2str(scanNum) '_000006.dcm'];
end
mask = GenerateMask(fn);

if matchNum == 0
    save(['./data/' num2str(subjectNum) '/mask_' num2str(subjectNum)],'mask');
else
    save(['./data/' num2str(subjectNum) '_match/mask_' num2str(subjectNum)],'mask');
end
%% Run 1 file process

runNum = 1;
fMRI = 8;
%today's testing 3/7
%testing file processing
realtimeData = 1;
debug = 0
% put this in to test:fMRI = 2;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)

%% Run 2 file process

runNum = 2;
fMRI = 16;

[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)

%%

runNum = 3;
fMRI = 14;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)


%%

runNum = 4;
fMRI = 16;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)


%%

runNum = 5;
fMRI = 18;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)


%%

runNum = 6;
fMRI = 20;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)


%%

runNum = 7;
fMRI = 20;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)


%%

runNum = 8;
fMRI = 22;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)

%%

runNum = 9;
fMRI = 24;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)
