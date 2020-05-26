% Purpose: easily run display of rt-experiment to interface with cloud web-server
% Author: ACM
% Date: 1/10/20
% STEP ONE: Edit the config file in the rtAttenPenn_cloud path - same config file for everything
toml_file = '/home/amennen/rtAttenPenn_cloud/PennCfg.toml';
% make sure the variables are correct:
% get subjectnumber and day here first!! 
[subjectNum,subjectDay,typeNum,useButtonBox,rtData,debugMode,usePyOutput] = readTomlFile(toml_file);
fprintf('Subject number:\t\t%i\n', subjectNum);
fprintf('****************************************\n')
fprintf('Scanning day number:\t%i\n', subjectDay);
fprintf('****************************************\n')
fprintf('Stimulus type\t\t%i\n', typeNum);
fprintf('****************************************\n')
fprintf('useButtonBox:\t\t%i\n', useButtonBox);
fprintf('****************************************\n')
fprintf('rtData:\t\t%i\n', rtData);
fprintf('****************************************\n')
fprintf('debugMode:\t\t%i\n', debugMode);
fprintf('****************************************\n')
%%
fprintf('IF ANYTHING IS INCORRECT, CHANGE THE PARAMETER VALUES IN %s\n', toml_file);
% STEP TWO: Generate the design files
GenerateExptDesign(toml_file);

%% STEP THREE: run each neurofeedback run
% modify the current run number
response = input('What run do you want to start?\n');
fprintf('Starting run number %i...\n', response);
% check that it's correct
runNumber = response;
RealTimePunisherDisplay_CLOUD(toml_file,runNumber);

%% STEP FOUR: copy used files over (like toml file, etc.) over to that subject's directory
copyallfilesforsubject(subjectNum,subjectDay)
