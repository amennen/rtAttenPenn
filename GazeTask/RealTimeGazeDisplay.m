function [blockData] = RealTimeGazeDisplay(subjectNum,matchNum,eyeTrack,debug)
% function [blockData] = RealTimePunisherDisplay(subjectNum,subjectName,runNum,useButtonBox,fMRI,rtData,debug)
%
% Face/house attention experiment with real-time classifier feedback
%
%
% REQUIRED INPUTS:
% - subjectNum:  participant number [any integer]
%                if subjectNum = 0, no information will be saved
% - matchNum:    if subject is yoked to a subject & which subject
% - debug:       whether debugging [1/0]
% - eyeTrack:    whether or not to use eyeTracker
%
% OUTPUTS
% - testTiming: elapsed time for each iteration of SVM testing
% - blockData:


%% check inputs
KbName('UnifyKeyNames');
%check that there is a sufficient number of inputs
if nargin < 4
    error('4 inputs are required: subjectNum, matchNum, eyeTrack,debug');
end

if ~isnumeric(subjectNum)
   error('subjectNum must be a number'); 
end


if ~isnumeric(matchNum)
   error('matchNum must be a number'); 
end


if (eyeTrack~=1) && (eyeTrack~=0)
    error('eyeTrack  must be either 1 (if using) or 0 (if not)')
end



if (debug~=1) && (debug~=0)
    error('debug must be either 1 (if debugging) or 0 (if not)')
end


%% Boilerplate

if (~debug) %so that when debugging you can do other things
    %Screen('Preference', 'SkipSyncTests', 1);
    
    
   % ListenChar(2);  %prevent command window output
   % HideCursor;     %hide mouse cursor    
else
    Screen('Preference', 'SkipSyncTests', 1);
end

seed = sum(100*clock); %get random seed
RandStream.setGlobalStream(RandStream('mt19937ar','seed',seed));%set seed




%initialize system time calls
GetSecs;

%% Experimental Parameters


% block timing
instructOn = 0;     % secs
instructDur = 1;    % secs
instructTRnum = 1;  % TRs
%fixationOn = TR-.3; % secs

% trial timing
stimDur = 30;        % secs
deltat = .1;        % secs
allowance = .05;    % secs
fixation = 1; %ITI

% display parameters
textColor = 0;
textFont = 'Arial';
textSize = 25;
textSpacing = 25;
fixColor = 0;
respColor = 255;
backColor = 127;
imageSize = [600 800]; % assumed square %MdB check image size
fixationSize = 4;% pixels
progWidth = 400; % image loading progress bar
progHeight = 20;

ScreenResX = 1280;
ScreenResY = 720;

%% Response Mapping and Counterbalancing

% skyra: use current design button box (keys 1,2,3,4)
KbName('UnifyKeyNames');
DEVICE = -1;
% counterbalancing response mapping based on subject assignment
% correctResp spells out the responses for {INDOOR,OUTDOOR,MALE,FEMALE}
instruct = 'Please look at the computer screen for the allotted time in the trial.';

% want to have it so there are 20 trials
% 8 filler trials: neutral fillers
% 12 regular trials
% each stimulus category must occur in each of the spots 3 times
nImages = 12;
nTrialsReg = 12;
nFillers = 8;
nTrials = nTrialsReg + nFillers;
DYSPHORIC = 1;
THREAT = 2;
NEUTRAL = 3;
POSITIVE = 4;
NEUTRALFILLER = 5;

order(DYSPHORIC,:) = randperm(nImages);
order(THREAT,:) = randperm(nImages);
order(NEUTRAL,:) = randperm(nImages);
order(POSITIVE,:) = randperm(nImages);
nCategories = 4;

% now for the positioning
done = 0;
while ~done
    for t = 1:nTrialsReg
        position(t,:) = randperm(nCategories);
    end
    % make sure there 3x repeats in each cateogry
    if length(find(position(:,1)==1)) == 3 && length(find(position(:,2)==1)) ==3 && length(find(position(:,3)==1))==3 && length(find(position(:,4)==1))==3 && length(find(position(:,1)==2)) == 3 && length(find(position(:,2)==2)) ==3 && length(find(position(:,3)==2))==3 && length(find(position(:,4)==2))==3 && length(find(position(:,1)==3)) == 3 && length(find(position(:,2)==3)) ==3 && length(find(position(:,3)==3))==3 && length(find(position(:,4)==3))==3 && length(find(position(:,1)==4)) == 3 && length(find(position(:,2)==4)) ==3 && length(find(position(:,3)==4))==3 && length(find(position(:,4)==4))==3
        done = 1;
    end
