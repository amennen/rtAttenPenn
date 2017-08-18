function [patterns] = RealTimePunisherFileProcess(imgDirHeader,subjectNum,subjectName,matchNum,runNum,fMRI,rtData)
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
    dataHeader = ['data/' num2str(matchNum) '_match'];
    runHeader = [dataHeader '/run' num2str(runNum)];
    classOutputDir = [runHeader '/controlneverseenclassoutput'];
end
fname = findNewestFile(runHeader, fullfile(runHeader, ['patternsdesign_' num2str(runNum) '*.mat']));
load(fname);
imgDir = [imgDirHeader datestr(now,10) datestr(now,5) datestr(now,7) '.' subjectName '.' subjectName '/'];

%%%%%%%%
%DELETE AFTER
%\subjDate = '8-11-17';
%imgDir = [imgDirHeader datestr(subjDate,10) datestr(subjDate,5) datestr(subjDate,7) '.' subjectName '.' subjectName '/'];
%%%%%%%%


%check that the fMRI file directory exists
if rtData
    if ~exist(imgDir,'dir')
        mkdir(imgDir)
        assert(logical(exist(imgDir,'dir')));
        fprintf('fMRI files being read from: %s\n',imgDir);
    end
end
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
cutoff = 112;
%timeOut = TR/2+.25;

zscoreNew = 1;
useHistory = 1;
firstBlockTRs = 64; %total number of TRs to take for standard deviation of last run
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
patterns.raw_sm_filt = nan(nTRs,numel(roiInds));
patterns.raw_sm_filt_z = nan(nTRs,numel(roiInds));
patterns.categoryseparation = NaN(1,nTRs);
patterns.firstTestTR = find(patterns.regressor(1,:)+patterns.regressor(2,:),1,'first') ; %(because took out first 10)

%% Output Files Setup

% open and set-up output file
dataFile = fopen([dataHeader '/fileprocessing.txt'],'a');
fprintf(dataFile,'\n*********************************************\n');
fprintf(dataFile,'* rtAttenPenn v.1.0\n');
fprintf(dataFile,['* Date/Time: ' datestr(now,0) '\n']);
fprintf(dataFile,['* Seed: ' num2str(seed) '\n']);
fprintf(dataFile,['* Subject Number: ' num2str(subjectNum) '\n']);
fprintf(dataFile,['* Subject Name: ' subjectName '\n']);
fprintf(dataFile,['* Run Number: ' num2str(runNum) '\n']);
fprintf(dataFile,['* Real-Time Data: ' num2str(rtData) '\n']);
fprintf(dataFile,'*********************************************\n\n');

% print header to command window
fprintf('\n*********************************************\n');
fprintf('* rtAttenPenn v.1.0\n');
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

fileCounter = firstVolPhase1-1; %file number = # of TR pulses
goodInd = [];
for iTrialPhase1 = 1:(firstVolPhase2-1) % (change ACM 8/10/17: keeping this going past the break-no need to break it into separate steps)
    
    zscoreLen = double(iTrialPhase1);
    zscoreLen1 = double(iTrialPhase1 - 1);
    zscoreConst = 1.0/zscoreLen;
    zscoreConst1 = 1.0/zscoreLen1;
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
    
    %if desired file is recognized, pause for 200ms to complete transfer
    pause(.2);
    
    % if file available, load it
    if (patterns.fileAvail(iTrialPhase1))
        [newVol patterns.timeRead{iTrialPhase1}] = ReadFile([imgDir patterns.newFile{iTrialPhase1}],imgmat,roi); % NTB: only reads top file
        patterns.raw(iTrialPhase1,:) = newVol;  % keep patterns for later training
        
        if (any(isnan(patterns.raw(iTrialPhase1,:)))) && (iTrialPhase1>1)
            patterns.fileload(iTrialPhase1) = 0; %mark that load failed
            indLastValidPattern = find(patterns.fileload,1,'last');
            patterns.raw(iTrialPhase1,:) = patterns.raw(indLastValidPattern,:); %replicate last complete pattern
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

% quick highpass filter!
fprintf(dataFile,'\n*********************************************\n');
fprintf(dataFile,'beginning highpass filter/zscore...\n');
fprintf('\n*********************************************\n');
fprintf('beginning highpassfilter/zscore...\n');
p1 = GetSecs;
i1 = 1;
i2 = firstVolPhase2-1;
patterns.raw_sm_filt(i1:i2,:) = HighPassBetweenRuns(patterns.raw_sm(i1:i2,:),TR,cutoff);
patterns.phase1Mean(1,:) = mean(patterns.raw_sm_filt(i1:i2,:),1);
patterns.phase1Y(1,:) = mean(patterns.raw_sm_filt(i1:i2,:).^2,1);
patterns.phase1Std(1,:) = std(patterns.raw_sm_filt(i1:i2,:),1,1);
patterns.phase1Var(1,:) = patterns.phase1Std(1,:).^2;
patterns.raw_sm_filt_z(i1:i2,:) = (patterns.raw_sm_filt(i1:i2,:) - repmat(patterns.phase1Mean,size(patterns.raw_sm_filt(i1:i2,:),1),1))./repmat(patterns.phase1Std,size(patterns.raw_sm_filt(i1:i2,:),1),1);
p2 = GetSecs;
fprintf(dataFile,sprintf('elapsed time...%.4f seconds\n',p2-p1));
fprintf(sprintf('elapsed time...%.4f seconds\n',p2-p1));

