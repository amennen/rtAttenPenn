%ExptWrapper_FileProcess_Subject9

%exptDir = '~/code/punisher02/';
%cd(exptDir);
subjectNum = 100;
projectName = 'rtAttenPenn';
subjectRun = 1;
%subjectName = 'rtAttenPenn1';
subjectName = ['behav' num2str(subjectNum)];
% **** types of stimuli to train/show to subjects *******
NEUTRAL = 1;
SAD = 2;
HAPPY = 3;
% *******************************************************
typeNum = HAPPY;
matchNum = 0;
realtimeData = 0;
KbName('UnifyKeyNames')
addpath(genpath('/opt/psychtoolbox/'))
%% Generate expt sequence
%make it fore each of the different type numbers and counterbalance order
%for every subject
if matchNum ==0
    runNum = 1;
    rtfeedback = 0;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum)
    
    runNum = 2;
    % changing it here for behavioral have rtfeedback = 0
    rtfeedback = 0;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum)
    
    runNum = 3;
    rtfeedback = 0;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum)
    
    runNum = 4;
    rtfeedback = 0;
    [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,typeNum)
    

end