function [fileAvail specificFile] = GetSpecificClassOutputFile(imgDir,scanNum,fileNum)

%2 digit scan string
if scanNum<10
    scanStr = ['0' num2str(scanNum)];
else
    scanStr = num2str(scanNum);
end

%3 digit file string
if fileNum <10
    fileStr = ['00' num2str(fileNum)];
elseif fileNum <100
    fileStr = ['0' num2str(fileNum)];
else
    fileStr = num2str(fileNum);
end

specificFile = ['001_0000' scanStr '_000' fileStr '.dcm'];

if exist([imgDir specificFile],'file');
    fileAvail = 1;
else
    fileAvail = 0;
end
