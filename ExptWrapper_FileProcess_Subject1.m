%ExptWrapper_FileProcess_Subject9

%exptDir = '~/code/punisher02/';
%cd(exptDir);
subjectNum = 1;
subjectName = 'rtAttenPenn1';
matchNum = 0;
realtimeData = 1;
KbName('UnifyKeyNames')
addpath(genpath('/opt/psychtoolbox/'))
%% Generate expt sequence

if matchNum ==0
    runNum = 1;
    rtfeedback = 0;
    negdist = 0;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,negdist)
    
    runNum = 2;
    rtfeedback = 1;
    negdist = 1;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,negdist)
    
    runNum = 3;
    rtfeedback = 1;
    negdist = 1;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,negdist)
    
    runNum = 4;
    rtfeedback = 1;
    negdist = 1;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,negdist)
    
    runNum = 5;
    rtfeedback = 1;
    negdist = 1;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,negdist)
    
    runNum = 6;
    rtfeedback = 1;
    negdist = 1;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,negdist)
end

%% Generate mask

scanNum = 6;

if scanNum < 10
    fn = ['/rt_test/temp/' datestr(now,10) datestr(now,5) datestr(now,7) '.' subjectName '.' subjectName '/001_00000' num2str(scanNum) '_000006.dcm'];
else
    fn = ['/rt_test/temp/' datestr(now,10) datestr(now,5) datestr(now,7) '.' subjectName '.' subjectName '/001_0000' num2str(scanNum) '_000006.dcm'];
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
%testing file processing
% put this in to test:fMRI = 2;
[patterns] = RealTimePunisherFileProcess(subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)

%% Run 2 file process

runNum = 2;
fMRI = 10;
[patterns] = RealTimePunisherFileProcess(subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)

%%

runNum = 3;
fMRI = 12;
[patterns] = RealTimePunisherFileProcess(subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)


%%

runNum = 4;
fMRI = 14;
[patterns] = RealTimePunisherFileProcess(subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)


%%

runNum = 5;
fMRI = 16;
[patterns] = RealTimePunisherFileProcess(subjectNum,subjectName,matchNum,runNum,fMRI,realtimeData)


%%

runNum = 6;
fMRI = 18;
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
