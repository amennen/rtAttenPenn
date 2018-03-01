function [fileAvail specificFile] = GetSpecificClassOutputFile(imgDir,fileNum,usepython)

fileStr = num2str(fileNum);
if ~usepython
    specificFile = ['vol_' fileStr '.mat'];
else
    specificFile = ['vol_' fileStr '_py.txt'];
end
if exist(fullfile(imgDir,specificFile),'file');
    fileAvail = 1;
else
    fileAvail = 0;
end
