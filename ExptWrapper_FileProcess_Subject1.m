%ExptWrapper_FileProcess_Subject9

%exptDir = '~/code/punisher02/';
%cd(exptDir);
subjectNum = 100;
projectName = 'rtAttenPenn';
subjectRun = 1;
%subjectName = 'rtAttenPenn1';
subjectName = [datestr(now,5) datestr(now,7) datestr(now,11) num2str(subjectRun) '_' projectName];
runNum = 1;
% **** types of stimuli to train/show to subjects *******
NEUTRAL = 1;
SAD = 2;
HAPPY = 3;
% *******************************************************
typeNum = HAPPY;
subjectName = [datestr(now,5) datestr(now,7) datestr(now,11) num2str(runNum) '_' projectName];
matchNum = 0;
realtimeData = 1;
KbName('UnifyKeyNames')
addpath(genpath('/opt/psychtoolbox/'))
%% Generate expt sequence

if matchNum ==0
    runNum = 1;
    rtfeedback = 0;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum)
    
    runNum = 2;
    rtfeedback = 1;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum)
    
    runNum = 3;
    rtfeedback = 1;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum)
    
    runNum = 4;
    rtfeedback = 1;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum)
    
    runNum = 5;
    rtfeedback = 1;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum)
    
    runNum = 6;
    rtfeedback = 1;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum)
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
ProcessMask(subjectNum,funcScan,subjectRun);
%% Run 1 file process

runNum = 1;
fMRI = 5;
%today's testing 3/7
fMRI = 10
%testing file processing
realtimeData = 0;
fMRI = 0;
debug = 1
% put this in to test:fMRI = 2;
[patterns] = RealTimePunisherFileProcess(subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)

%% Run 2 file process

runNum = 2;
fMRI = 12;
[patterns] = RealTimePunisherFileProcess(subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)

%%

runNum = 3;
fMRI = 14;
[patterns] = RealTimePunisherFileProcess(subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)


%%

runNum = 4;
fMRI = 16;
[patterns] = RealTimePunisherFileProcess(subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)


%%

runNum = 5;
fMRI = 18;
[patterns] = RealTimePunisherFileProcess(subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)


%%

runNum = 6;
fMRI = 20;
[patterns] = RealTimePunisherFileProcess(subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)


%%

runNum = 7;
fMRI = 20;
[patterns] = RealTimePunisherFileProcess(subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)


%%

runNum = 8;
fMRI = 22;
[patterns] = RealTimePunisherFileProcess(subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)

%%

runNum = 9;
fMRI = 24;
[patterns] = RealTimePunisherFileProcess(subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)
