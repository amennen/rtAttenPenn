%ExptWrapper_FileProcess_Subject9

subjectNum = 100;
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
code_dir = '~/rtAttenPenn/';
image_dir = code_dir; % the images will be in the same place so we don't need to recopy them
ex_image_dir = pwd;
KbName('UnifyKeyNames')
addpath(genpath('/opt/psychtoolbox/'))
%% COUNTERBALANCE
% each person is doing this 4 times so each person will have the order
% % differ
% condMap = mod(subjectNum-1,4)+1;
% switch (condMap)
%     case 1
%         typeOrder = [SAD HAPPY];
%         neutralVec = [1 1 ];
%     case 2
%         typeOrder = [SAD HAPPY];
%         neutralVec = [0 0];
%     case 3
%         typeOrder = [HAPPY SAD];
%         neutralVec = [1 1];
%     case 4
%         typeOrder = [HAPPY SAD];
%         neutralVec = [0 0];
%     otherwise
%         error('Impossible response mapping!');
% end
%% Generate expt sequence
%make it fore each of the different type numbers and counterbalance order
%for every subject

% generate all neutral first seconds

runNum = 1;
[blockData patterns] = RealTimePunisherExptSequence_NEW(subjectNum,subjectName,runNum,rtfeedback,subjectDay);

% now go through the rest
nRuns = 2;
% counterbalance order of if happy or sad is first/then if first or
% second order so 4 options
for i = 1:nRuns
    % changing it here for behavioral have rtfeedback = 0
    runNum = i+1;
    [blockData patterns] = RealTimePunisherExptSequence_NEW(subjectNum,subjectName,runNum,rtfeedback,subjectDay);
end

%% now run instructions

RealTimeBehavInstruct(subjectNum,subjectName,matchNum,1,debug);

%% now run exp sequence
BehavDisplay(subjectNum,subjectName,runNum,subjectDay,useButtonBox,fMRI,rtData,debug)
% change the image paths inside this script