end

% now counterbalance types of trials
trialType = Shuffle([ones(1,nTrialsReg) 2*ones(1,nFillers)]);
% so 1 = regular trial and 2 = filler
%% Initialize Screens

screenNumbers = Screen('Screens');

% show full screen if real, otherwise part of screen
if debug
    screenNum = 0;
else
    screenNum = screenNumbers(end);
end

%retrieve the size of the display screen
if debug
    screenX = 800;
    screenY = 800;
else
    % first just make the screen tiny
    
    [screenX screenY] = Screen('WindowSize',screenNum);
    % put this back in!!!
    windowSize.degrees = [51 30];
    resolution = Screen('Resolution', screenNum);
    resolution = Screen('Resolution', 0); % REMOVE THIS AFTERWARDS!!
    windowSize.pixels = [resolution.width resolution.height];
    screenX = windowSize.pixels(1);
    screenY = windowSize.pixels(2);
end

mainWindow = Screen(screenNum,'OpenWindow',backColor,[0 0 screenX screenY]);

% details of main window
centerX = screenX/2; centerY = screenY/2;
Screen(mainWindow,'TextFont',textFont);
Screen(mainWindow,'TextSize',textSize);

% placeholder for images
imageRect = [0,0,imageSize,imageSize];

% position of images
centerRect = [centerX-imageSize/2,centerY-imageSize/2,centerX+imageSize/2,centerY+imageSize/2];

% position of fixation dot
fixDotRect = [centerX-fixationSize,centerY-fixationSize,centerX+fixationSize,centerY+fixationSize];

% image loading progress bar
progRect = [centerX-progWidth/2,centerY-progHeight/2,centerX+progWidth/2,centerY+progHeight/2];


%% Load or Initialize Real-Time Data & Staircasing Parameters

% if matchNum == 0
%     dataHeader = ['data/' num2str(subjectNum)];
% else
%     dataHeader = ['data/' num2str(subjectNum) '_match'];
% end
% runHeader = [dataHeader '/run' num2str(runNum)];
% classOutputDir = [runHeader '/classoutput'];
% fname = findNewestFile(runHeader, fullfile(runHeader, ['blockdatadesign_' num2str(runNum) '*.mat']));
% %fn = ls([runHeader '/blockdatadesign_' num2str(runNum) '_*']);
% load(fname);
% 
% if any([blockData.type]==2) %#ok<NODEF>
%     restInstruct = 'The feedback blocks will start soon';
% else
%     restInstruct = 'The next blocks will start soon';
% end
% restDur = 4;

%% Load Images
nSubCategs = 5;
cd images;
for categ=1:nSubCategs
    
    % move into the right folder
    if (categ == DYSPHORIC)
        cd Dysphoric_proc;
    elseif (categ == THREAT)
        cd Threat_proc;
    elseif (categ == NEUTRAL)
        cd Neutral_proc;
    elseif (categ == POSITIVE)
        cd Positive_proc;
    elseif (categ == NEUTRALFILLER)
        cd NeutralFiller_proc;
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
                
                % update progress bar
%                 Screen('FrameRect',mainWindow,0,progRect,10);
%                 Screen('FillRect',mainWindow,0,progRect);
%                 Screen('FillRect',mainWindow,[255 0 0],progRect-[0 0 round((1-img/numImages(categ))*progWidth) 0]);
%                 Screen('Flip',mainWindow);
                
                % read images
                images{categ,img} = imread(dirList{categ}(img).name); %#ok<AGROW>
            end
            
            cd ..;
        end
    else
        error('Need at least one image per directory!');
    end
end
cd ..;
Screen('Flip',mainWindow);


%% Output Files Setup

% open and set-up output file
dataFile = fopen([dataHeader '/behavior.txt'],'a');
fprintf(dataFile,'\n*********************************************\n');
fprintf(dataFile,'* Punisher Experiment v.2.0\n');
fprintf(dataFile,['* Date/Time: ' datestr(now,0) '\n']);
fprintf(dataFile,['* Seed: ' num2str(seed) '\n']);
fprintf(dataFile,['* Subject Number: ' num2str(subjectNum) '\n']);
fprintf(dataFile,['* Subject Name: ' subjectName '\n']);
fprintf(dataFile,['* Run Number: ' num2str(runNum) '\n']);
fprintf(dataFile,['* Use Button Box: ' num2str(useButtonBox) '\n']);
fprintf(dataFile,['* rtData: ' num2str(rtData) '\n']);
fprintf(dataFile,['* debug: ' num2str(debug) '\n']);
fprintf(dataFile,'*********************************************\n\n');

