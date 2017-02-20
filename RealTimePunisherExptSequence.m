function [blockData patterns] = RealTimePunisherExptSequence(subjectNum,subjectName,runNum,rtfeedback,negdist)
% function [testTiming blockData] = RealTimePunisherExptOutline(subjectNum,subjectName,runNum)
%
% Face/house attention experiment with real-time classifier feedback
%
%
% REQUIRED INPUTS:
% - subjectNum:  participant number [any integer]
%                if subjectNum = 0, no information will be saved
% - subjectName: ntblab subject naming convention [MMDDYY#_REALTIME02]
% - runNum:      run number [any integer]
%
% OUTPUTS
% - testTiming: elapsed time for each iteration of SVM testing
% - patterns:   ?????
%
% Written by: Megan deBettencourt
% Version: 1.0
% Last modified: Feb 2012

%% check inputs

%check that there is a sufficient number of inputs
if nargin < 4
    error('3 inputs are required: subjectNum, subjectName, runNum');
end

if ~isnumeric(subjectNum)
   error('subjectNum must be a number'); 
end

if ~ischar(subjectName)
    error('subjectName must be a string');
end

if ~isnumeric(runNum)
    error('runNum must be a number');
end

if (rtfeedback ~= 0) && (rtfeedback ~= 1)
    error('rtfeedback must be either 0 or 1');
end

%% Boilerplate

seed = sum(100*clock); %get random seed
RandStream.setGlobalStream(RandStream('mt19937ar','seed',seed));%set seed
% ACM: took out the if statement on 2/13
%if strcmp(computer,'MACI');
    dataHeader = ['data/' num2str(subjectNum)];
    runHeader = [dataHeader '/run' num2str(runNum)];
    classOutputDir = [runHeader '/classoutput'];
    
    matchDataHeader = ['data/' num2str(subjectNum) '_match'];
    matchRunHeader = [matchDataHeader '/run' num2str(runNum)];
    matchClassOutputDir = [matchRunHeader '/classoutput'];
    matchNeverSeenClassOutputDir = [matchRunHeader '/controlneverseenclassoutput'];
%else
%    error('this code is only written to run on 32 bit macs, not %s\n',computer);
%end


%% create subject folder

%somehow assert that subject/run combo has not already been run!

if (~isdir(dataHeader))
    mkdir(dataHeader);
end

if (~isdir(runHeader))
    mkdir(runHeader);
end

if (~isdir(classOutputDir))
    mkdir(classOutputDir);
end
    
if (~isdir(matchDataHeader))
    mkdir(matchDataHeader);
end

if (~isdir(matchRunHeader))
    mkdir(matchRunHeader);
end

if (~isdir(matchClassOutputDir))
    mkdir(matchClassOutputDir);
end

if (~isdir(matchNeverSeenClassOutputDir))
    mkdir(matchNeverSeenClassOutputDir);
end

%% Experimental Parameters

%scanning parameters
disdaqs = 6;        %#ok<NASGU> % [secs] # seconds to drop at the beginning of run
TR = 2;             %#ok<NASGU> % [secs] # seconds per volume
nTrialsPerTR = 2;   % [trials]#trials per TR
labelsShift = 2;    % [TRs]  # volumes to shift label

%experimental design
instructLen = 1;    % [TRs]  # TRs to dedicate to instructions
IBI = 2;            % [TRs]  # TRs to dedicate to rest between blocks
nTRs = 230;         % [TRs]  # TRs per epi sequence 

%trial phases (phase 1 & 2)
nTrialsPerBlock = 50; % [trials]#trials per block
nBlocksPerPhase = 4;  % [blocks]#blocks per phase

%fixation
nTRsFix = IBI*2;       % [TRs]  # TRs to dedicate to training the model

STABLE = 1;         % numerical designation of the block type stable
RTFEED = 2;         % numerical designation of the block type feedback

%experimental order of block types
if (rtfeedback == 1)
    typeOrder = [RTFEED*ones(1,nBlocksPerPhase) RTFEED*ones(1,nBlocksPerPhase)];
elseif (rtfeedback == 0)
    typeOrder = [STABLE*ones(1,nBlocksPerPhase) STABLE*ones(1,nBlocksPerPhase)];
end

%numerically designate the block categories
nCategs = 2;      
SCENE = 1;
FACE = 2;

%numerically designate the subcategories 
nSubCategs = 6;     % in total, across all categorires
INDOOR = 1;         % scenes
OUTDOOR = 2;        % scenes
MALE = 3;           % faces
FEMALE = 4;         % faces
MALESAD = 5;
FEMALESAD = 6;


%experimental design
goCategPercent = .9;% prevalence of category with go response
nNoGoTrials = ceil(nTrialsPerBlock*(1-goCategPercent));    % min number of no-go trials per block

%% Response Mapping and Counterbalancing

% skyra: use current design button box (keys 1,2,3,4)
LEFT = KbName('1!');

% counterbalancing response mapping based on subject assignment
% correctResp spells out the responses for {INDOOR,OUTDOOR,MALE,FEMALE}
respMap = mod(subjectNum-1,4)+1;
switch (respMap)
    case 1
        goSubCategs = [INDOOR MALE];
        nogoSubCategs = [OUTDOOR FEMALE];
        correctResp = {LEFT,NaN,LEFT,NaN};
    case 2
        goSubCategs = [OUTDOOR FEMALE];
        nogoSubCategs = [INDOOR MALE];
        correctResp = {NaN,LEFT,NaN,LEFT};
    case 3
        goSubCategs = [OUTDOOR MALE];
        nogoSubCategs = [INDOOR FEMALE];
        correctResp = {NaN,LEFT,LEFT,NaN};
    case 4
        goSubCategs = [INDOOR FEMALE];
        nogoSubCategs = [OUTDOOR MALE];
        correctResp = {LEFT,NaN,NaN,LEFT};
    otherwise
        error('Impossible response mapping!');
end

for i = 1:nCategs
    randSampAttCategList(i,:) = [goSubCategs(i)*ones(1,goCategPercent*10) nogoSubCategs(i)]; %#ok<AGROW>
    randSampInattCategList(i,:) = [goSubCategs(i)*ones(1,goCategPercent*10) nogoSubCategs(i)]; %#ok<AGROW>
end


%% Load Images

cd images;
for categ=1:nSubCategs
    
    % move into the right folder
    if (categ == INDOOR)
        cd indoor;
    elseif (categ == OUTDOOR)
        cd outdoor;
    elseif (categ == MALE)
        cd male_neut;
    elseif (categ == FEMALE)
        cd female_neut;
    elseif (categ == MALESAD)
        cd male_sad;
    elseif (categ == FEMALESAD)
        cd female_sad;
    else
        error('Impossible category!');
    end
    
    % get filenames
    dirList{categ} = dir; %#ok<AGROW>
    dirList{categ} = dirList{categ}(3:end); %#ok<AGROW>  skip . & ..
    if (~isempty(dirList{categ}))
        if (strcmp(dirList{categ}(1).name,'.DS_Store')==1)
            dirList{categ} = dirList{categ}(2:end); %#ok<AGROW>
        end
        
        if (strcmp(dirList{categ}(end).name,'Thumbs.db')==1)
            dirList{categ} = dirList{categ}(1:(end-1)); %#ok<AGROW>
        end
        
        numImages(categ) = length(dirList{categ}); %#ok<AGROW>
        
        if (numImages(categ)>0)
            
            % get images
            for img=1:numImages(categ)
               
                % read images
                images{categ,img} = imread(dirList{categ}(img).name); %#ok<AGROW>
                tempFFT = fft2(images{categ,img});
                imagePower{categ,img} = abs(tempFFT); %#ok<NASGU,AGROW>
                imagePhase{categ,img} = angle(tempFFT); %#ok<NASGU,AGROW>
            end
            
            % randomize order of images in each run
            imageShuffle{categ} = randperm(numImages(categ)); %#ok<AGROW>
            cd ..;
        end
    else
        error('Need at least one image per directory!');
    end
end
cd ..;


%% Generate Trial and Block Sequences

% counterbalance block order across runs and subjects
if negdist
    categOrderPhase1 = [SCENE SCENE SCENE SCENE];
    categOrderPhase2 = [SCENE SCENE SCENE SCENE];
else
    if (mod(subjectNum,2)==1)
        if (mod(runNum,2)==1)
            blockSequencePhase1 = [SCENE FACE FACE SCENE];
            categOrderPhase1 = repmat(blockSequencePhase1,1,nBlocksPerPhase/numel(blockSequencePhase1));
            
            blockSequencePhase2 = [FACE SCENE SCENE FACE];
            categOrderPhase2 = repmat(blockSequencePhase2,1,nBlocksPerPhase/numel(blockSequencePhase2));
        else
            blockSequencePhase1 = [FACE SCENE SCENE FACE];
            categOrderPhase1 = repmat(blockSequencePhase1,1,nBlocksPerPhase/numel(blockSequencePhase1));
            
            blockSequencePhase2 = [SCENE FACE FACE SCENE];
            categOrderPhase2 = repmat(blockSequencePhase2,1,nBlocksPerPhase/numel(blockSequencePhase2));
        end
    else
        if (mod(runNum,2)==1)
            blockSequencePhase1 = [FACE SCENE SCENE FACE];
            categOrderPhase1 = repmat(blockSequencePhase1,1,nBlocksPerPhase/numel(blockSequencePhase1));
            
            blockSequencePhase2 = [SCENE FACE FACE SCENE];
            categOrderPhase2 = repmat(blockSequencePhase2,1,nBlocksPerPhase/numel(blockSequencePhase2));
        else
            blockSequencePhase1 = [SCENE FACE FACE SCENE];
            categOrderPhase1 = repmat(blockSequencePhase1,1,nBlocksPerPhase/numel(blockSequencePhase1));
            
            blockSequencePhase2 = [FACE SCENE SCENE FACE];
            categOrderPhase2 = repmat(blockSequencePhase2,1,nBlocksPerPhase/numel(blockSequencePhase2));
        end
    end
end

attCategOrder = [categOrderPhase1 categOrderPhase2];
inattCategOrder = (attCategOrder==1)+1;
numBlocks = numel(attCategOrder);

categCounter = zeros(1,nSubCategs);


%% set up block data structure

trialCounter = 0;
TRCounter = 0;

for iBlock=1:numBlocks
    
    % set up block data structure
    blockData(iBlock).block = iBlock; %#ok<AGROW>
    blockData(iBlock).type = typeOrder(iBlock); %#ok<AGROW>
    blockData(iBlock).attCateg = attCategOrder(iBlock); %#ok<AGROW>
    blockData(iBlock).inattCateg = inattCategOrder(iBlock); %#ok<AGROW>
    blockData(iBlock).trialsPerBlock = nTrialsPerBlock; %#ok<AGROW>
    blockData(iBlock).trial = 1:blockData(iBlock).trialsPerBlock; %#ok<AGROW>
    blockData(iBlock).trialLabel = repmat(blockData(iBlock).attCateg,1,blockData(iBlock).trialsPerBlock); %#ok<AGROW>
    blockData(iBlock).trialCount = nan(1,blockData(iBlock).trialsPerBlock); %#ok<AGROW>
    blockData(iBlock).actualblockonset = nan; %#ok<AGROW>
    blockData(iBlock).plannedinstructonset = nan; %#ok<AGROW>
    blockData(iBlock).actualinstructonset = nan; %#ok<AGROW>
    blockData(iBlock).plannedtrialonsets = nan(1,blockData(iBlock).trialsPerBlock); %#ok<AGROW>
    blockData(iBlock).actualtrialonsets = nan(1,blockData(iBlock).trialsPerBlock); %#ok<AGROW>
    blockData(iBlock).corrresps = nan(1,blockData(iBlock).trialsPerBlock); %#ok<AGROW>
    blockData(iBlock).rts = nan(1,blockData(iBlock).trialsPerBlock); %#ok<AGROW>
    blockData(iBlock).resps = nan(1,blockData(iBlock).trialsPerBlock); %#ok<AGROW>
    blockData(iBlock).accs = zeros(1,blockData(iBlock).trialsPerBlock); %#ok<AGROW>
    blockData(iBlock).pulses = nan(1,blockData(iBlock).trialsPerBlock); %#ok<AGROW>
    blockData(iBlock).predict = nan(1,blockData(iBlock).trialsPerBlock); %#ok<AGROW>
    blockData(iBlock).classOutputFileLoad = nan(2,ceil(blockData(iBlock).trialsPerBlock/2)); %#ok<AGROW>
    blockData(iBlock).classOutputFile = cell(2,ceil(blockData(iBlock).trialsPerBlock/2)); %#ok<AGROW>
    blockData(iBlock).categsep = nan(1,blockData(iBlock).trialsPerBlock); %#ok<AGROW>
    blockData(iBlock).attImgProp = nan(2,ceil(blockData(iBlock).trialsPerBlock/2)); %#ok<AGROW>
    blockData(iBlock).smoothAttImgProp = nan(2,ceil(blockData(iBlock).trialsPerBlock/2));  %#ok<AGROW>
    blockData(iBlock).categs{blockData(iBlock).attCateg} = PsychRandSample(randSampAttCategList(blockData(iBlock).attCateg,:),[1 blockData(iBlock).trialsPerBlock]); %#ok<AGROW>
    tempNoGoTrials = find(blockData(iBlock).categs{blockData(iBlock).attCateg}==nogoSubCategs(blockData(iBlock).attCateg));
    while ((numel(tempNoGoTrials)~=nNoGoTrials) || (tempNoGoTrials(1)<10) || (any(diff(tempNoGoTrials)<4)) || (tempNoGoTrials(end)>48))
        blockData(iBlock).categs{blockData(iBlock).attCateg} = PsychRandSample(randSampAttCategList(blockData(iBlock).attCateg,:),[1 blockData(iBlock).trialsPerBlock]); %#ok<AGROW>
        tempNoGoTrials = find(blockData(iBlock).categs{blockData(iBlock).attCateg}==nogoSubCategs(blockData(iBlock).attCateg)); %#ok<NOPRT>
    end

    if negdist
        blockData(iBlock).categs{blockData(iBlock).inattCateg} = PsychRandSample(randSampInattCategList(blockData(iBlock).inattCateg,:)+2,[1 blockData(iBlock).trialsPerBlock]); %#ok<AGROW>
        tempNoGoTrials = find(blockData(iBlock).categs{blockData(iBlock).inattCateg}==nogoSubCategs(blockData(iBlock).inattCateg)+2); %#ok<NOPRT>
        while (numel(tempNoGoTrials)~=nNoGoTrials) || (tempNoGoTrials(1)<10) || (any(diff(tempNoGoTrials)<4)) || (tempNoGoTrials(end)>47)
            blockData(iBlock).categs{blockData(iBlock).inattCateg} = PsychRandSample(randSampInattCategList(blockData(iBlock).inattCateg,:)+2,[1 blockData(iBlock).trialsPerBlock]); %#ok<AGROW>
            tempNoGoTrials = find(blockData(iBlock).categs{blockData(iBlock).inattCateg}==nogoSubCategs(blockData(iBlock).inattCateg)+2); %#ok<NOPRT>
        end
    else
        blockData(iBlock).categs{blockData(iBlock).inattCateg} = PsychRandSample(randSampInattCategList(blockData(iBlock).inattCateg,:),[1 blockData(iBlock).trialsPerBlock]); %#ok<AGROW>
        tempNoGoTrials = find(blockData(iBlock).categs{blockData(iBlock).inattCateg}==nogoSubCategs(blockData(iBlock).inattCateg));
        while (numel(tempNoGoTrials)~=nNoGoTrials) || (tempNoGoTrials(1)<10) || (any(diff(tempNoGoTrials)<4)) || (tempNoGoTrials(end)>47)
            blockData(iBlock).categs{blockData(iBlock).inattCateg} = PsychRandSample(randSampInattCategList(blockData(iBlock).inattCateg,:),[1 blockData(iBlock).trialsPerBlock]); %#ok<AGROW>
            tempNoGoTrials = find(blockData(iBlock).categs{blockData(iBlock).inattCateg}==nogoSubCategs(blockData(iBlock).inattCateg)); %#ok<NOPRT>
        end
    end
    blockData(iBlock).images{SCENE} = nan(1,blockData(iBlock).trialsPerBlock); %#ok<AGROW>
    blockData(iBlock).images{FACE} = nan(1,blockData(iBlock).trialsPerBlock); %#ok<AGROW>
    blockData(iBlock).files = cell(1,blockData(iBlock).trialsPerBlock); %#ok<AGROW>
    
    if iBlock == (nBlocksPerPhase+1) %first feedback block
        TRsFix = (TRCounter+1):(TRCounter+nTRsFix);
        patterns.block(TRsFix) = zeros(1,nTRsFix);
        patterns.type(TRsFix) = zeros(1,nTRsFix);
        patterns.attCateg(TRsFix) = zeros(1,nTRsFix);
        patterns.stim(TRsFix) = zeros(1,nTRsFix);
        patterns.regressor(1:2,TRsFix) = zeros(2,nTRsFix);
        TRCounter = TRCounter+nTRsFix-1;
    end
    
    %account for instruction TRs
    for TRCounter = (TRCounter+1):(TRCounter+instructLen);
        patterns.block(TRCounter) = iBlock;
        patterns.type(TRCounter) = blockData(iBlock).type;
        patterns.attCateg(TRCounter) = blockData(iBlock).attCateg;
        patterns.stim(TRCounter) = 0;
        switch patterns.attCateg(TRCounter)
            case 1
                patterns.regressor(:,TRCounter+labelsShift) = [0;0];
            case 2
                patterns.regressor(:,TRCounter+labelsShift) = [0;0];
        end
    end
    
    % prep images
    for iTrial = 1:blockData(iBlock).trialsPerBlock;
        
        % prep images
        for half=[SCENE FACE]
            % update image counters
            categCounter(blockData(iBlock).categs{half}(iTrial)) = categCounter(blockData(iBlock).categs{half}(iTrial))+1;
            % reset counter and reshuffle images if list has been exhausted
            if (categCounter(blockData(iBlock).categs{half}(iTrial)) > numImages(blockData(iBlock).categs{half}(iTrial)))
                categCounter(blockData(iBlock).categs{half}(iTrial)) = 1; % start counter over, and reshuffle images
                imageShuffle{blockData(iBlock).categs{half}(iTrial)} = randperm(numImages(blockData(iBlock).categs{half}(iTrial))); %#ok<AGROW>
            end
            % get current images
            blockData(iBlock).images{half}(iTrial) = imageShuffle{blockData(iBlock).categs{half}(iTrial)}(categCounter(blockData(iBlock).categs{half}(iTrial))); %#ok<AGROW
        end
        
        blockData(iBlock).corrresps(iTrial) = correctResp{blockData(iBlock).categs{blockData(iBlock).attCateg}(iTrial)}; %#ok<AGROW>
        
        trialCounter = trialCounter+1;
        blockData(iBlock).trialCount(iTrial) = trialCounter; %#ok<AGROW>
        
        if (mod(iTrial,nTrialsPerTR)==1)
            TRCounter = TRCounter + 1;
            patterns.block(TRCounter) = iBlock;
            patterns.type(TRCounter) = blockData(iBlock).type;
            patterns.attCateg(TRCounter) = blockData(iBlock).attCateg;
            patterns.stim(TRCounter) = 1;
            switch patterns.attCateg(TRCounter)
                case 1
                    patterns.regressor(:,TRCounter+labelsShift) = [1;0];
                case 2
                    patterns.regressor(:,TRCounter+labelsShift) = [0;1];
            end
        end
        
    end
    
    for TRCounter = (TRCounter+1):(TRCounter+IBI);
        patterns.block(TRCounter) = iBlock;
        patterns.type(TRCounter) = blockData(iBlock).type;
        patterns.attCateg(TRCounter) = blockData(iBlock).attCateg;
        patterns.stim(TRCounter) = 0;
        switch patterns.attCateg(TRCounter)
            case 1
                patterns.regressor(:,TRCounter+labelsShift) = [0;0];
            case 2
                patterns.regressor(:,TRCounter+labelsShift) = [0;0];
        end
    end
    
    if iBlock == numBlocks
        TRsExtra = (TRCounter+1):nTRs;
        patterns.block(TRsExtra) = zeros(1,numel(TRsExtra));
        patterns.type(TRsExtra) = zeros(1,numel(TRsExtra));
        patterns.attCateg(TRsExtra) = zeros(1,numel(TRsExtra));
        patterns.stim(TRsExtra) = zeros(1,numel(TRsExtra));
        patterns.regressor(1:2,TRsExtra) = zeros(2,numel(TRsExtra));        
    end
end

lastVolPhase1 = find(patterns.block==(nBlocksPerPhase),1,'last'); %#ok<NASGU>
firstVolPhase2 = find(patterns.block==(nBlocksPerPhase+1),1,'first'); %#ok<NASGU>

%% save variables to load during experiment

save([runHeader '/blockdatadesign_' num2str(runNum) '_' datestr(now,30)],'blockData','STABLE','RTFEED','disdaqs','TR','nTrialsPerTR','labelsShift','instructLen',...
    'IBI','SCENE','FACE','nSubCategs','INDOOR','OUTDOOR','MALE','FEMALE','FEMALESAD','MALESAD','firstVolPhase2','rtfeedback');
save([runHeader '/patternsdesign_' num2str(runNum) '_' datestr(now,30)],'patterns','TR','labelsShift','STABLE','RTFEED','instructLen','disdaqs','nBlocksPerPhase','nTRs','nTRsFix','firstVolPhase2','lastVolPhase1','rtfeedback');

save([matchRunHeader '/blockdatadesign_' num2str(runNum) '_' datestr(now,30)],'blockData','STABLE','RTFEED','disdaqs','TR','nTrialsPerTR','labelsShift','instructLen',...
    'IBI','SCENE','FACE','nSubCategs','INDOOR','OUTDOOR','MALE','FEMALE','FEMALESAD','MALESAD','firstVolPhase2','rtfeedback');
save([matchRunHeader '/patternsdesign_' num2str(runNum) '_' datestr(now,30)],'patterns','TR','labelsShift','STABLE','RTFEED','instructLen','disdaqs','nBlocksPerPhase','nTRs','nTRsFix','firstVolPhase2','lastVolPhase1','rtfeedback');


% clean up and go home
fclose('all');
end
