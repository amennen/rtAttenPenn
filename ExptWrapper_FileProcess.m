%%
seed = sum(100*clock); %get random seed
RandStream.setGlobalStream(RandStream('mt19937ar','seed',seed));%set seed


%% first specify things that change
subjectNum = 3;
subjectRun = 1; % run number for the day
subjectDay = 3; % this will determine which mask the RT thing will use VERY IMPORTANT AND COUNTERBALANCING
group='HC'; %or 'MDD';
% check that subject number makes sense
if strcmp(group,'HC')
    if subjectNum < 100
        fprintf('HC numbering starts at 1.\n')
    else
        error('ERROR: HC numbering too high.')
    end
elseif strcmp(group, 'MDD')
   if subjectNum <= 100
       error('ERROR: MDD numbering needs to be increased.')
   else
       fprintf('MDD numbering starts at 101.\n')
   end
else
    error('ERROR: incorrect group label.')
end


%%
%imgDirHeader = '/Data1/subjects/';
% for testing code at Princeton
% for Penn
%imgDirHeader = '/Data1/subjects/';
%imgDirHeader = '/mnt/rtexport/RTexport_Current/';
imgDirHeader = '/mnt/Data/';
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

runNum = 7;
rtfeedback = 1;
[blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum,subjectDay)
if subjectDay > 1 % don't need to make if on day 1
    runNum = 8;
    rtfeedback = 1;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum,subjectDay)
    
    if subjectDay == 2
        runNum = 9;
        rtfeedback = 1;
        [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum,subjectDay)
    end
end

%% Run 1 file process
runNum = 1;
fMRI = 8;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,runNum,fMRI,realtimeData,subjectDay)

%% Run 2 file process

runNum = 2511511;
fMRI = 12;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,runNum,fMRI,realtimeData,subjectDay)

%%

runNum = 3;
fMRI = 14;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,runNum,fMRI,realtimeData,subjectDay)


%%

runNum = 4;
fMRI = 16;
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
fMRI = 22;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,runNum,fMRI,realtimeData,subjectDay)


%%

runNum = 8;
fMRI = 24;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,runNum,fMRI,realtimeData,subjectDay)

%%

runNum = 9;
fMRI = 24;
[patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,runNum,fMRI,realtimeData,subjectDay)