% print header to command window
fprintf('\n*********************************************\n');
fprintf('* Punisher Experiment v.2.0\n');
fprintf(['* Date/Time: ' datestr(now,0) '\n']);
fprintf(['* Seed: ' num2str(seed) '\n']);
fprintf(['* Subject Number: ' num2str(subjectNum) '\n']);
fprintf(['* Subject Name: ' subjectName '\n']);
fprintf(['* Run Number: ' num2str(runNum) '\n']);
fprintf(['* Use Button Box: ' num2str(useButtonBox) '\n']);
fprintf(['* rtData: ' num2str(rtData) '\n']);
fprintf(['* debug: ' num2str(debug) '\n']);
fprintf('*********************************************\n\n');


%% Show Instructions

% clear screen
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);
FlushEvents('keyDown');

% show instructions
if (blockData(1).type == 1)
    runInstruct{1} = sceneInstruct;
    runInstruct{2} = faceInstruct;
else
    runInstruct{1} = faceInstruct;
    runInstruct{2} = sceneInstruct;
end

for instruct=1:length(runInstruct)
    tempBounds = Screen('TextBounds',mainWindow,runInstruct{instruct});
    Screen('drawtext',mainWindow,runInstruct{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow);

% wait for experimenter to advance with 'q' key
FlushEvents('keyDown');
while(1)
    temp = GetChar;
    if (temp == '1')
        break;
    end
end
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);



%% Start Experiment

% wait for initial trigger
Priority(MaxPriority(screenNum));
Screen(mainWindow,'FillRect',backColor);
runStart = GetSecs;
Screen('Flip',mainWindow);
Priority(0);


%% set up

for iBlock = 1:numel(blockData)
    %block instructions
    if (blockData(iBlock).attCateg==SCENE)
        blockInstruct{1} = sceneShorterInstruct; %#ok<AGROW>
    elseif (blockData(iBlock).attCateg==FACE)
        blockInstruct{2} = faceShorterInstruct; %#ok<AGROW>
    end
    
    %timing
    blockDur(iBlock+1) = TR*(instructLen+blockData(iBlock).trialsPerBlock/nTrialsPerTR+IBI); %#ok<AGROW>
    blockOnsets(iBlock) = disdaqs + sum(blockDur(1:iBlock)); %#ok<AGROW>
end

typeOrder = [blockData.type];
indBlocksPhase1 = 1:(numel(typeOrder)/2);
indBlocksPhase2 = (numel(typeOrder)/2+1):numel(typeOrder);

%% Block Sequence - Phase 1

trialCounter = 0;
volCounter = 1+disdaqs/TR-1;
for iBlock=1:numel(indBlocksPhase1)
    
    % timing
    blockData(iBlock).actualblockonset = GetSecs; %#ok<AGROW>
    blockData(iBlock).plannedinstructonset = blockOnsets(iBlock)+runStart; %#ok<AGROW>
    blockData(iBlock).plannedtrialonsets = blockData(iBlock).plannedinstructonset + TR*instructTRnum + [0 cumsum(repmat(TR/nTrialsPerTR,1,blockData(iBlock).trialsPerBlock))]; %#ok<AGROW>
    
    % show instructions
    tempBounds = Screen('TextBounds',mainWindow,blockInstruct{blockData(iBlock).attCateg});
    Screen('drawtext',mainWindow,blockInstruct{blockData(iBlock).attCateg},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5,textColor);
    clear tempBounds;
    blockData(iBlock).actualinstructonset = Screen('Flip',mainWindow,blockData(iBlock).plannedinstructonset+instructOn); %#ok<AGROW> % turn on
    
    % show fixation
    Screen(mainWindow,'FillOval',fixColor,fixDotRect);
    Screen('Flip',mainWindow,blockData(iBlock).actualinstructonset+instructOn+instructDur); %turn off
    
    % start trial sequence
    for iTrial=1:(blockData(iBlock).trialsPerBlock)
        
        trialCounter = trialCounter+1;
            

        % generate image
        fullImage = uint8((1-blockData(iBlock).attImgProp(iTrial))*tempImage{SCENE}+blockData(iBlock).attImgProp(iTrial)*tempImage{FACE});
        
        % make textures
        imageTex = Screen('MakeTexture',mainWindow,fullImage);
        Screen('PreloadTextures',mainWindow,imageTex);
        
        % wait for trigger and show image
        FlushEvents('keyDown');
        Priority(MaxPriority(screenNum));
        Screen('FillRect',mainWindow,backColor);
        Screen('DrawTexture',mainWindow,imageTex,imageRect,centerRect);
        Screen(mainWindow,'FillOval',fixColor,fixDotRect);
        tRespTimeout = blockData(iBlock).plannedtrialonsets(iTrial)+respWindow; %response timeout
        
        %wait for pulse
        if (rtData) && mod(iTrial,nTrialsPerTR)==1
            %[~,blockData(iBlock).pulses(iTrial)] = WaitTRPulsePTB3_skyra(1,blockData(iBlock).plannedtrialonsets(iTrial)+allowance); %#ok<AGROW>
            [~,blockData(iBlock).pulses(iTrial)] = WaitTRPulse(TRIGGER_keycode,DEVICE,blockData(iBlock).plannedtrialonsets(iTrial));
            blockData(iBlock).actualtrialonsets(iTrial) = Screen('Flip',mainWindow,blockData(iBlock).plannedtrialonsets(iTrial)); %#ok<AGROW> % turn on
        else
            blockData(iBlock).pulses(iTrial) = 0; %#ok<AGROW>
            blockData(iBlock).actualtrialonsets(iTrial) = Screen('Flip',mainWindow,blockData(iBlock).plannedtrialonsets(iTrial)); %#ok<AGROW>
        end
        stimOn = 1;
        FlushEvents('keyDown');
        while(GetSecs < tRespTimeout)
            
            % remove stimulus and wait for response
