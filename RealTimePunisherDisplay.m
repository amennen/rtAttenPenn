function [blockData] = RealTimePunisherDisplay(subjectNum,subjectName,matchNum,runNum,useButtonBox,fMRI,rtData,debug)
% function [blockData] = RealTimePunisherDisplay(subjectNum,subjectName,runNum,useButtonBox,fMRI,rtData,debug)
%
% Face/house attention experiment with real-time classifier feedback
%
%
% REQUIRED INPUTS:
% - subjectNum:  participant number [any integer]
%                if subjectNum = 0, no information will be saved
% - subjectName: ntblab subject naming convention [MMDDYY#_REALTIME02]
% - matchNum:    if subject is yoked to a subject & which subject
% - runNum:      run number [any integer]
% - useButtonBox:whether using skyra realtime computer [1/0]
% - fMRI:        whether collecting fMRI data [scannumber if yes/0 if not]q5
% - rtData:  whether to give feedback in realtime [1/0]
% - debug:       whether debugging [1/0]
%
% OUTPUTS
% - testTiming: elapsed time for each iteration of SVM testing
% - blockData:
%
% Written by: Nick Turk-Browne
% Editied by: Megan deBettencourt
% Version: 2.0
% Last modified: 10/14/11

%% check inputs
KbName('UnifyKeyNames');
%check that there is a sufficient number of inputs
if nargin < 8
    error('8 inputs are required: subjectNum, subjectName, matchNum, runNum, useButtonBox, fMRI, rtData, debug');
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

if (useButtonBox~=1) && (useButtonBox~=0)
    error('useButtonBox must be either 1 (if at scanner) or 0 (if not)')
end

if (rtData~=1) && (rtData~=0)
    error('rtData must be either 1 (if returning feedback) or 0 (if not)')
end

if (debug~=1) && (debug~=0)
    error('debug must be either 1 (if debugging) or 0 (if not)')
end


%% Boilerplate

if (~debug) %so that when debugging you can do other things
    %Screen('Preference', 'SkipSyncTests', 1);
    
    
    ListenChar(2);  %prevent command window output
    HideCursor;     %hide mouse cursor    
else
    Screen('Preference', 'SkipSyncTests', 1);
end

seed = sum(100*clock); %get random seed
RandStream.setGlobalStream(RandStream('mt19937ar','seed',seed));%set seed

% if strcmp(computer,'MACI');
%     %dataHeader = ['data/' num2str(subjectNum)];
% elseif strcmp(computer,'PCWIN')
%     %dataHeader = ['data/' num2str(subjectNum)];
% elseif findstr(computer,'64')
%     error('psychtoolbox requires 64-bit OS, you are on: %s\n',computer);
% else
%     error('this code is only written to run on macs, not %s\n',computer);
% end

if rtData
    imgDir = ['/mnt/rtexport/RTexport_Current/' datestr(now,10) datestr(now,5) datestr(now,7) '.' subjectName '.' subjectName '/'];
else
    %imgDir = ['/Volumes/ntb/projects/punisher01/subjects/' subjectName '/data/dicom/']; 
    imgDir = ['/Volumes/KINGSTON/dicomdata/20121025.1025121_punisher02.1025121_punisher02/'];
end

%check that the files exist
if fMRI
    assert(logical(exist(imgDir,'dir')));
    fprintf('fMRI files being read from: %s\n',imgDir);
end


%initialize system time calls
GetSecs;

%% Experimental Parameters

%stimulus number parameters
categStr = {'sc','fa'};
typeStr = {'stab','rtfd'};

% block timing
instructOn = 0;     % secs
instructDur = 1;    % secs
instructTRnum = 1;  % TRs
%fixationOn = TR-.3; % secs

% trial timing
stimDur = 1;        % secs
respWindow = .85;   % secs
deltat = .1;        % secs
allowance = .05;    % secs

% display parameters
textColor = 0;
textFont = 'Arial';
textSize = 25;
textSpacing = 25;
fixColor = 0;
respColor = 255;
backColor = 127;
imageSize = 256; % assumed square %MdB check image size
fixationSize = 4;% pixels
progWidth = 400; % image loading progress bar
progHeight = 20;

% how to average the faces and scenes
attImgPropPhase1 = .5;
attImgPropPhase2 = .5;

% function mapping classifier output to attended image proportion
gain = 3;
x_shift = .2;
y_shift = .15;
steepness = .9;

ScreenResX = 1280;
ScreenResY = 720;

%trainedModelFile = 'trainingcomplete.mat';


%% Response Mapping and Counterbalancing

% skyra: use current design button box (keys 1,2,3,4)
KbName('UnifyKeyNames');
LEFT = KbName('1!');
DEVICENAME = 'Current Designs, Inc. 932';
if useButtonBox && (~debug)
    [index devName] = GetKeyboardIndices;
    for device = 1:length(index)
        if strcmp(devName(device),DEVICENAME)
            DEVICE = index(device);
        end
    end
else
    DEVICE = -1;
end
KbName('UnifyKeyNames')
TRIGGER = '5%';
TRIGGER_keycode = getKeys(TRIGGER);
% counterbalancing response mapping based on subject assignment
% correctResp spells out the responses for {INDOOR,OUTDOOR,MALE,FEMALE}
respMap = mod(subjectNum-1,4)+1;
switch (respMap)
    case 1
        sceneInstruct = 'Places: respond if it is an indoor place. DO NOT respond if it is an outdoor place';
        faceInstruct = 'Faces: respond if it is a male face. DO NOT respond if it is a female face';
        sceneShorterInstruct = 'indoor places';
        faceShorterInstruct = 'male faces';
    case 2
        sceneInstruct = 'Places: respond if it is an outdoor place. DO NOT respond if it is an indoor place';
        faceInstruct = 'Faces: respond if it is a female face. DO NOT respond if it is a male face';
        sceneShorterInstruct = 'outdoor places';
        faceShorterInstruct = 'female faces';
    case 3
        sceneInstruct = 'Places: respond if it is an outdoor place. DO NOT respond if it is an indoor place';
        faceInstruct = 'Faces: respond if it is a male face. DO NOT respond if it is a female face';
        sceneShorterInstruct = 'outdoor places';
        faceShorterInstruct = 'male faces';
    case 4
        sceneInstruct = 'Places: respond if it is an indoor place. DO NOT respond if it is an outdoor place';
        faceInstruct = 'Faces: respond if it is a female face. DO NOT respond if it is a male face';
        sceneShorterInstruct = 'indoor places';
        faceShorterInstruct = 'female faces';
    otherwise
        error('Impossible response mapping!');
end

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
%     screenX = 800;
%     screenY = 800;
%     %to ensure that the images are standardized (they take up the same degrees of the visual field) for all subjects
%     if (screenX ~= ScreenResX) || (screenY ~= ScreenResY)
%         fprintf('The screen dimensions may be incorrect. For screenNum = %d,screenX = %d (not 1152) and screenY = %d (not 864)',screenNum, screenX, screenY);
%     end
end
windowSize.degrees = [51 30];
resolution = Screen('Resolution', screenNum);
windowSize.pixels = [resolution.width/2 resolution.height];
screenX = windowSize.pixels(1);
screenY = windowSize.pixels(2);
%create main window
% ACM: took out if statement because specifying top doesn't work on penn
% comp
%if (useButtonBox)%scanner display monitor has error with inputs of screen size
%    mainWindow = Screen(screenNum,'OpenWindow',backColor);
%else
    mainWindow = Screen(screenNum,'OpenWindow',backColor,[0 0 screenX screenY]);
%end

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

if matchNum == 0
    dataHeader = ['data/' num2str(subjectNum)];
else
    dataHeader = ['data/' num2str(subjectNum) '_match'];
end
runHeader = [dataHeader '/run' num2str(runNum)];
classOutputDir = [runHeader '/classoutput'];
fn = ls([runHeader '/blockdatadesign_' num2str(runNum) '_*']);
load(deblank(fn));

if any([blockData.type]==2) %#ok<NODEF>
    restInstruct = 'The feedback blocks will start soon';
else
    restInstruct = 'The next blocks will start soon';
end
restDur = 4;

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
                
                % update progress bar
                Screen('FrameRect',mainWindow,0,progRect,10);
                Screen('FillRect',mainWindow,0,progRect);
                Screen('FillRect',mainWindow,[255 0 0],progRect-[0 0 round((1-img/numImages(categ))*progWidth) 0]);
                Screen('Flip',mainWindow);
                
                % read images
                images{categ,img} = imread(dirList{categ}(img).name); %#ok<AGROW>
                tempFFT = fft2(images{categ,img});
                imagePower{categ,img} = abs(tempFFT); %#ok<AGROW>
                imagePhase{categ,img} = angle(tempFFT); %#ok<AGROW>
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
    if (temp == 'q')
        break;
    end
end
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);


