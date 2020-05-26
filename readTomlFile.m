function [subjectNum,subjectDay,typeNum,useButtonBox,rtData,debugMode,usePyOutput] = readTomlFile(toml_file)
% Purpose of function: read the toml file given and print the parameters to make sure they're correct

addpath(genpath('matlab-toml'));
raw_text = fileread(toml_file);
Cfg = toml.decode(raw_text);
subjectNum = Cfg.session.subjectNum;
subjectDay = Cfg.session.subjectDay;
typeNum = Cfg.session.typeNum;

useButtonBox = Cfg.session.useButtonBox;
rtData = Cfg.session.rtData;
debugMode = Cfg.session.debugMode;
usePyOutput = Cfg.session.usePyOutput;

end