%            if (stimOn && (GetSecs-blockData(iBlock).actualtrialonsets(iTrial) > stimDur))
%                 Screen('FillRect',mainWindow,backColor);
%                 Screen(mainWindow,'FillOval',fixColor,fixDotRect);
%                 Screen('Flip',mainWindow);
%                stimOn = 0;
%            end
            
            % check for responses if none received yet
            if isnan(blockData(iBlock).rts(iTrial))
                [keyIsDown, secs, keyCode] = KbCheck(DEVICE); % -1 checks all keyboards
                if keyIsDown
                    if (keyCode(LEFT))
                        blockData(iBlock).rts(iTrial) = secs-blockData(iBlock).actualtrialonsets(iTrial); %#ok<AGROW> NTB: deltasecs is timed to last KbCheck call
                        blockData(iBlock).resps(iTrial) = find(keyCode,1); %#ok<AGROW>
                        Screen('FillRect',mainWindow,backColor);
                        if (stimOn) % leave image up if response before image duration
                            Screen('DrawTexture',mainWindow,imageTex,imageRect,centerRect);
                        end
                        Screen(mainWindow,'FillOval',respColor,fixDotRect);
                        Screen('Flip',mainWindow);
                    end
                end
            end
        end
        
        %accuracy
        if ~isnan(blockData(iBlock).corrresps(iTrial)) %go trial
            if (blockData(iBlock).resps(iTrial)==blockData(iBlock).corrresps(iTrial)) %made correct response
                blockData(iBlock).accs(iTrial) = 1; %#ok<AGROW>
            else
                blockData(iBlock).accs(iTrial) = 0; %#ok<AGROW>
            end
        else %nogo trial
            if isnan(blockData(iBlock).resps(iTrial)) %correctly did NOT make a response
                blockData(iBlock).accs(iTrial) = 2; %#ok<AGROW>
            else %made a response
                blockData(iBlock).accs(iTrial) = 0; %#ok<AGROW>
            end
        end
        
        
        % print trial results
        fprintf(dataFile,'%d\t%d\t%s\t%s\t%d\t%.3f\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n',runNum,iBlock,typeStr{blockData(iBlock).type},categStr{blockData(iBlock).attCateg},iTrial,blockData(iBlock).actualtrialonsets(iTrial)-blockData(iBlock).plannedtrialonsets(iTrial),blockData(iBlock).pulses(iTrial),blockData(iBlock).categs{SCENE}(iTrial),blockData(iBlock).categs{FACE}(iTrial),blockData(iBlock).images{SCENE}(iTrial),blockData(iBlock).images{FACE}(iTrial),blockData(iBlock).corrresps(iTrial),blockData(iBlock).resps(iTrial),blockData(iBlock).accs(iTrial),blockData(iBlock).rts(iTrial),NaN,NaN,NaN,blockData(iBlock).attImgProp(iTrial),NaN);
        fprintf('%d\t%d\t%s\t%s\t%d\t%.3f\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n',runNum,iBlock,typeStr{blockData(iBlock).type},categStr{blockData(iBlock).attCateg},iTrial,blockData(iBlock).actualtrialonsets(iTrial)-blockData(iBlock).plannedtrialonsets(iTrial),blockData(iBlock).pulses(iTrial),blockData(iBlock).categs{SCENE}(iTrial),blockData(iBlock).categs{FACE}(iTrial),blockData(iBlock).images{SCENE}(iTrial),blockData(iBlock).images{FACE}(iTrial),blockData(iBlock).corrresps(iTrial),blockData(iBlock).resps(iTrial),blockData(iBlock).accs(iTrial),blockData(iBlock).rts(iTrial),NaN,NaN,NaN,blockData(iBlock).attImgProp(iTrial),NaN);
        
    end % trial loop
    
    while ((GetSecs-blockData(iBlock).actualtrialonsets(iTrial) < stimDur))
        1;
    end
    
    Screen('FillRect',mainWindow,backColor);
    Screen(mainWindow,'FillOval',fixColor,fixDotRect);
    Screen('Flip',mainWindow);
    
