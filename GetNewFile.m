function [fileAvail newFile oldFiles] = GetNewFile(dirName,oldFiles)

% read directory
dirList = dir(dirName);

% skip hidden files
while (strcmp(dirList(1).name(1),'.'))
    dirList = dirList(2:end);
end

% compared against used list
dirList = struct2cell(dirList);
dirList = cell(dirList(1,:));
newFile = dirList(~ismember(dirList,oldFiles));
if (~isempty(newFile))
    tempNew = newFile{end}; % FIX THIS
    newFile = cell(1,1);
    newFile{1} = tempNew;
end

% check number available
assert(length(newFile)<=1,'Wrong number of new files!');
fileAvail = length(newFile);
oldFiles = dirList;
