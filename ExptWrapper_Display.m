% do this once at the start
seed = sum(100*clock); %get random seed
RandStream.setGlobalStream(RandStream('mt19937ar','seed',seed));%set seed

%% first specify the things that change
subjectNum = 8;
subjectRun = 1;
subjectDay = 1;

useButtonBox=1;
% CHANGE TRIGGER BACK!!!
realtimeData = 1;
debug=0;
usepyoutput = 0;

%% DO THIS AT THE END: COPY ALL FILES INTO SUBJECT FOLDER
copyallfilesforsubject(subjectNum,subjectDay)
%% then specify everything else
projectName = 'rtAttenPenn';
Screen('Preference', 'SkipSyncTests', 1);
% **** types of stimuli to train/show to subjects *******
NEUTRAL = 1;
SAD = 2;
HAPPY = 3;
% *******************************************************
typeNum = SAD;
subjectName = [datestr(now,5) datestr(now,7) datestr(now,11) num2str(subjectRun) '_' projectName];
KbName('UnifyKeyNames')
addpath(genpath('/opt/psychtoolbox/'))
%%
runNum=1;
% today's scanning number
fMRI = 8;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,runNum,subjectDay,useButtonBox,fMRI,realtimeData,debug,usepyoutput)

%%
runNum=2;
fMRI = 10;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,runNum,subjectDay,useButtonBox,fMRI,realtimeData,debug,usepyoutput)


%%
runNum = 3;
fMRI = 15;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,runNum,subjectDay,useButtonBox,fMRI,realtimeData,debug,usepyoutput)


%%
runNum = 4;
fMRI = 17;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,runNum,subjectDay,useButtonBox,fMRI,realtimeData,debug,usepyoutput)


%%
runNum = 5;
fMRI = 19;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,runNum,subjectDay,useButtonBox,fMRI,realtimeData,debug,usepyoutput)

%%
runNum = 6;
fMRI = 20;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,runNum,subjectDay,useButtonBox,fMRI,realtimeData,debug,usepyoutput)


%%

runNum = 7;
fMRI = 20;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,runNum,subjectDay,useButtonBox,fMRI,realtimeData,debug,usepyoutput)


%%

runNum = 8;
fMRI = 22;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,runNum,subjectDay,useButtonBox,fMRI,realtimeData,debug,usepyoutput)


%%

runNum = 9;
fMRI = 24;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,runNum,subjectDay,useButtonBox,fMRI,realtimeData,debug,usepyoutput)