end % end phase 1 block loop


%% pause & wait for model to be trained


% show instructions
tempBounds = Screen('TextBounds',mainWindow,restInstruct);
Screen('drawtext',mainWindow,restInstruct,centerX-tempBounds(3)/2,centerY-tempBounds(4)/5,textColor);
clear tempBounds;
restOnset = Screen('Flip',mainWindow); % show instructions

save([runHeader '/blockdata_training'],'blockData');

% show fixation
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
Screen('Flip',mainWindow,restOnset+restDur); %turn off

% check for model training to be complete
trainedModelComplete = 0;
filePrevFirstVolPhase2 = firstVolPhase2 + (disdaqs/TR) - 2;

if rtData
    while (trainedModelComplete==0)
        [trainedModelComplete tempFileTrainingComplete] = GetSpecificFMRIFile(imgDir,fMRI,filePrevFirstVolPhase2); %#ok<NASGU>
        %     else
        %         if exist(fullfile(classOutputDir,trainedModelFile),'file')
        %             trainedModelComplete = 1;
        %         end
    end
end

% wait for pulse
if rtData
    %[phase2Start,~] = WaitTRPulsePTB3_skyra(1);
    [phase2Start,~] = WaitTRPulse(TRIGGER_keycode,DEVICE);
    if phase2Start == -1
        phase2Start = GetSecs;
    end
    
    phase2Start= phase2Start+TR;
    
else
    FlushEvents('keyDown');

    WaitSecs(IBI*2);
    phase2Start = GetSecs+TR;

end

iBlockPhase2 = 0;
for iBlock = indBlocksPhase2 %Megan Check this!!!
    iBlockPhase2 = iBlockPhase2+1;
    blockDurPhase2(iBlockPhase2+1) = TR*(instructLen+blockData(iBlock).trialsPerBlock/nTrialsPerTR+IBI); %#ok<AGROW>
    blockOnsetsPhase2(iBlockPhase2) = phase2Start + sum(blockDurPhase2(1:iBlockPhase2)); %#ok<AGROW>
end
Screen(mainWindow,'FillRect',backColor);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
Screen('Flip',mainWindow);



%% Block Sequence - Phase2

% prepare for trial sequence
fprintf(dataFile,'run\tblock\tbltyp\tblcat\ttrial\tonsdif\tscat\tfcat\tsimg\tfimg\tcorresp\tresp\tacc\trt\tfile\tload\tcatsep\tattProp\tsmoothProp\n');
fprintf('run\tblock\tbltyp\tblcat\ttrial\tonsdif\tscat\tfcat\tsimg\tfimg\tcorresp\tresp\tacc\trt\tfile\tload\tcatsep\tattProp\tsmoothProp\n');

trialCounter = 0;
volCounter = firstVolPhase2+disdaqs/TR-1;

