function [patterns] = RealTimePunisherFileProcess(subjectNum,subjectName,matchNum,runNum,fMRI,rtData)
% function [patterns] = RealTimePunisherFileProcess(subjectNum,subjectName,runNum,fMRI,rtData)
%
% this function describes the file processing procedure for the realtime 
% fMRI attentional training experiment
%
%
% REQUIRED INPUTS:
% - subjectNum:  participant number [any integer]
%                if subjectNum = 0, no information will be saved
% - subjectName: ntblab subject naming convention [MMDDYY#_REALTIME02]
% - runNum:      run number [any integer]
% - fMRI:        whether collecting fMRI data [scannumber if yes/0 if not]
% - rtData:whether data acquired in realtime or previously collected [1/0]
%
% OUTPUTS
% - patterns: elapsed time for each iteration of SVM testing
%
% Written by: Nick Turk-Browne
% Editied by: Megan deBettencourt
% Version: 2.0
% Last modified: 10/14/11

%% check inputs

%check that there is a sufficient number of inputs
if nargin < 6
    error('6 inputs are required: subjectNum, subjectName, matchNum, runNum, fMRI, rtData');
end

if ~isnumeric(subjectNum)
   error('subjectNum must be a number'); 
end

if ~ischar(subjectName)
    error('subjectName must be a string');
end

if ~isnumeric(matchNum)
   error('matchNum must be a number'); 
end

if ~isnumeric(runNum)
    error('runNum must be a number');
end

if ~isnumeric(fMRI)
    error('fMRI must be a number - equal to the next motion-corrected scan number')
end

if (rtData~=1) && (rtData~=0)
    error('rtData must be either 1 (if realtime data acquisition) or 0 (if not)')
end


%% Boilerplate

seed = sum(100*clock); %get random seed
RandStream.setGlobalStream(RandStream('mt19937ar','seed',seed));%set seed

%initialize system time calls
GetSecs;


%% Load or Initialize Real-Time Data & Staircasing Parameters

if matchNum == 0
    dataHeader = ['data/' num2str(subjectNum)];
    runHeader = [dataHeader '/run' num2str(runNum)];
    classOutputDir = [runHeader '/classoutput'];
    
    matchDataHeader = ['data/' num2str(subjectNum) '_match'];
    matchRunHeader = [matchDataHeader '/run' num2str(runNum)]; 
    matchClassOutputDir = [matchRunHeader '/classoutput'];
else
    dataHeader = ['data/' num2str(subjectNum) '_match'];
    runHeader = [dataHeader '/run' num2str(runNum)];
    classOutputDir = [runHeader '/controlneverseenclassoutput'];
end
fn = ls([runHeader '/patternsdesign_' num2str(runNum) '_*']);
load(deblank(fn));
    
if rtData
    %imgDir = ['/rt_test/20120604.' subjectName '.' subjectName '/'];
    imgDir = ['/mnt/rtexport/RTexport_Current/' datestr(now,10) datestr(now,5) datestr(now,7) '.' subjectName '.' subjectName '/'];
else
    %dataHeader = ['data/' num2str(subjectNum)];
    imgDir = ['/Volumes/ntb/projects/punisher02/subjects/' subjectName '/data/dicom/'];
    %imgDir = ['/Volumes/KINGSTON/dicomdata/20121025.1025121_punisher02.1025121_punisher02/'];
end

    
%check that the fMRI file directory exists
assert(logical(exist(imgDir,'dir')));
fprintf('fMRI files being read from: %s\n',imgDir);
    
%check that the fMRI dicom files do NOT exist
if rtData
    %2 digit scan string
    if fMRI<10
        scanStr = ['0' num2str(fMRI)];
    else
        scanStr = num2str(fMRI);
    end
    
    %3 digit file string
    tempFileNum = 1;
    fileStr = ['00' num2str(tempFileNum)];
    
    specificFile = ['001_0000' scanStr '_000' fileStr '.dcm'];
    
    if exist([imgDir specificFile],'file');
        reply = input('Files with this scan number already exist. Do you want to continue? Y/N [N]: ', 's');
        if isempty(reply)
            reply = 'N';
        end
        if ~(strcmp(reply,'Y') || strcmp(reply,'y'))
            return
        end
    end
end
    
%load previous patterns
if runNum>1
    patsfn = ls([dataHeader '/patternsdata_' num2str(runNum-1) '_*']);
    oldpats = load(deblank(patsfn));
    
    modelfn = ls([dataHeader '/trainedModel_' num2str(runNum-1) '_*']);
    load(deblank(modelfn),'trainedModel');
end


%% Experimental Parameters

%scanning parameters
imgmat = 64; % the fMRI image matrix size
temp = load([dataHeader '/mask_' num2str(subjectNum)]);
roi = temp.mask;
assert(exist('roi','var')==1);
roiDims = size(roi);
roiInds = find(roi);

%pre-processing parameters
FWHM = 5;
%timeOut = TR/2+.25;


%% Block Sequence

firstVolPhase1 = find(patterns.block==1,1,'first'); %#ok<NODEF>
lastVolPhase1 = find(patterns.block==nBlocksPerPhase,1,'last'); 
nVolsPhase1 = lastVolPhase1 - firstVolPhase1+1;

lastVolPhase2 = find(patterns.type~=0,1,'last'); 
nVolsPhase2 = lastVolPhase2 - firstVolPhase2;

patterns.fileAvail = zeros(1,nTRs);
patterns.fileNum = NaN(1,nTRs);
patterns.newFile = cell(1,nTRs);
patterns.timeRead = cell(1,nTRs);
patterns.fileload = NaN(1,nTRs);
patterns.raw = nan(nTRs,numel(roiInds));
patterns.raw_sm = nan(nTRs,numel(roiInds));
patterns.raw_sm_z = nan(nTRs,numel(roiInds));
patterns.categoryseparation = NaN(1,nTRs);

%% Output Files Setup

% open and set-up output file
dataFile = fopen([dataHeader '/fileprocessing.txt'],'a');
fprintf(dataFile,'\n*********************************************\n');
fprintf(dataFile,'* Punisher Experiment v.2.0\n');
fprintf(dataFile,['* Date/Time: ' datestr(now,0) '\n']);
fprintf(dataFile,['* Seed: ' num2str(seed) '\n']);
fprintf(dataFile,['* Subject Number: ' num2str(subjectNum) '\n']);
fprintf(dataFile,['* Subject Name: ' subjectName '\n']);
fprintf(dataFile,['* Run Number: ' num2str(runNum) '\n']);
fprintf(dataFile,['* Real-Time Data: ' num2str(rtData) '\n']);
fprintf(dataFile,'*********************************************\n\n');
    
% print header to command window
fprintf('\n*********************************************\n');
fprintf('* Punisher Experiment v.2.0\n');
fprintf(['* Date/Time: ' datestr(now,0) '\n']);
fprintf(['* Seed: ' num2str(seed) '\n']);
fprintf(['* Subject Number: ' num2str(subjectNum) '\n']);
fprintf(['* Subject Name: ' subjectName '\n']);
fprintf(['* Run Number: ' num2str(runNum) '\n']);
fprintf(dataFile,['* Real-Time Data: ' num2str(rtData) '\n']);
fprintf('*********************************************\n\n');


%% Start Experiment

% prepare for trial sequence
fprintf(dataFile,'run\tblock\ttrial\tbltyp\tblcat\tstim\tfilenum\tloaded\toutput\tavg\n');
fprintf('run\tblock\ttrial\tbltyp\tblcat\tstim\tfilenum\tloaded\toutput\tavg\n');


%% acquiring files

ffileCounter = firstVolPhase1-1; %file number = # of TR pulses

for iTrialPhase1 = 1:nVolsPhase1
    
    %increase the count of TR pulses
    fileCounter = fileCounter+1;
    
    %save this into the structure
    patterns.fileNum(iTrialPhase1) =  fileCounter+disdaqs/TR;
    
    %check for new files from the scanner
    patterns.fileAvail(iTrialPhase1) = 0;
    
    %check for new files from the scanner
    while (patterns.fileAvail(iTrialPhase1)==0)
        [patterns.fileAvail(iTrialPhase1) patterns.newFile{iTrialPhase1}] = GetSpecificFMRIFile(imgDir,fMRI,patterns.fileNum(iTrialPhase1));
    end
    
    %if desired file is recognized, pause for 100ms to complete transfer
    pause(.2);
    
    % if file available, load it
    if (patterns.fileAvail(iTrialPhase1))
        [newVol patterns.timeRead{iTrialPhase1}] = ReadFile([imgDir patterns.newFile{iTrialPhase1}],imgmat,roi); % NTB: only reads top file
        patterns.raw(iTrialPhase1,:) = newVol;  % keep patterns for later training
        
        if (any(isnan(patterns.raw(iTrialPhase1,:)))) && (iTrialPhase1>1)
            patterns.fileload(iTrialPhase1) = 0; %mark that load failed
            patterns.raw(iTrialPhase1,:) = patterns.raw(iTrialPhase1-1,:); %replicate last complete pattern
        else
            patterns.fileload(iTrialPhase1) = 1;
        end
        
    end
    
    %smooth files
    patterns.raw_sm(iTrialPhase1,:) = SmoothRealTime(patterns.raw(iTrialPhase1,:),roiDims,roiInds,FWHM);
    
    % print trial results
    fprintf(dataFile,'%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%.3f\t%.3f\n',runNum,patterns.block(iTrialPhase1),iTrialPhase1,patterns.type(iTrialPhase1),patterns.attCateg(iTrialPhase1),patterns.stim(iTrialPhase1),patterns.fileNum(iTrialPhase1),patterns.fileAvail(iTrialPhase1),NaN,NaN);
    fprintf('%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%.3f\t%.3f\n',runNum,patterns.block(iTrialPhase1),iTrialPhase1,patterns.type(iTrialPhase1),patterns.attCateg(iTrialPhase1),patterns.stim(iTrialPhase1),patterns.fileNum(iTrialPhase1),patterns.fileAvail(iTrialPhase1),NaN,NaN);
    
end % Phase1 loop

%% pre-process the files that were obtained during training

%print pre-processing results
fprintf(dataFile,'loading patterns that were acquired during model training...\n');
fprintf('loading patterns that were acquired during model training...\n');

fprintf(dataFile,'files:\t%d\t%d\n',patterns.fileNum(nVolsPhase1)+1,patterns.fileNum(firstVolPhase2)-1);
fprintf('files:\t%d\t%d\n',patterns.fileNum(nVolsPhase1)+1,patterns.fileNum(firstVolPhase2)-1);

for iTrialTraining = (nVolsPhase1+1):(firstVolPhase2-1)
    
    fileCounter = fileCounter+1;
    
    patterns.fileNum(fileCounter) = fileCounter+disdaqs/TR;
    
    %check for new files from the scanner
    while (patterns.fileAvail(fileCounter)==0)
        [patterns.fileAvail(fileCounter) patterns.newFile{fileCounter}] = GetSpecificFMRIFile(imgDir,fMRI,patterns.fileNum(fileCounter));
    end
    
    fprintf(dataFile,'%d...\t',patterns.fileNum(fileCounter));
    fprintf('%d...\t',patterns.fileNum(fileCounter));
    
    %if desired file is recognized, pause for 100ms to complete transfer
    pause(.1);
    
    % if file available, load it
    if (patterns.fileAvail(fileCounter))
        [newVol patterns.timeRead{fileCounter}] = ReadFile([imgDir patterns.newFile{fileCounter}],imgmat,roi); % NTB: only reads top file
        patterns.raw(fileCounter,:) = newVol;  % keep patterns for later training
        
        if (any(isnan(patterns.raw(fileCounter,:))))
            patterns.fileload(fileCounter) = 0; %mark that load failed
            patterns.raw(fileCounter,:) = patterns.raw(fileCounter-1,:); %replicate last complete pattern
        else
            patterns.fileload(fileCounter) = 1;
        end
        
    end
    
    %smooth files
    patterns.raw_sm(fileCounter,:) = SmoothRealTime(patterns.raw(fileCounter,:),roiDims,roiInds,FWHM);
end

fprintf(dataFile,'\n');
fprintf('\n');

%z-score
patterns.trainingAndFixDataMean = mean(patterns.raw_sm(1:fileCounter,:),1);  %mean across all volumes per voxel
patterns.trainingAndFixDataStd = std(patterns.raw_sm(1:fileCounter,:),[],1); %std dev across all volumes per voxel

patterns.raw_sm_z(1:fileCounter,:) = (patterns.raw_sm(1:fileCounter,:) - repmat(patterns.trainingAndFixDataMean,fileCounter,1))./repmat(patterns.trainingAndFixDataStd,fileCounter,1);

if rtData
    save([classOutputDir '/trainingcomplete.mat'],'firstVolPhase2');
end

fprintf(dataFile,'\n*********************************************\n');
fprintf(dataFile,'beginning model testing...\n');
fprintf('\n*********************************************\n');
fprintf('beginning model testing...\n');

%% testing

%% testing

% prepare for trial sequence
fprintf(dataFile,'run\tblock\ttrial\tbltyp\tblcat\tstim\tfilenum\tloaded\toutput\tavg\n');
fprintf('run\tblock\ttrial\tbltyp\tblcat\tstim\tfilenum\tloaded\toutput\tavg\n');

for iTrialPhase2=1:(nVolsPhase2+1)
    
    fileCounter = fileCounter+1;
    
    patterns.fileNum(fileCounter) = fileCounter+disdaqs/TR;
     
    %check for new files from the scanner
    patterns.fileAvail(fileCounter) = 0;
    while (patterns.fileAvail(fileCounter)==0)
            [patterns.fileAvail(fileCounter) patterns.newFile{fileCounter}] = GetSpecificFMRIFile(imgDir,fMRI,patterns.fileNum(fileCounter));          
    end
    
    % if file available, perform preprocessing and test classifier
    if (patterns.fileAvail(fileCounter))
        
        pause(.1);
        
        [newVol patterns.timeRead{fileCounter}] = ReadFile([imgDir patterns.newFile{fileCounter}],imgmat,roi);
        patterns.raw(fileCounter,:) = newVol;  % keep patterns for later training
        
        if (any(isnan(patterns.raw(fileCounter,:))))
            patterns.fileload(fileCounter) = 0;
            patterns.raw(fileCounter,:) = patterns.raw(fileCounter-1,:); %replicate last complete pattern
        else
            patterns.fileload(fileCounter) = 1;
        end
        
        %smooth
        patterns.raw_sm(fileCounter,:) = SmoothRealTime(patterns.raw(fileCounter,:),roiDims,roiInds,FWHM);
        
        %z-score
        patterns.raw_sm_z(fileCounter,:) = (patterns.raw_sm(fileCounter,:) - patterns.trainingAndFixDataMean)./patterns.trainingAndFixDataStd;
    else
        indLastValidPatterns = find(~isnan(patterns.raw_sm_z(:,1)),1,'last');
        patterns.raw_sm_z(fileCounter,:) = patterns.raw_sm_z(indLastValidPatterns,:);
    end
    
    if rtfeedback
        if any(patterns.regressor(:,fileCounter))
            [patterns.predict(fileCounter),~,~,patterns.activations(:,fileCounter)] = Test_L2_RLR_realtime(trainedModel,patterns.raw_sm_z(fileCounter,:),patterns.regressor(:,fileCounter)); %#ok<NODEF>
            
            categ = find(patterns.regressor(:,fileCounter));
            otherCateg = mod(categ,2)+1;
            patterns.categoryseparation(fileCounter) = patterns.activations(categ,fileCounter)-patterns.activations(otherCateg,fileCounter);
            
            classOutput = patterns.categoryseparation(fileCounter); %#ok<NASGU>
            save([classOutputDir '/vol_' num2str(patterns.fileNum(fileCounter))],'classOutput');
        else
            patterns.categoryseparation(fileCounter) = NaN;
            
            classOutput = patterns.categoryseparation(fileCounter); %#ok<NASGU>
            
            save([classOutputDir '/vol_' num2str(patterns.fileNum(fileCounter))],'classOutput');
        end
    else
        patterns.categoryseparation(fileCounter) = NaN;
    end
    
    % print trial results
    fprintf(dataFile,'%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%.3f\t%.3f\n',runNum,patterns.block(fileCounter),iTrialPhase2,patterns.type(fileCounter),patterns.attCateg(fileCounter),patterns.stim(fileCounter),patterns.fileNum(fileCounter),patterns.fileAvail(fileCounter),patterns.categoryseparation(fileCounter),nanmean(patterns.categoryseparation(firstVolPhase2:fileCounter)));
    fprintf('%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%.3f\t%.3f\n',runNum,patterns.block(fileCounter),iTrialPhase2,patterns.type(fileCounter),patterns.attCateg(fileCounter),patterns.stim(fileCounter),patterns.fileNum(fileCounter),patterns.fileAvail(fileCounter),patterns.categoryseparation(fileCounter),nanmean(patterns.categoryseparation(firstVolPhase2:fileCounter)));

    
end % Phase 2 loop

%% training

trainStart = tic; %start timing 

%print training results
fprintf(dataFile,'\n*********************************************\n');
fprintf(dataFile,'beginning model training...\n');
fprintf('\n*********************************************\n');
fprintf('beginning model training...\n');
    
%model training
if runNum == 1
    trainIdx1 = any(patterns.regressor(:,1:lastVolPhase1),1);
    trainLabels1 = patterns.regressor(:,trainIdx1)'; %find the labels of those indices
    trainPats1 = patterns.raw_sm_z(trainIdx1,:); %retrieve the patterns of those indices
    
    trainIdx2 = find(any(patterns.regressor(:,(firstVolPhase2+1):lastVolPhase2),1));
    trainLabels2 = patterns.regressor(:,firstVolPhase2+trainIdx2)'; %find the labels of those indices
    trainPats2_notz = patterns.raw_sm(firstVolPhase2+trainIdx2,:); %retrieve the patterns of those indices
    trainPats2mean = mean(trainPats2_notz,1);
    trainPats2std = std(trainPats2_notz,[],1);
    trainPats2 = (trainPats2_notz - repmat(trainPats2mean,numel(trainIdx2),1))./repmat(trainPats2std,numel(trainIdx2),1);
elseif runNum == 2
    trainIdx1 = find(any(oldpats.patterns.regressor(:,(firstVolPhase2+1):lastVolPhase2),1));
    trainLabels1 = oldpats.patterns.regressor(:,firstVolPhase2+trainIdx1)'; %find the labels of those indices
    trainPats1_notz = oldpats.patterns.raw_sm(firstVolPhase2+trainIdx1,:); %retrieve the patterns of those indices
    trainPats1mean = mean(trainPats1_notz,1);
    trainPats1std = std(trainPats1_notz,[],1);
    trainPats1 = (trainPats1_notz - repmat(trainPats1mean,numel(trainIdx1),1))./repmat(trainPats1std,numel(trainIdx1),1);
    
    trainIdx2 = any(patterns.regressor(:,1:lastVolPhase1,1));
    trainLabels2 = patterns.regressor(:,trainIdx2)'; %find the labels of those indices
    trainPats2 = patterns.raw_sm_z(trainIdx2,:); %retrieve the patterns of those indices
else
    trainIdx1 = any(oldpats.patterns.regressor(:,1:lastVolPhase1),1);
    trainLabels1 = oldpats.patterns.regressor(:,trainIdx1)'; %find the labels of those indices
    trainPats1 = oldpats.patterns.raw_sm_z(trainIdx1,:); %retrieve the patterns of those indices
    
    trainIdx2 = any(patterns.regressor(:,1:lastVolPhase1),1);
    trainLabels2 = patterns.regressor(:,trainIdx2)'; %find the labels of those indices
    trainPats2 = patterns.raw_sm_z(trainIdx2,:); %retrieve the patterns of those indices
end

trainPats = [trainPats1;trainPats2];
trainLabels = [trainLabels1;trainLabels2];

trainedModel = classifierLogisticRegression(trainPats,trainLabels); %train the model

trainingOnlyTime = toc(trainStart);  %end timing

%print training timing and results

fprintf(dataFile,'model training time: \t%.3f\n',trainingOnlyTime);
fprintf('model training time: \t%.3f\n',trainingOnlyTime);
if isfield(trainedModel,'biases')
    fprintf(dataFile,'model biases: \t%.3f\t%.3f\n',trainedModel.biases(1),trainedModel.biases(2));
    fprintf('model biases: \t%.3f\t%.3f\n',trainedModel.biases(1),trainedModel.biases(2));
end




%%

save([dataHeader '/patternsdata_' num2str(runNum) '_' datestr(now,30)],'patterns');
save([dataHeader '/trainedModel_' num2str(runNum) '_' datestr(now,30)],'trainedModel','trainPats','trainLabels');

%MdB Check This!!! 
if rtfeedback && runNum>1 && matchNum == 0
    unix(['cp ' classOutputDir '/vol_* ' matchClassOutputDir]);
end

% clean up and go home
fclose('all');
end
