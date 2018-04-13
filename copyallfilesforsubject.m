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

% COPY CLOUD VERSIONS - JUPYTER NOTEBOOK AND CONFIG FLIE
cloudpath = ['~/rtAtten_cloud/'];
filename = ['rtAtten_jupyter_Subject_' num2str(subjectNum) '_Day' num2str(DAYNUM) '.ipynb'];
unix(sprintf('cp %srtAtten_jupyter.ipynb %s%s', cloudpath,dataHeader,filename));
filename = ['exampleCfg_Subject_' num2str(subjectNum) '_Day' num2str(DAYNUM) '.toml'];
unix(sprintf('cp %sexampleCfg.toml %s%s', cloudpath,dataHeader,filename));

end