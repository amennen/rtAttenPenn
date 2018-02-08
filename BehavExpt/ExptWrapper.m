%ExptWrapper_FileProcess_Subject9

subjectNum = 500;
subjectName = ['behav' num2str(subjectNum)];
subjectDay = 1;
% if subjectDay == 1
%    % then you want it so the day order is going to be shuffled for that subject
%    % randomize order fore that person and save in that day order
%    condOrder = shuffle([1:4]);
% end
% **** types of stimuli to train/show to subjects *******
NEUTRAL = 1;
SAD = 2;
HAPPY = 3;
% *******************************************************
realtimeData = 0;    
rtfeedback = 0;
useButtonBox = 0; %maybe replace with keyboard eventually?
rtData = 0;
fMRI = 0;
debug = 0;
ex_image_dir = pwd;
KbName('UnifyKeyNames')
addpath(genpath('/opt/psychtoolbox/'))

% figure out how to find what directory you need



%% Generate expt sequence
%make it fore each of the different type numbers and counterbalance order
%for every subject

% generate all neutral first seconds

runNum = 1;
[blockData patterns] = BehavExptSequence(subjectNum,subjectName,runNum,rtfeedback,subjectDay);

% now go through the rest
nRuns = 1;
% counterbalance order of if happy or sad is first/then if first or
% second order so 4 options
for i = 1:nRuns
    % changing it here for behavioral have rtfeedback = 0
    runNum = i+1;
    [blockData patterns] = BehavExptSequence(subjectNum,subjectName,runNum,rtfeedback,subjectDay);
end

%% now run instructions

BehavInstruct(subjectNum,subjectName,1,subjectDay,debug);

%% now run exp sequence
runNum = 1;
BehavDisplay(subjectNum,subjectName,runNum,subjectDay,useButtonBox,fMRI,rtData,debug)
% change the image paths inside this script
runNum = 2;
BehavDisplay(subjectNum,subjectName,runNum,subjectDay,useButtonBox,fMRI,rtData,debug)

%runNum = 3;
%BehavDisplay(subjectNum,subjectName,runNum,subjectDay,useButtonBox,fMRI,rtData,debug)

%%
copyallfilesforsubject(subjectNum,subjectDay);