exptDir = '~/code/rtAttention/';
cd(exptDir)
subjectNum = 1;
subjectName = 'rtAttenUP_1;
matchNum = 0;
useButtonBox=1;
realtimeData = 1;
debug=0;
KbName('UnifyKeyNames')
addpath(genpath('/opt/psychtoolbox/'))

%%
runNum=1;
fMRI = 8;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)


%%
runNum=2;
fMRI = 10;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)


%%
runNum = 3;
fMRI = 12;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)


%%
runNum = 4;
fMRI = 14;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)


%%
runNum = 5;
fMRI = 16;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)

%%
runNum = 6;
fMRI = 18;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)


%%

runNum = 7;
fMRI = 20;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)


%%

runNum = 8;
fMRI = 22;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)


%%

runNum = 9;
fMRI = 24;
[blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,realtimeData,debug)
