function [] = GenerateExptDesign(toml_file)
%Display_Cfg;
addpath(genpath('matlab-toml'));
raw_text = fileread(toml_file);
Cfg = toml.decode(raw_text);
subjectNum = Cfg.session.subjectNum;
subjectDay = Cfg.session.subjectDay;
subjectDayInt = floor(subjectDay); % this will get the actual day, no matter how many repeated times
typeNum = Cfg.session.typeNum;
%%%%%%% LOAD CONFIGURATIONS FROM TOML FILE
KbName('UnifyKeyNames');
addpath(genpath('/opt/psychtoolbox/'))
%% Generate expt sequence
if subjectDayInt == 1
    nRuns = 7;
elseif subjectDayInt == 2
    nRuns = 9;
elseif subjectDayInt == 3
    nRuns = 8;
end

for runNum = 1:nRuns
    if runNum == 1
        rtfeedback = 0;
    else
        rtfeedback = 1;
    end
    [blockData patterns] = RealTimePunisherExptSequence_CLOUD(subjectNum,runNum,rtfeedback,typeNum,subjectDay);
end
end
