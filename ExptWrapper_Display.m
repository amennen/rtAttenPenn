% do this once at the start
seed = sum(100*clock); %get random seed
RandStream.setGlobalStream(RandStream('mt19937ar','seed',seed));%set seed

%% first specify the things that change
subjectNum = 114; %
subjectRun = 1;
subjectDay = 3;
group='MDD'; %or 'MDD';

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

useButtonBox=1;
% CHANGE TRIGGER BACK!!!
realtimeData = 1;
debug=0;
usepyoutput = 1; % run 4 on
fprintf('Running for subject %i, run% i, day %i\n', subjectNum,subjectRun,subjectDay);
fprintf('usebuttonbox: %i\nrealtimedata: %i\ndebug: %i\nusepyoutput: %i\n', useButtonBox,realtimeData,debug, usepyoutput);

%% then specify everything else
projectName = 'rtAttenPenn';
Screen('Preference', 'SkipSyncTests', 1);
%Screen('Preference', 'Verbosi1ty', 4)
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
fMRI = 12;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,runNum,subjectDay,useButtonBox,fMRI,realtimeData,debug,usepyoutput)


%%
runNum = 4;
fMRI = 14;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,runNum,subjectDay,useButtonBox,fMRI,realtimeData,debug,usepyoutput)


%%
runNum = 5;
fMRI =16;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,runNum,subjectDay,useButtonBox,fMRI,realtimeData,debug,usepyoutput)

%%
runNum = 6;
fMRI = 18;
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
%% DO THIS AT THE END: COPY ALL FILES INTO SUBJECT FOLDER
copyallfilesforsubject(subjectNum,subjectDay)
