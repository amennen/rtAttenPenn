function [blockData patterns] = RealTimePunisherExptSequence_CLOUD(subjectNum,runNum,rtfeedback,typeNum,expDay)
% function [testTiming blockData] = RealTimePunisherExptOutline_CLOUD(subjectNum,runNum,rtfeedback,typeNum,expDay)
%
% Face/house attention experiment with real-time classifier feedback
%
%
% REQUIRED INPUTS:
% - subjectNum:  participant number [any integer]
%                if subjectNum = 0, no information will be saved
% - runNum:      run number [any integer]
% - rtfeedback:  if you're doing rt-feedback in that run (no for first run, yes for others) 
% - typeNum:     if you want to show negative/positive/neutral faces during NF
% - expDay:      day of NF training (determines how many runs there are)

%
% OUTPUTS
% - testTiming: elapsed time for each iteration of SVM testing
% - patterns:   ?????
%
% Written by: Megan deBettencourt/Anne Mennen
% Version: 2.0
% Last modified: Jan 2020 - changing to be used with toml file

%% check inputs

%check that there is a sufficient number of inputs

if ~isnumeric(subjectNum)
    error('subjectNum must be a number');
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
dataHeader = ['data/subject' num2str(subjectNum)];
dayHeader = [dataHeader '/day' num2str(expDay)];
runHeader = [dayHeader '/run' num2str(runNum)];
classOutputDir = [runHeader '/classoutput'];
expDayInt = floor(expDay); % make sure you get the actual day number
%% create subject folder

%somehow assert that subject/run combo has not already been run!

if (~isdir(dataHeader))
    mkdir(dataHeader);
end

if (~isdir(dayHeader))
    mkdir(dayHeader);
end

if (~isdir(runHeader))
    mkdir(runHeader);
end

if (~isdir(classOutputDir))
    mkdir(classOutputDir);
end


%% Experimental Parameters

%scanning parameters
disdaqs = 20;        %#ok<NASGU> % [secs] # seconds to drop at the beginning of run
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
nTRsFix = 3;       % [TRs]  # TRs to dedicate to training the model

STABLE = 1;         % numerical designation of the block type stable
RTFEED = 2;         % numerical designation of the block type feedback

%experimental order of block types
if (rtfeedback == 1)
    %typeOrder = [RTFEED*ones(1,nBlocksPerPhase) RTFEED*ones(1,nBlocksPerPhase)];
    typeOrder = [STABLE*ones(1,nBlocksPerPhase) RTFEED*ones(1,nBlocksPerPhase)];
elseif (rtfeedback == 0)
    typeOrder = [STABLE*ones(1,nBlocksPerPhase) STABLE*ones(1,nBlocksPerPhase)];
end

%numerically designate the block categories
nCategs = 2;
SCENE = 1;
FACE = 2;

%numerically designate the subcategories
nSubCategs = 8;     % in total, across all categorires
INDOOR = 1;         % scenes
OUTDOOR = 2;        % scenes
MALE = 3;           % faces
FEMALE = 4;         % faces
MALESAD = 5;
FEMALESAD = 6;
MALEHAPPY = 7;
FEMALEHAPPY = 8;


% TypeNum:
NEUTRAL = 1;
SAD = 2;
HAPPY = 3;

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
    randSampAttCategList(i,:) = [goSubCategs(i)*ones(1,goCategPercent*10) nogoSubCategs(i)]; %#ok<AGROW> %just where to choose 10% of the time have it be a nogo trial
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
    elseif (categ == MALEHAPPY)
        cd male_happy;
    elseif (categ == FEMALEHAPPY)
        cd female_happy
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
% counterbalance block order across runs and subjects
% this is fine if type is NEUTRAL--counterbalance across all

if (mod(subjectNum,8) == 1) || (mod(subjectNum,8) == 2) || (mod(subjectNum,8) == 3) || (mod(subjectNum,8) == 4)
    if mod(expDayInt,2)==1
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
else
    if (mod(expDayInt,2)==1)
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
    else
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
    end
end
% now modify based on types

if rtfeedback % if this is a feedback run
    if typeNum == SAD
        emblocks = [0 0 0 0 1 1 1 1]; %emotion blocks
        blockSequencePhase2 = [SCENE SCENE SCENE SCENE]; % we only want to attend to scenes
        categOrderPhase2 = repmat(blockSequencePhase2,1,nBlocksPerPhase/numel(blockSequencePhase2));
    elseif typeNum == HAPPY
        emblocks = [0 0 0 0 1 1 1 1];
        blockSequencePhase2 = [FACE FACE FACE FACE]; % we only want to attend to faces
        categOrderPhase2 = repmat(blockSequencePhase2,1,nBlocksPerPhase/numel(blockSequencePhase2));
    else
        emblocks = [0 0 0 0 0 0 0 0];
    end
else
    emblocks = [0 0 0 0 0 0 0 0]; % if not a feedback run
end

