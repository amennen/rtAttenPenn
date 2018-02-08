function [runnums,filenames] = GrabFileInfo(datadir,datastr)
%function [runnums,filenames] = GrabFileInfo(datadir,datastr)
%
%
% 
% MdB 3/2012

%change to the subject's data directory
cd(datadir)

%general string - with underscore, star appended
genstr = [datastr '_*'];

%list all files
if strncmp(computer,'MACI',4)
    datalist = ls('-m',genstr);
else
    datalist = ls('--color=no','-m',genstr);
end

%indices of underscores (located around run number)
indUnderscores = strfind(datalist,'_');

%find all runs
tempRuns = nan(1,numel(indUnderscores)/2);
for i = 1:(numel(indUnderscores)/2)
    tempRuns(i) = str2double(datalist((indUnderscores((2*i-1))+1):(indUnderscores(2*i)-1)));
end

%sort run numbers
[runnums,indsort] = sort(tempRuns);

%indices of commas (located between run numbers)
indCommas = strfind(datalist,',');

%find all file names
tempfilenames = cell(1,numel(indCommas)+1);
for i = 1:(numel(indCommas)+1)
   if i==1
       tempfilenames{i} = datalist(1:(indCommas(i)-1));
   elseif i > (numel(indCommas))
       tempfilenames{i} = deblank(datalist((indCommas(end)+2):end));
   else
       tempfilenames{i} = deblank(datalist((indCommas(i-1)+2):(indCommas(i)-1)));
   end
   
   if isspace(tempfilenames{i}(1))
       tempfilenames{i} = tempfilenames{i}(2:end);
   end
end

%sort file names
for i = 1:numel(indsort)
    filenames(i) = tempfilenames(indsort(i));
end