%% hack
% if strcmp(computer,'PCWIN');
%     
%     % clear screen
%     Screen(mainWindow,'FillRect',backColor);
%     Screen('Flip',mainWindow);
%     FlushEvents('keyDown');
%     
%     % show instructions
%     runInstruct{1} = sceneInstruct;
%     runInstruct{2} = faceInstruct;
%     
%     for instruct=1:length(runInstruct)
%         tempBounds = Screen('TextBounds',mainWindow,runInstruct{instruct});
%         Screen('drawtext',mainWindow,runInstruct{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
%         clear tempBounds;
%     end
%     Screen('Flip',mainWindow);
%     
%     % wait for experimenter to advance with 'q' key
%     FlushEvents('keyDown');
%     while(1)
%         temp = GetChar;
%         if (temp == 'q')
%             break;
%         end
%     end
%     Screen(mainWindow,'FillRect',backColor);
%     Screen('Flip',mainWindow);
% end


%% Start Experiment

% wait for initial trigger
Priority(MaxPriority(screenNum));
Screen(mainWindow,'FillRect',backColor);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
if (rtData )
   % if strcmp(computer,'MACI') % taking out because we're running on a linux!
        %runStart = WaitTRPulsePTB3_skyra(1);
        runStart = WaitTRPulse(TRIGGER_keycode,DEVICE);
   % else
   %     WaitSecs(.5);
   %     runStart = KbWait;
   % end
else
    runStart = GetSecs;
end
Screen('Flip',mainWindow);
Priority(0);

% prepare for trial sequence
fprintf(dataFile,'run\tblock\tbltyp\tblcat\ttrial\tonsdif\tpulse\tscat\tfcat\tsimg\tfimg\tcorresp\tresp\tacc\trt\tfile\tload\tcatsep\tattProp\tsmoothProp\n');
fprintf('run\tblock\tbltyp\tblcat\ttrial\tonsdif\tpulse\tscat\tfcat\tsimg\tfimg\tcorresp\tresp\tacc\trt\tfile\tload\tcatsep\tattProp\tsmoothProp\n');

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
            
        % prep images
        for half=[SCENE FACE]
            % get current images
            tempPower{half} = imagePower{blockData(iBlock).categs{half}(iTrial),blockData(iBlock).images{half}(iTrial)}; %#ok<AGROW>
            tempImagePhase{half} = imagePhase{blockData(iBlock).categs{half}(iTrial),blockData(iBlock).images{half}(iTrial)}; %#ok<AGROW>
            tempImage{half} = real(ifft2(tempPower{half}.*exp(sqrt(-1)*tempImagePhase{half}))); %#ok<AGROW>
        end
       
        %update imgProp value
        blockData(iBlock).attImgProp(iTrial)=attImgPropPhase1; %#ok<AGROW>
        
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