attCategOrder = [categOrderPhase1 categOrderPhase2]; % SAYS IF THAT BLOCK ATTEND TO SCENE OR FACE, ALL 8 BLOCKS IN RUN
inattCategOrder = (attCategOrder==1)+1; % JUST THE REVERSE OF BEFORE, WHAT YOU'RE NOT PAYING ATTENTION TO
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
    blockData(iBlock).fileList = {}; %#ok<AGROW>
    blockData(iBlock).newestFile = {};
    blockData(iBlock).categsep = nan(1,blockData(iBlock).trialsPerBlock); %#ok<AGROW>
    blockData(iBlock).attImgProp = nan(2,ceil(blockData(iBlock).trialsPerBlock/2)); %#ok<AGROW>
    blockData(iBlock).smoothAttImgProp = nan(2,ceil(blockData(iBlock).trialsPerBlock/2));  %#ok<AGROW>
    blockData(iBlock).categs{blockData(iBlock).attCateg} = PsychRandSample(randSampAttCategList(blockData(iBlock).attCateg,:),[1 blockData(iBlock).trialsPerBlock]); % this randomly samples the probability list so that ratio of go/no trials are kept
    tempNoGoTrials = find(blockData(iBlock).categs{blockData(iBlock).attCateg}==nogoSubCategs(blockData(iBlock).attCateg)); % this finds where the no go trials are
    while ((numel(tempNoGoTrials)~=nNoGoTrials) || (tempNoGoTrials(1)<10) || (any(diff(tempNoGoTrials)<4)) || (tempNoGoTrials(end)>47)) % don't want the no go trials to be too early, too frequent, or too late
        blockData(iBlock).categs{blockData(iBlock).attCateg} = PsychRandSample(randSampAttCategList(blockData(iBlock).attCateg,:),[1 blockData(iBlock).trialsPerBlock]); %#ok<AGROW>
        tempNoGoTrials = find(blockData(iBlock).categs{blockData(iBlock).attCateg}==nogoSubCategs(blockData(iBlock).attCateg)); %#ok<NOPRT>
    end
    % if this block is emotional and we're going to attend to scenes and
    % AWAY from happy
    if emblocks(iBlock) && typeNum==SAD % this says for every trial in block, what category is the unattended stimulus going to be
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
        
        if emblocks(iBlock) && typeNum == HAPPY % then get happy images--redo attended categories
            blockData(iBlock).categs{blockData(iBlock).attCateg} = PsychRandSample(randSampAttCategList(blockData(iBlock).attCateg,:)+4,[1 blockData(iBlock).trialsPerBlock]); % this randomly samples the probability list so that ratio of go/no trials are kept
            tempNoGoTrials = find(blockData(iBlock).categs{blockData(iBlock).attCateg}==nogoSubCategs(blockData(iBlock).attCateg)+4); % this finds where the no go trials are
            while ((numel(tempNoGoTrials)~=nNoGoTrials) || (tempNoGoTrials(1)<10) || (any(diff(tempNoGoTrials)<4)) || (tempNoGoTrials(end)>47)) % don't want the no go trials to be too early, too frequent, or too late
                blockData(iBlock).categs{blockData(iBlock).attCateg} = PsychRandSample(randSampAttCategList(blockData(iBlock).attCateg,:)+4,[1 blockData(iBlock).trialsPerBlock]); %#ok<AGROW>
                tempNoGoTrials = find(blockData(iBlock).categs{blockData(iBlock).attCateg}==nogoSubCategs(blockData(iBlock).attCateg)+4); %#ok<NOPRT>
            end
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
        patterns.regressor(1:2,TRsFix+labelsShift) = zeros(2,nTRsFix); % ACM added 8/11-labelshift not there before
        TRCounter = TRCounter+nTRsFix;
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
    
    % prep images over all 50 trials in the block
    for iTrial = 1:blockData(iBlock).trialsPerBlock;
        
        % prep images
        for half=[SCENE FACE]
            % update image counters
            categCounter(blockData(iBlock).categs{half}(iTrial)) = categCounter(blockData(iBlock).categs{half}(iTrial))+1; % counts the number of times that category was shown in the trial
            % reset counter and reshuffle images if list has been exhausted
            if (categCounter(blockData(iBlock).categs{half}(iTrial)) > numImages(blockData(iBlock).categs{half}(iTrial)))
                categCounter(blockData(iBlock).categs{half}(iTrial)) = 1; % start counter over, and reshuffle images
                imageShuffle{blockData(iBlock).categs{half}(iTrial)} = randperm(numImages(blockData(iBlock).categs{half}(iTrial))); %#ok<AGROW>
            end
            % get current images--out of the imageShuffle for that
            % category, take the next image in imageShuffle from that
            % category
            blockData(iBlock).images{half}(iTrial) = imageShuffle{blockData(iBlock).categs{half}(iTrial)}(categCounter(blockData(iBlock).categs{half}(iTrial))); %#ok<AGROW
        end
        if blockData(iBlock).categs{blockData(iBlock).attCateg}(iTrial) > 4 % then we're using an emotion
            if blockData(iBlock).categs{blockData(iBlock).attCateg}(iTrial) > 6 % then subtract 4 because happy
                blockData(iBlock).corrresps(iTrial) = correctResp{blockData(iBlock).categs{blockData(iBlock).attCateg}(iTrial)-4};
            else
                blockData(iBlock).corrresps(iTrial) = correctResp{blockData(iBlock).categs{blockData(iBlock).attCateg}(iTrial)-2};
            end
        else
            blockData(iBlock).corrresps(iTrial) = correctResp{blockData(iBlock).categs{blockData(iBlock).attCateg}(iTrial)}; %#ok<AGROW>
        end
        
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
    'IBI','SCENE','FACE','nSubCategs','INDOOR','OUTDOOR','MALE','FEMALE','FEMALESAD','MALESAD','MALEHAPPY', 'FEMALEHAPPY', 'firstVolPhase2','rtfeedback');
save([runHeader '/patternsdesign_' num2str(runNum) '_' datestr(now,30)],'patterns','TR','labelsShift','STABLE','RTFEED','instructLen','disdaqs','nBlocksPerPhase','nTRs','nTRsFix','firstVolPhase2','lastVolPhase1','rtfeedback');

% clean up and go home
fclose('all');
end