for iBlock=indBlocksPhase2

    if ~isfield(blockData,'categsep')
        blockData(iBlock).categsep = NaN(1,blockData(iBlock).trialsPerBlock); %#ok<AGROW>
    end
    
    volCounter = volCounter+1;
    
    % timing
    blockData(iBlock).actualblockonset = GetSecs; %#ok<AGROW>
    blockData(iBlock).plannedinstructonset = blockOnsetsPhase2(iBlock-indBlocksPhase2(1)+1); %#ok<AGROW>
    blockData(iBlock).plannedtrialonsets = blockData(iBlock).plannedinstructonset + TR*instructTRnum + [0 cumsum(repmat(TR/nTrialsPerTR,1,blockData(iBlock).trialsPerBlock))]; %#ok<AGROW>
    
    % show instructions
    tempBounds = Screen('TextBounds',mainWindow,blockInstruct{blockData(iBlock).attCateg});
    Screen('drawtext',mainWindow,blockInstruct{blockData(iBlock).attCateg},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5,textColor);
    clear tempBounds;
    blockData(iBlock).actualinstructonset = Screen('Flip',mainWindow,blockData(iBlock).plannedinstructonset+instructOn); %#ok<AGROW> % turn on
    
    % show instructions
    tempBounds = Screen('TextBounds',mainWindow,blockInstruct{blockData(iBlock).attCateg});
    Screen('drawtext',mainWindow,blockInstruct{blockData(iBlock).attCateg},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5,textColor);
    clear tempBounds;
    blockData(iBlock).actualinstructonset = Screen('Flip',mainWindow,blockData(iBlock).plannedinstructonset+instructOn); %#ok<AGROW>
    
    % show fixation
    Screen(mainWindow,'FillOval',fixColor,fixDotRect);
    Screen('Flip',mainWindow,blockData(iBlock).actualinstructonset+instructOn+instructDur); %turn off
    
    % start trial sequence
    for iTrial=1:(blockData(iBlock).trialsPerBlock)
        
        trialCounter = trialCounter+1;
        if (mod(iTrial,nTrialsPerTR)==1) 
            volCounter = volCounter+1;
        end
        blockData(iBlock).volCounter(iTrial) = volCounter; %#ok<AGROW>
        
        % prep images
        for half=[SCENE FACE]
            % get current images
            tempPower{half} = imagePower{blockData(iBlock).categs{half}(iTrial),blockData(iBlock).images{half}(iTrial)}; %#ok<AGROW>
            tempImagePhase{half} = imagePhase{blockData(iBlock).categs{half}(iTrial),blockData(iBlock).images{half}(iTrial)}; %#ok<AGROW>
            tempImage{half} = real(ifft2(tempPower{half}.*exp(sqrt(-1)*tempImagePhase{half}))); %#ok<AGROW>
        end
        
        if iTrial <= nTrialsPerTR %initialize attImgProp
            if iTrial == 1
                blockData(iBlock).attImgProp(iTrial) = attImgPropPhase2; %#ok<AGROW>
                blockData(iBlock).smoothAttImgProp(iTrial) = attImgPropPhase2; %#ok<AGROW>
            end
            blockData(iBlock).attImgProp(iTrial+1) = attImgPropPhase2; %#ok<AGROW>
            blockData(iBlock).smoothAttImgProp(iTrial+1) = attImgPropPhase2; %#ok<AGROW>
        end
        
        % generate image
        fullImage = uint8((1-blockData(iBlock).smoothAttImgProp(iTrial))*tempImage{blockData(iBlock).inattCateg}+blockData(iBlock).smoothAttImgProp(iTrial)*tempImage{blockData(iBlock).attCateg});
        
        % make textures
        imageTex = Screen('MakeTexture',mainWindow,fullImage);
        Screen('PreloadTextures',mainWindow,imageTex);
        
        % wait for trigger and show image
        FlushEvents('keyDown');
        Priority(MaxPriority(screenNum));
        Screen('FillRect',mainWindow,backColor);
        Screen('DrawTexture',mainWindow,imageTex,imageRect,centerRect);
        Screen(mainWindow,'FillOval',fixColor,fixDotRect);
        
        
        tRespTimeout = blockData(iBlock).plannedtrialonsets(iTrial)+respWindow;
        
        %wait for pulse
        if (rtData) && (mod(blockData(iBlock).trial(iTrial),nTrialsPerTR==1)) % this will be true for every other then
            %[~,blockData(iBlock).pulses(iTrial)] = WaitTRPulsePTB3_skyra(1,blockData(iBlock).plannedtrialonsets(iTrial)+allowance); %#ok<AGROW>
            [~,blockData(iBlock).pulses(iTrial)] = WaitTRPulse(TRIGGER_keycode,DEVICE,blockData(iBlock).plannedtrialonsets(iTrial));
            blockData(iBlock).actualtrialonsets(iTrial) = Screen('Flip',mainWindow,blockData(iBlock).plannedtrialonsets(iTrial)); %#ok<AGROW> % turn on
        else
            blockData(iBlock).pulses(iTrial) = 0; %#ok<AGROW>
            blockData(iBlock).actualtrialonsets(iTrial) = Screen('Flip',mainWindow,blockData(iBlock).plannedtrialonsets(iTrial)); %#ok<AGROW>
        end
        
        stimOn = 1;
        FlushEvents('keyDown');
        while(GetSecs < tRespTimeout)
            
            % check for responses if none received yet
            if isnan(blockData(iBlock).rts(iTrial))
                [keyIsDown, secs, keyCode] = KbCheck(DEVICE); % -1 checks all keyboards
                if keyIsDown
                    if (keyCode(LEFT))
                        blockData(iBlock).rts(iTrial) = secs-blockData(iBlock).actualtrialonsets(iTrial); %#ok<AGROW> NTB: deltasecs is timed to last KbCheck call
                        blockData(iBlock).resps(iTrial) = find(keyCode,1); %#ok<AGROW>
                        Screen('FillRect',mainWindow,backColor);
                        if (stimOn) % leave image up if response before image duration
                            Screen('DrawTexture',mainWindow,imageTex,imageRect,centerRect);
                        end
                        Screen(mainWindow,'FillOval',respColor,fixDotRect);
                        Screen('Flip',mainWindow);
                    end
                end
            end
        end
        
        %accuracy
        if ~isnan(blockData(iBlock).corrresps(iTrial)) %go trial
            if (blockData(iBlock).resps(iTrial)==blockData(iBlock).corrresps(iTrial)) %made correct response
                blockData(iBlock).accs(iTrial) = 1; %#ok<AGROW>
            else
                blockData(iBlock).accs(iTrial) = 0; %#ok<AGROW>
            end
        else %nogo trial
            if isnan(blockData(iBlock).resps(iTrial)) %correctly did NOT make a response
                blockData(iBlock).accs(iTrial) = 2; %#ok<AGROW>
            else %made a response
                blockData(iBlock).accs(iTrial) = 0; %#ok<AGROW>
            end
        end
        

         % *************

        %load rtfeedback values once per TR
        if rtfeedback
            if (mod(iTrial,nTrialsPerTR)==1) && (iTrial>nTrialsPerTR)
                %number of odd trials - paired with TRs
                iTrialOdd = ceil(iTrial/2);
                
                %preset the file load to 0 and the timeout
                blockData(iBlock).classOutputFileLoad(iTrial) = 0; %#ok<AGROW>
                tClassOutputFileTimeout = GetSecs + deltat;
                
                %check for classifier output file
                while (~blockData(iBlock).classOutputFileLoad(iTrial) && (GetSecs < tClassOutputFileTimeout))
                    [blockData(iBlock).classOutputFileLoad(iTrial) blockData(iBlock).classOutputFile{iTrial}] = GetSpecificClassOutputFile(classOutputDir,volCounter-1); %#ok<AGROW>
                end
                
                %load classifier output file
                if blockData(iBlock).classOutputFileLoad(iTrial)
                    tempStruct = load([classOutputDir '/' blockData(iBlock).classOutputFile{iTrial}]);
                    blockData(iBlock).categsep(iTrial) = tempStruct.classOutput; %#ok<AGROW>
                else
                    blockData(iBlock).classOutputFile{iTrial} = 'notload'; %#ok<AGROW>
                end
                
                %constrain the proportion of attended image
                if isnan(blockData(iBlock).categsep(iTrial)) %attImgProp for that trial for some reason was NaN
                    tempLastClassOutput = find(~isnan(blockData(iBlock).categsep),1,'last');
                    if ~isempty(tempLastClassOutput)
                        blockData(iBlock).attImgProp(iTrial+1) = blockData(iBlock).attImgProp(tempLastClassOutput); %#ok<AGROW>
                    else
                        blockData(iBlock).attImgProp(iTrial+1) = attImgPropPhase2; %#ok<AGROW>
                    end
                     %******* SET DEMO AMOUNTS--DELETE THIS AFTERWARDS!!! ****
                    vals = linspace(0,.8,25);
                    blockData(iBlock).attImgProp(iTrial+1) = vals(iTrialOdd);
                     %******* SET DEMO AMOUNTS--DELETE THIS AFTERWARDS!!! ****
                else
                    blockData(iBlock).attImgProp(iTrial+1) = steepness./(1+exp(-gain*(blockData(iBlock).categsep(iTrial)-x_shift)))+y_shift; %#ok<AGROW>
                    
                end
                
                %set for next trial
                if ((iTrial+2)<blockData(iBlock).trialsPerBlock)
                    blockData(iBlock).attImgProp(iTrial+2) = blockData(iBlock).attImgProp(iTrial+1); %#ok<AGROW>
                end
                
                %smooth the trials
                if iTrialOdd == 2
                    blockData(iBlock).smoothAttImgProp(2,iTrialOdd) = .5*blockData(iBlock).attImgProp(2,iTrialOdd-1)+.5*blockData(iBlock).attImgProp(2,iTrialOdd); %#ok<AGROW>
                else
                    blockData(iBlock).smoothAttImgProp(2,iTrialOdd) = (1/3)*blockData(iBlock).attImgProp(2,iTrialOdd-2)+(1/3)*blockData(iBlock).attImgProp(2,iTrialOdd-1)+(1/3)*blockData(iBlock).attImgProp(2,iTrialOdd); %#ok<AGROW>
                end
                
                %set for next trial
                if ((iTrial+2)<=blockData(iBlock).trialsPerBlock)
                    blockData(iBlock).smoothAttImgProp(iTrial+2) = blockData(iBlock).smoothAttImgProp(iTrial+1); %#ok<AGROW>
                end
            else
                blockData(iBlock).classOutputFile{iTrial} = '12orev'; %#ok<AGROW>
            end
        else
            if ((iTrial+1)<=blockData(iBlock).trialsPerBlock)
                blockData(iBlock).attImgProp(iTrial+1) = attImgPropPhase2; %#ok<AGROW>
                blockData(iBlock).smoothAttImgProp(iTrial+1)= attImgPropPhase2; %#ok<AGROW>
            end
            if ((iTrial+2)<=blockData(iBlock).trialsPerBlock-2)
                blockData(iBlock).attImgProp(iTrial+2) = attImgPropPhase2; %#ok<AGROW>
                blockData(iBlock).smoothAttImgProp(iTrial+2)= attImgPropPhase2; %#ok<AGROW>
            end
          
            blockData(iBlock).classOutputFile{iTrial} = 'notrt'; %#ok<AGROW>
            blockData(iBlock).classOutputFile{iTrial} = NaN; %#ok<AGROW>
        end
            
        % print trial results
        fprintf(dataFile,'%d\t%d\t%s\t%s\t%d\t%.3f\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%.3f\t%d\t%d\t%.3f\t%.3f\t%.3f\n',runNum,iBlock,typeStr{blockData(iBlock).type},categStr{blockData(iBlock).attCateg},iTrial,blockData(iBlock).actualtrialonsets(iTrial)-blockData(iBlock).plannedtrialonsets(iTrial),blockData(iBlock).categs{SCENE}(iTrial),blockData(iBlock).categs{FACE}(iTrial),blockData(iBlock).images{SCENE}(iTrial),blockData(iBlock).images{FACE}(iTrial),blockData(iBlock).corrresps(iTrial),blockData(iBlock).resps(iTrial),blockData(iBlock).accs(iTrial),blockData(iBlock).rts(iTrial),blockData(iBlock).volCounter(iTrial),blockData(iBlock).classOutputFileLoad(iTrial),blockData(iBlock).categsep(iTrial),blockData(iBlock).attImgProp(iTrial),blockData(iBlock).smoothAttImgProp(iTrial));
        fprintf('%d\t%d\t%s\t%s\t%d\t%.3f\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%.3f\t%d\t%d\t%.3f\t%.3f\t%.3f\n',runNum,iBlock,typeStr{blockData(iBlock).type},categStr{blockData(iBlock).attCateg},iTrial,blockData(iBlock).actualtrialonsets(iTrial)-blockData(iBlock).plannedtrialonsets(iTrial),blockData(iBlock).categs{SCENE}(iTrial),blockData(iBlock).categs{FACE}(iTrial),blockData(iBlock).images{SCENE}(iTrial),blockData(iBlock).images{FACE}(iTrial),blockData(iBlock).corrresps(iTrial),blockData(iBlock).resps(iTrial),blockData(iBlock).accs(iTrial),blockData(iBlock).rts(iTrial),blockData(iBlock).volCounter(iTrial),blockData(iBlock).classOutputFileLoad(iTrial),blockData(iBlock).categsep(iTrial),blockData(iBlock).attImgProp(iTrial),blockData(iBlock).smoothAttImgProp(iTrial));

    end % trial loop
    
    volCounter = volCounter+2;
    
    while ((GetSecs-blockData(iBlock).actualtrialonsets(iTrial) < stimDur))
        1;
    end
    
    Screen('FillRect',mainWindow,backColor);
    Screen(mainWindow,'FillOval',fixColor,fixDotRect);
    Screen('Flip',mainWindow);
    
end % phase 2 block loop

WaitSecs(2);

%% save

save([dataHeader '/blockdata_' num2str(runNum) '_' datestr(now,30)],'blockData','runStart');

% clean up and go home
sca;
ListenChar(1);
fclose('all');
end
