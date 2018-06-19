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
filename = ['BehavExptWrapper_Subject_' num2str(subjectNum) '_Day' num2str(DAYNUM) '.m'];
unix(sprintf('cp ExptWrapper.m %s%s', dataHeader,filename));

end