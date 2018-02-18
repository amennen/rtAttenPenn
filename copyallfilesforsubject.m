%% TO DO AT THE END OF THE EXPERIMENT: COPY THIS INTO THE SUBJECT'S FOLDER

% want to copy:
% 1. ExptWrapper_Display
% 2. ExptWrapper_FileProcess
% 3. ProcessMultiday - save for each day so you know the settings

function copyallfilesforsubject(subjectNum,DAYNUM)
dataHeader = ['data/subject' num2str(subjectNum) '/' 'usedscripts' '/'];
if ~exist(dataHeader)
    mkdir(dataHeader)
end
% FIRST EXPT WRAPPERS
filename = ['ExptWrapper_Display_Subject_' num2str(subjectNum) '_Day' num2str(DAYNUM) '.m'];
unix(sprintf('cp ExptWrapper_Display.m %s%s', dataHeader,filename));
filename = ['ExptWrapper_FileProcess_Subject_' num2str(subjectNum) '_Day' num2str(DAYNUM) '.m'];
unix(sprintf('cp ExptWrapper_FileProcess.m %s%s', dataHeader,filename));

% THEN PROCESSING OF MASKS FOR SETTINGS
filename = ['ProcessMaskScript_Subject_' num2str(subjectNum) '_Day' num2str(DAYNUM) '.m'];
if DAYNUM == 1
    % copy the day one script then
    unix(sprintf('cp ProcessMultiday_Day1.m %s%s', dataHeader,filename));
else
    unix(sprintf('cp ProcessMultiday_Day2.m %s%s', dataHeader,filename));
end
end