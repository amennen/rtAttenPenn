function [fileAvail specificFile] = GetSpecificClassOutputFile(imgDir,fileNum)

fileStr = num2str(fileNum);
specificFile = ['vol_' fileStr '.mat'];

if exist(fullfile(imgDir,specificFile),'file');
    fileAvail = 1;
else
    fileAvail = 0;
end