%% testing
fprintf(dataFile,'\n*********************************************\n');
fprintf(dataFile,'beginning model testing...\n');
fprintf('\n*********************************************\n');
fprintf('beginning model testing...\n');

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
        
        pause(.2);
        
        [newVol patterns.timeRead{fileCounter}] = ReadFile([imgDir patterns.newFile{fileCounter}],imgmat,roi);
        patterns.raw(fileCounter,:) = newVol;  % keep patterns for later training
        
        if (any(isnan(patterns.raw(fileCounter,:))))
            patterns.fileload(fileCounter) = 0;
            indLastValidPatterns = find(patterns.fileload,1,'last');
            patterns.raw(fileCounter,:) = patterns.raw(indLastValidPattern,:); %replicate last complete pattern
        else
            patterns.fileload(fileCounter) = 1;
        end
        
        %smooth
        patterns.raw_sm(fileCounter,:) = SmoothRealTime(patterns.raw(fileCounter,:),roiDims,roiInds,FWHM);
        
        %z-score
    else
        indLastValidPatterns = find(patterns.fileload,1,'last');
        patterns.raw_sm_filt(fileCounter,:) = patterns.raw_sm_filt(indLastValidPatterns,:);
    end
    
    
    % detrend
    patterns.raw_sm_filt(fileCounter,:) = HighPassRealTime(patterns.raw_sm(1:fileCounter,:),TR,cutoff);
    
    % only update if the latest file wasn't nan
    if patterns.fileload(fileCounter)
        
        patterns.realtimeMean(1,:) = mean(patterns.raw_sm_filt(1:fileCounter,:),1);
        patterns.realtimeY(1,:) = mean(patterns.raw_sm_filt(1:fileCounter,:).^2,1);
        patterns.realtimeStd(1,:) = std(patterns.raw_sm_filt(1:fileCounter,:),1,1); %flad to use N instead of N-1
        patterns.realtimeVar(1,:) = patterns.realtimeStd(1,:).^2;
        
        
        %record last history
        patterns.realtimeLastMean(1,:) = patterns.realtimeMean(1,:);
        patterns.realtimeLastY(1,:) = patterns.realtimeY(1,:);
        patterns.realtimeLastVar(1,:) = patterns.realtimeVar(1,:);
        %update mean
        patterns.realtimeMean(1,:) = (patterns.realtimeMean(1,:).*zscoreLen1 + patterns.raw_sm_filt(fileCounter,:)).*zscoreConst;
        %update y = E(X^2)
        patterns.realtimeY(1,:) = (patterns.realtimeY(1,:).*zscoreLen1+ patterns.raw_sm_filt(fileCounter,:).^2).*zscoreConst;
        %update var
        if useHistory
            patterns.realtimeVar(1,:) = patterns.realtimeLastVar(1,:) ...
                + patterns.realtimeLastMean(1,:).^2 - patterns.realtimeMean(1,:).^2 ...
                + patterns.realtimeY(1,:) - patterns.realtimeLastY(1,:);
        else
            % update var
            patterns.realtimeVar(1,:) = patterns.realtimeVar(1,:) - patterns.realtimeMean(1,:).^2 ...
                + ((patterns.realtimeMean(1,:).*zscoreLen - patterns.raw_sm_filt(fileCounter,:)).*zscoreConst1).^2 ...
                + (patterns.raw_sm_filt(fileCounter,:).^2 - patterns.realtimeY(1,:)).*zscoreConst1;
        end
    end
    patterns.raw_sm_filt_z(fileCounter,:) = (patterns.raw_sm_filt(fileCounter,:) - patterns.realtimeMean(1,:))./patterns.realtimeStd(1,:);
    
    if rtfeedback
        if any(patterns.regressor(:,fileCounter))
            [patterns.predict(fileCounter),~,~,patterns.activations(:,fileCounter)] = Test_L2_RLR_realtime(trainedModel,patterns.raw_sm_filt_z(fileCounter,:),patterns.regressor(:,fileCounter)); %#ok<NODEF>
            
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

patterns.runStd = std(patterns.raw_sm_filt,[],1); %std dev across all volumes per voxel

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
    trainPats1 = patterns.raw_sm_filt_z(trainIdx1,:); %retrieve the patterns of those indices
    
    trainIdx2 = find(any(patterns.regressor(:,(firstVolPhase2+1):lastVolPhase2),1));
    trainLabels2 = patterns.regressor(:,firstVolPhase2+trainIdx2)'; %find the labels of those indices
    trainPats2 = patterns.raw_sm_filt_z(trainIdx2,:);
elseif runNum == 2
    trainIdx1 = find(any(oldpats.patterns.regressor(:,(firstVolPhase2+1):lastVolPhase2),1));
    trainLabels1 = oldpats.patterns.regressor(:,firstVolPhase2+trainIdx1)'; %find the labels of those indices
    trainPats1 = oldpats.patterns.raw_sm_filt_z(trainIdx1,:);
    
    trainIdx2 = any(patterns.regressor(:,1:lastVolPhase1,1));
    trainLabels2 = patterns.regressor(:,trainIdx2)'; %find the labels of those indices
    trainPats2 = patterns.raw_sm_filt_z(trainIdx2,:); %retrieve the patterns of those indices
else
    trainIdx1 = any(oldpats.patterns.regressor(:,1:lastVolPhase1),1);
    trainLabels1 = oldpats.patterns.regressor(:,trainIdx1)'; %find the labels of those indices
    trainPats1 = oldpats.patterns.raw_sm_filt_z(trainIdx1,:); %retrieve the patterns of those indices
    
    trainIdx2 = any(patterns.regressor(:,1:lastVolPhase1),1);
    trainLabels2 = patterns.regressor(:,trainIdx2)'; %find the labels of those indices
    trainPats2 = patterns.raw_sm_filt_z(trainIdx2,:); %retrieve the patterns of those indices
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
