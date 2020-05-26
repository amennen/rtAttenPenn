%% TO DO AT THE END OF THE EXPERIMENT: COPY THIS INTO THE SUBJECT'S FOLDER

% want to copy:
% 1. ExptWrapper_CLOUD - version of experiment wrapper used
% 2. RealTimePunisherDisplay_CLOUD - display settings
% 3. PennCfg.toml - config file with all the settings

function copyallfilesforsubject(subjectNum,DAYNUM)
dataHeader = ['data/subject' num2str(subjectNum) '/' 'usedscripts' '/'];
if ~exist(dataHeader)
    mkdir(dataHeader)
end
% FIRST EXPT WRAPPERS
filename = ['ExptWrapper_CLOUD_Subject_' num2str(subjectNum) '_Day' num2str(DAYNUM) '.m'];
unix(sprintf('cp ExptWrapper_CLOUD.m %s%s', dataHeader,filename));
filename = ['RealTimePunisherDisplay_CLOUD_Subject_' num2str(subjectNum) '_Day' num2str(DAYNUM) '.m'];
unix(sprintf('cp RealTimePunisherDisplay_CLOUD.m %s%s', dataHeader,filename));

% COPY CLOUD CONFIG FLIE
cloudpath = ['~/rtAttenPenn_cloud/'];
unix(sprintf('cp %sPennCfg.toml %sPennCfg_Day%i.toml', cloudpath,dataHeader,DAYNUM));
% make an extra copy in that integer day to make things less annoying
unix(sprintf('cp %sPennCfg.toml %sPennCfg_Day%i.toml', cloudpath,dataHeader,floor(DAYNUM)));
fprintf('DONE!!!!')

end
