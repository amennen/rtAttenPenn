function [blockData] = RealTimePunisherInstruct(subjectNum,subjectName,matchNum,runNum,debug)
% function [blockData] = RealTimeBehavInstruct(subjectNum,subjectName,matchNum,runNum,debug)
%
% These are the instructions for the behavioral version of the experiment. 
%
%
% REQUIRED INPUTS:
% - subjectNum:  participant number [any integer]
%                if subjectNum = 0, no information will be saved
% - subjectName: subject initials for behavioral studies, ntblab naming
%                convention for fmri scan [mmddyy#_rtat01]
% - matchNum:    if the subject is matched to another subject [if so, input subjectNum, if not, input 0]
% - runNum:      run number [any integer]
% - debug:       whether debugging [1/0]
%
% OUTPUTS
% - blockData:
%
% Written by:  Megan deBettencourt
% Version: 1.0
% Last modified: 10/22/12

%% check inputs

%check that there is a sufficient number of inputs
if nargin < 5
    error('5 inputs are required: subjectNum, subjectName, matchNum, runNum, debug');
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

if (debug~=1) && (debug~=0)
    error('debug must be either 1 (if debugging) or 0 (if not)')
end


%% Boilerplate

if (debug) %so that when debugging you can do other things
    Screen('Preference', 'SkipSyncTests', 1);
else
    %ListenChar(2);  %prevent command window output
    HideCursor;     %hide mouse cursor    
end

seed = sum(100*clock); %get random seed
RandStream.setDefaultStream(RandStream('mt19937ar','seed',seed));%set seed

%assert(strcmp(computer,'PCWIN'),'this code is only written to run on windows');
assert(isempty(findstr(computer,'64')),'this code is only written to run on 32 bit matlab');
    
%initialize system time calls
GetSecs;

%% Experimental Parameters

%stimulus number parameters
categStr = {'sc','fa'};

% block timing
instructOn = 0;     % secs
instructDur = 1;    % secs
instructTRnum = 1;  % TRs

% trial timing
stimDur = 1;        % secs
respWindowPractice = 10;   % secs
respWindow = .85;   % secs

% display parameters
textColor = 0;
textFont = 'Arial';
textSize = 16;
textSpacing = 25;
fixColor = 0;
respColor = 255;
backColor = 127;
imageSize = 256; % assumed square %MdB check image size
fixationSize = 4;% pixels
progWidth = 400; % image loading progress bar
progHeight = 20;

% how to average the faces and scenes
attImgProp = .5;

ScreenResX = 1600;
ScreenResY = 900;


%% Response Mapping and Counterbalancing

% skyra: use current design button box (keys 1,2,3,4)
LEFT = KbName('1!');
DEVICE = -1;

% counterbalancing response mapping based on subject assignment
% correctResp spells out the responses for {INDOOR,OUTDOOR,MALE,FEMALE}
if matchNum==0
    respMap = mod(subjectNum-1,4)+1;
else
    respMap = mod(matchNum-1,4)+1;
end

switch (respMap)
    case 1
        sceneInstruct{1} = 'For places you will be looking for INDOOR places. If you see an indoor place in the photo, press the 1 key.';
        sceneInstruct{2} = 'If you see an OUTDOOR place in the photo do not press anything.';
        sceneInstruct{3} = 'When you''re looking for indoor places you should IGNORE the faces. Faces will be irrelevant to the task';
        sceneSummaryInstruct = 'indoor places = 1';
        faceInstruct{1} = 'For faces you will be looking for MALE faces. If you see a male face in the photo, press the 1 key.';
        faceInstruct{2} = 'If you see a FEMALE face in the photo do not press anything.';
        faceInstruct{3} = 'When you''re looking for male faces you should IGNORE the places. Places will be irrelevant to the task';
        faceSummaryInstruct = 'male faces = 1';
        sceneShorterInstruct = 'indoor places';
        faceShorterInstruct = 'male faces';
    case 2
        sceneInstruct{1} = 'For places you will be looking for OUTDOOR places. If you see an outdoor place in the photo, press the 1 key.';
        sceneInstruct{2} = 'If you see an INDOOR place in the photo do not press anything.';
        sceneInstruct{3} = 'When you''re looking for outdoor places you should IGNORE the faces. Faces will be irrelevant to the task';
        sceneSummaryInstruct = 'outdoor places = 1';
        faceInstruct{1} = 'For faces you will be looking for FEMALE faces. If you see a female face in the photo, press the 1 key.';
        faceInstruct{2} = 'If you see a MALE face in the photo do not press anything.';
        faceInstruct{3} = 'When you''re looking for female faces you should IGNORE the places. Places will be irrelevant to the task';
        faceSummaryInstruct = 'female faces = 1';
        sceneShorterInstruct = 'outdoor places';
        faceShorterInstruct = 'female faces';
    case 3
        sceneInstruct{1} = 'For places you will be looking for OUTDOOR places. If you see an outdoor place in the photo, press the 1 key.';
        sceneInstruct{2} = 'If you see an INDOOR place in the photo do not press anything.';
        sceneInstruct{3} = 'When you''re looking for indoor places you should IGNORE the faces. Faces will be irrelevant to the task';
        sceneSummaryInstruct = 'outdoor places = 1';
        faceInstruct{1} = 'For faces you will be looking for MALE faces. If you see a male face in the photo, press the 1 key.';
        faceInstruct{2} = 'If you see a FEMALE face in the photo do not press anything.';
        faceInstruct{3} = 'When you''re looking for male faces you should IGNORE the places. Places will be irrelevant to the task';
        faceSummaryInstruct = 'male faces = 1';
        sceneShorterInstruct = 'outdoor places';
        faceShorterInstruct = 'male faces';
    case 4
        sceneInstruct{1} = 'For places you will be looking for INDOOR places. If you see an indoor place in the photo, press the 1 key.';
        sceneInstruct{2} = 'If you see an OUTDOOR place in the photo do not press anything.';
        sceneInstruct{3} = 'When you''re looking for indoor places you should IGNORE the faces. Faces will be irrelevant to the task';
        sceneSummaryInstruct = 'indoor places = 1';
        faceInstruct{1} = 'For faces you will be looking for FEMALE faces. If you see a female face in the photo, press the 1 key.';
        faceInstruct{2} = 'If you see a MALE face in the photo do not press anything.';
        faceInstruct{3} = 'When you''re looking for female faces you should IGNORE the places. Places will be irrelevant to the task';
        faceSummaryInstruct = 'female faces = 1';
        sceneShorterInstruct = 'indoor places';
        faceShorterInstruct = 'female faces';
    otherwise
        error('Impossible response mapping!');
end

contInstruct = sprintf('Please hit q to continue');

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
    [screenX screenY] = Screen('WindowSize',screenNum);
    screenX = screenX/2;
    screenY = screenY/2;
else
    [screenX screenY] = Screen('WindowSize',screenNum);
    
    %to ensure that the images are standardized (they take up the same degrees of the visual field) for all subjects
    if (screenX ~= ScreenResX) || (screenY ~= ScreenResY)
        fprintf('The screen dimensions may be incorrect. For screenNum = %d,screenX = %d (not 1152) and screenY = %d (not 864)',screenNum, screenX, screenY);
    end
end

%create main window
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

if (~ispc)
    dataHeader = ['data/' num2str(subjectNum)];
    runHeader = [dataHeader '/run' num2str(runNum)];
    fn = ls([runHeader '/blockdatadesign_' num2str(runNum) '_*']);
    load(deblank(fn));
else
    if matchNum ==0
        dataHeader = ['data/' num2str(subjectNum)];
    else
        dataHeader = ['data/' num2str(matchNum) '_match'];
    end
    runHeader = [dataHeader '/run' num2str(runNum)];
    fn = ls([runHeader '/blockdatadesign_' num2str(runNum) '_*']);
    assert(~isempty(fn),'have not created the block design');
    load([runHeader '/' deblank(fn)]);
end

%% Load Images

%cd instructstim;
cd instructstim
for categ=1:4
    
    % move into the right folder
    if (categ == INDOOR)
        cd indoor;
    elseif (categ == OUTDOOR)
        cd outdoor;
    elseif (categ == MALE)
        cd male_neut;
    elseif (categ == FEMALE)
        cd female_neut;
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

%% Welcome instructions

% clear screen
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);
FlushEvents('keyDown');

% show instructions
runInstruct{1} = 'Welcome! In this experiment you will be shown photos of overlapping faces and places';
runInstruct{2} = 'You will be told to look at either the face or the place';
runInstruct{3} = ' ';
runInstruct{4} = 'First let''s try the face task';
runInstruct{5} = contInstruct;

for instruct=1:length(runInstruct)
    tempBounds = Screen('TextBounds',mainWindow,runInstruct{instruct});
    Screen('drawtext',mainWindow,runInstruct{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow);
pause;

%% face instruct
% clear screen
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);
FlushEvents('keyDown');

% show instructions
clearvars runInstruct;
runInstruct{1} = faceInstruct{1};
runInstruct{2} = faceInstruct{2};
runInstruct{3} = ' ';
runInstruct{4} = faceInstruct{3};
runInstruct{5} = ' ';
runInstruct{6} = ' ';
runInstruct{7} = contInstruct;

for instruct=1:length(runInstruct)
    tempBounds = Screen('TextBounds',mainWindow,runInstruct{instruct});
    Screen('drawtext',mainWindow,runInstruct{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow);
pause;

%% face instruct #2 

% clear screen
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);
FlushEvents('keyDown');

% show instructions
clearvars runInstruct;
runInstruct{1} = faceSummaryInstruct;
runInstruct{2} = ' ';
runInstruct{3} = ' ';
runInstruct{4} = 'Please repeat these instructions in your own words to the person helping you';

for instruct=1:length(runInstruct)
    tempBounds = Screen('TextBounds',mainWindow,runInstruct{instruct});
    Screen('drawtext',mainWindow,runInstruct{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow);
pause;

%% face stim

% show fixation
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tFix = Screen('Flip',mainWindow);

for half=[SCENE FACE]
    % get current images
    tempPower{half} = imagePower{mode(blockData(1).categs{half}),1}; %#ok<NODEF>
    tempImagePhase{half} = imagePhase{mode(blockData(1).categs{half}),1}; %#ok<AGROW>
    tempImage{half} = real(ifft2(tempPower{half}.*exp(sqrt(-1)*tempImagePhase{half}))); %#ok<AGROW>
end
        
% generate image
fullImage = uint8(.5*tempImage{SCENE}+.5*tempImage{FACE});
        
% make textures
imageTex = Screen('MakeTexture',mainWindow,fullImage);
Screen('PreloadTextures',mainWindow,imageTex);
        
% wait for trigger and show image
FlushEvents('keyDown');
Priority(MaxPriority(screenNum));
Screen('FillRect',mainWindow,backColor);
Screen('DrawTexture',mainWindow,imageTex,imageRect,centerRect);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tStim = Screen('Flip',mainWindow,tFix+1);
tRespTimeout = tStim+respWindowPractice; %response timeout
stimOn = 1;
rts = NaN;

while(GetSecs < tRespTimeout)
    
    % check for responses if none received yet
    if isnan(rts)
        [keyIsDown, secs, keyCode] = KbCheck(DEVICE); % -1 checks all keyboards
        if keyIsDown
            if (keyCode(LEFT))
                rts = secs-tStim; 
                resps = find(keyCode,1); 
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

Screen('FillRect',mainWindow,backColor);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tFix = Screen('Flip',mainWindow,tStim+TR);

%% Welcome instructions

% clear screen
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);
FlushEvents('keyDown');

% show instructions
clearvars runInstruct;
runInstruct{1} = 'Now let''s try the place task';
runInstruct{2} = ' ';
runInstruct{3} = sceneInstruct{1};
runInstruct{4} = sceneInstruct{2};
runInstruct{5} = ' ';
runInstruct{6} = sceneInstruct{3};
runInstruct{7} = ' ';
runInstruct{8} = contInstruct;

for instruct=1:length(runInstruct)
    tempBounds = Screen('TextBounds',mainWindow,runInstruct{instruct});
    Screen('drawtext',mainWindow,runInstruct{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow,tFix+TR);
pause;


%% Scene instructions

% clear screen
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);
FlushEvents('keyDown');

% show instructions
clearvars runInstruct;
runInstruct{1} = sceneSummaryInstruct;
runInstruct{2} = ' ';
runInstruct{3} = 'Please repeat these instructions in your own words to the person helping you';

for instruct=1:length(runInstruct)
    tempBounds = Screen('TextBounds',mainWindow,runInstruct{instruct});
    Screen('drawtext',mainWindow,runInstruct{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow,tFix+TR);
pause;

%% scene stim

% show fixation
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tFix = Screen('Flip',mainWindow);

for half=[SCENE FACE]
    % get current images
    tempPower{half} = imagePower{mode(blockData(1).categs{half}),1}; %#ok<NODEF>
    tempImagePhase{half} = imagePhase{mode(blockData(1).categs{half}),1}; %#ok<AGROW>
    tempImage{half} = real(ifft2(tempPower{half}.*exp(sqrt(-1)*tempImagePhase{half}))); %#ok<AGROW>
end
        
% generate image
fullImage = uint8(.5*tempImage{SCENE}+.5*tempImage{FACE});
        
% make textures
imageTex = Screen('MakeTexture',mainWindow,fullImage);
Screen('PreloadTextures',mainWindow,imageTex);
        
% wait for trigger and show image
FlushEvents('keyDown');
Priority(MaxPriority(screenNum));
Screen('FillRect',mainWindow,backColor);
Screen('DrawTexture',mainWindow,imageTex,imageRect,centerRect);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tStim = Screen('Flip',mainWindow,tFix+1);
tRespTimeout = tStim+respWindowPractice; %response timeout
stimOn = 1;
rts = NaN;

while(GetSecs < tRespTimeout)
    
    % check for responses if none received yet
    if isnan(rts)
        [keyIsDown, secs, keyCode] = KbCheck(DEVICE); % -1 checks all keyboards
        if keyIsDown
            if (keyCode(LEFT))
                rts = secs-tStim; 
                resps = find(keyCode,1); 
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

Screen('FillRect',mainWindow,backColor);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tFix = Screen('Flip',mainWindow,tStim+TR);


%% scene instruct 2

% clear screen
Screen(mainWindow,'FillRect',backColor);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
Screen('Flip',mainWindow);
FlushEvents('keyDown');

% show instructions
fixInstruct{1} = 'During the experiment, please look at the dot in the center';
fixInstruct{2} = 'You may have noticed that it will change from black to white when you respond';
fixInstruct{3} = ' ';
fixInstruct{4} = 'Please note that you will need to respond for most images';
fixInstruct{5} = ['That means, most images will be either ' sceneShorterInstruct ' or ' faceShorterInstruct ];
fixInstruct{5} = ' ';
fixInstruct{6} = contInstruct;

for instruct=1:length(fixInstruct)
    tempBounds = Screen('TextBounds',mainWindow,fixInstruct{instruct});
    Screen('drawtext',mainWindow,fixInstruct{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
tFix = Screen('Flip',mainWindow,tFix+TR);
pause;

%% scene instruct 2

% clear screen
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);
FlushEvents('keyDown');

% show instructions
runInstruct{1} = 'Now let''s try the scene task again.';
runInstruct{2} = 'This time, the photos will be presented for a much shorter amount of time';
runInstruct{3} = 'Also during the experiment, the only instructions you''ll see is:';
runInstruct{4} = ' ';
runInstruct{5} = sceneShorterInstruct;
runInstruct{6} = ' ';
runInstruct{7} = contInstruct;

for instruct=1:length(runInstruct)
    tempBounds = Screen('TextBounds',mainWindow,runInstruct{instruct});
    Screen('drawtext',mainWindow,runInstruct{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow,tFix+TR);
pause;

%% scene stim

% clear screen
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);
FlushEvents('keyDown');

% show instructions
clearvars runInstruct;
runInstruct{1} = sceneShorterInstruct;

for instruct=1:length(runInstruct)
    tempBounds = Screen('TextBounds',mainWindow,runInstruct{instruct});
    Screen('drawtext',mainWindow,runInstruct{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
tInstruct = Screen('Flip',mainWindow);

% show fixation
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tFix = Screen('Flip',mainWindow,tInstruct+instructDur);

for half=[SCENE FACE]
    % get current images
    tempPower{half} = imagePower{mode(blockData(1).categs{half}),2}; %#ok<NODEF>
    tempImagePhase{half} = imagePhase{mode(blockData(1).categs{half}),2}; %#ok<AGROW>
    tempImage{half} = real(ifft2(tempPower{half}.*exp(sqrt(-1)*tempImagePhase{half}))); %#ok<AGROW>
end
        
% generate image
fullImage = uint8(.5*tempImage{SCENE}+.5*tempImage{FACE});
        
% make textures
imageTex = Screen('MakeTexture',mainWindow,fullImage);
Screen('PreloadTextures',mainWindow,imageTex);
        
% wait for trigger and show image
FlushEvents('keyDown');
Priority(MaxPriority(screenNum));
Screen('FillRect',mainWindow,backColor);
Screen('DrawTexture',mainWindow,imageTex,imageRect,centerRect);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tStim = Screen('Flip',mainWindow,tFix+1);
tRespTimeout = tStim+respWindow; %response timeout
stimOn = 1;
rts = NaN;

while(GetSecs < tRespTimeout)
    
    % check for responses if none received yet
    if isnan(rts)
        [keyIsDown, secs, keyCode] = KbCheck(DEVICE); % -1 checks all keyboards
        if keyIsDown
            if (keyCode(LEFT))
                rts = secs-tStim; 
                resps = find(keyCode,1); 
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

Screen('FillRect',mainWindow,backColor);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tFix = Screen('Flip',mainWindow,tStim+TR);
WaitSecs(TR);

%% face instruct 2

% clear screen
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);
FlushEvents('keyDown');

% show instructions
clearvars runInstruct;
runInstruct{1} = 'Now let''s try the face task the same way';
runInstruct{2} = ' ';
runInstruct{3} = contInstruct;

for instruct=1:length(runInstruct)
    tempBounds = Screen('TextBounds',mainWindow,runInstruct{instruct});
    Screen('drawtext',mainWindow,runInstruct{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow,tFix+TR);
pause;

%% face stim

% clear screen
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);
FlushEvents('keyDown');

% show instructions
clearvars runInstruct;
runInstruct{1} = faceShorterInstruct;

for instruct=1:length(runInstruct)
    tempBounds = Screen('TextBounds',mainWindow,runInstruct{instruct});
    Screen('drawtext',mainWindow,runInstruct{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
tInstruct = Screen('Flip',mainWindow);

% show fixation
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tFix = Screen('Flip',mainWindow,tInstruct+instructDur);

for half=[SCENE FACE]
    % get current images
    tempPower{half} = imagePower{mode(blockData(1).categs{half}),3}; %#ok<NODEF>
    tempImagePhase{half} = imagePhase{mode(blockData(1).categs{half}),3}; %#ok<AGROW>
    tempImage{half} = real(ifft2(tempPower{half}.*exp(sqrt(-1)*tempImagePhase{half}))); %#ok<AGROW>
end
        
% generate image
fullImage = uint8(.5*tempImage{SCENE}+.5*tempImage{FACE});
        
% make textures
imageTex = Screen('MakeTexture',mainWindow,fullImage);
Screen('PreloadTextures',mainWindow,imageTex);
        
% wait for trigger and show image
FlushEvents('keyDown');
Priority(MaxPriority(screenNum));
Screen('FillRect',mainWindow,backColor);
Screen('DrawTexture',mainWindow,imageTex,imageRect,centerRect);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tStim = Screen('Flip',mainWindow,tFix+1);
tRespTimeout = tStim+respWindow; %response timeout
stimOn = 1;
rts = NaN;

while(GetSecs < tRespTimeout)
    
    % check for responses if none received yet
    if isnan(rts)
        [keyIsDown, secs, keyCode] = KbCheck(DEVICE); % -1 checks all keyboards
        if keyIsDown
            if (keyCode(LEFT))
                rts = secs-tStim; 
                resps = find(keyCode,1); 
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

Screen('FillRect',mainWindow,backColor);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tFix = Screen('Flip',mainWindow,tStim+TR);
WaitSecs(TR);

%% face instruct 3

% clear screen
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);
FlushEvents('keyDown');

% show instructions
clearvars runInstruct;
runInstruct{1} = 'During the real tasks, you will see instruction text followed by many images continuously';
runInstruct{2} = 'Let''s practice that now';
runInstruct{3} = ' ';
runInstruct{4} = contInstruct;

for instruct=1:length(runInstruct)
    tempBounds = Screen('TextBounds',mainWindow,runInstruct{instruct});
    Screen('drawtext',mainWindow,runInstruct{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow,tFix+TR);
pause;

%% face stim

% clear screen
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);
FlushEvents('keyDown');

% show instructions
clearvars runInstruct;
runInstruct{1} = faceShorterInstruct;

for instruct=1:length(runInstruct)
    tempBounds = Screen('TextBounds',mainWindow,runInstruct{instruct});
    Screen('drawtext',mainWindow,runInstruct{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
tInstruct = Screen('Flip',mainWindow);

% show fixation
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tFix = Screen('Flip',mainWindow,tInstruct+instructDur);

iTrial = 3;
for half=[SCENE FACE]
    % get current images
    tempPower{half} = imagePower{mode(blockData(1).categs{half}),iTrial}; %#ok<NODEF>
    tempImagePhase{half} = imagePhase{mode(blockData(1).categs{half}),iTrial}; %#ok<AGROW>
    tempImage{half} = real(ifft2(tempPower{half}.*exp(sqrt(-1)*tempImagePhase{half}))); %#ok<AGROW>
end
        
% generate image
fullImage = uint8(.5*tempImage{SCENE}+.5*tempImage{FACE});
        
% make textures
imageTex = Screen('MakeTexture',mainWindow,fullImage);
Screen('PreloadTextures',mainWindow,imageTex);
        
% wait for trigger and show image
FlushEvents('keyDown');
Priority(MaxPriority(screenNum));
Screen('FillRect',mainWindow,backColor);
Screen('DrawTexture',mainWindow,imageTex,imageRect,centerRect);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tStim = Screen('Flip',mainWindow,tFix+1);
tRespTimeout = tStim+respWindow; %response timeout
stimOn = 1;
rts = NaN;

while(GetSecs < tRespTimeout)
    
    % check for responses if none received yet
    if isnan(rts)
        [keyIsDown, secs, keyCode] = KbCheck(DEVICE); % -1 checks all keyboards
        if keyIsDown
            if (keyCode(LEFT))
                rts = secs-tStim; 
                resps = find(keyCode,1); 
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

for iTrial = 4:8;
    for half=[SCENE FACE]
        % get current images
        if (half == FACE) && (iTrial==6)
            x= blockData(1).categs{half}(find(blockData(1).categs{half}~=mode(blockData(1).categs{half}),1,'first'));
        else
            x = mode(blockData(1).categs{half});
        end
        tempPower{half} = imagePower{x,iTrial}; %#ok<NODEF>
        tempImagePhase{half} = imagePhase{x,iTrial}; %#ok<AGROW>
        tempImage{half} = real(ifft2(tempPower{half}.*exp(sqrt(-1)*tempImagePhase{half}))); %#ok<AGROW>    
    end
    
    % generate image
    fullImage = uint8(.5*tempImage{SCENE}+.5*tempImage{FACE});
    
    % make textures
    imageTex = Screen('MakeTexture',mainWindow,fullImage);
    Screen('PreloadTextures',mainWindow,imageTex);
    
    % wait for trigger and show image
    FlushEvents('keyDown');
    Priority(MaxPriority(screenNum));
    Screen('FillRect',mainWindow,backColor);
    Screen('DrawTexture',mainWindow,imageTex,imageRect,centerRect);
    Screen(mainWindow,'FillOval',fixColor,fixDotRect);
    tStim = Screen('Flip',mainWindow,tStim+stimDur);
    tRespTimeout = tStim+respWindow; %response timeout
    stimOn = 1;
    rts = NaN;
    
    while(GetSecs < tRespTimeout)
        
        % check for responses if none received yet
        if isnan(rts)
            [keyIsDown, secs, keyCode] = KbCheck(DEVICE); % -1 checks all keyboards
            if keyIsDown
                if (keyCode(LEFT))
                    rts = secs-tStim;
                    resps = find(keyCode,1);
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
end

Screen('FillRect',mainWindow,backColor);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tFix = Screen('Flip',mainWindow,tStim+stimDur);
WaitSecs(1);

%% scene instruct 3

% clear screen
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);
FlushEvents('keyDown');

% show instructions
clearvars runInstruct;
runInstruct{1} = 'Let''s practice that again for the places';
runInstruct{2} = ' ';
runInstruct{3} = ' ';
runInstruct{4} = contInstruct;

for instruct=1:length(runInstruct)
    tempBounds = Screen('TextBounds',mainWindow,runInstruct{instruct});
    Screen('drawtext',mainWindow,runInstruct{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow,tFix+TR);
pause;

%% scene stim

% clear screen
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);
FlushEvents('keyDown');

% show instructions
clearvars runInstruct;
runInstruct{1} = sceneShorterInstruct;

for instruct=1:length(runInstruct)
    tempBounds = Screen('TextBounds',mainWindow,runInstruct{instruct});
    Screen('drawtext',mainWindow,runInstruct{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
tInstruct = Screen('Flip',mainWindow);

% show fixation
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tFix = Screen('Flip',mainWindow,tInstruct+instructDur);

iTrial = 3;
for half=[SCENE FACE]
    % get current images
    tempPower{half} = imagePower{mode(blockData(1).categs{half}),iTrial}; %#ok<NODEF>
    tempImagePhase{half} = imagePhase{mode(blockData(1).categs{half}),iTrial}; %#ok<AGROW>
    tempImage{half} = real(ifft2(tempPower{half}.*exp(sqrt(-1)*tempImagePhase{half}))); %#ok<AGROW>
end
        
% generate image
fullImage = uint8(.5*tempImage{SCENE}+.5*tempImage{FACE});
        
% make textures
imageTex = Screen('MakeTexture',mainWindow,fullImage);
Screen('PreloadTextures',mainWindow,imageTex);
        
% wait for trigger and show image
FlushEvents('keyDown');
Priority(MaxPriority(screenNum));
Screen('FillRect',mainWindow,backColor);
Screen('DrawTexture',mainWindow,imageTex,imageRect,centerRect);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tStim = Screen('Flip',mainWindow,tFix+1);
tRespTimeout = tStim+respWindow; %response timeout
stimOn = 1;
rts = NaN;

while(GetSecs < tRespTimeout)
    
    % check for responses if none received yet
    if isnan(rts)
        [keyIsDown, secs, keyCode] = KbCheck(DEVICE); % -1 checks all keyboards
        if keyIsDown
            if (keyCode(LEFT))
                rts = secs-tStim; 
                resps = find(keyCode,1); 
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

for iTrial = 4:8;
    for half=[SCENE FACE]
        % get current images
        if (half == SCENE) && (iTrial==5)
            x= blockData(1).categs{half}(find(blockData(1).categs{half}~=mode(blockData(1).categs{half}),1,'first'));
        else
            x = mode(blockData(1).categs{half});
        end
        tempPower{half} = imagePower{x,iTrial}; %#ok<NODEF>
        tempImagePhase{half} = imagePhase{x,iTrial}; %#ok<AGROW>
        tempImage{half} = real(ifft2(tempPower{half}.*exp(sqrt(-1)*tempImagePhase{half}))); %#ok<AGROW>    
    end
    
    % generate image
    fullImage = uint8(.5*tempImage{SCENE}+.5*tempImage{FACE});
    
    % make textures
    imageTex = Screen('MakeTexture',mainWindow,fullImage);
    Screen('PreloadTextures',mainWindow,imageTex);
    
    % wait for trigger and show image
    FlushEvents('keyDown');
    Priority(MaxPriority(screenNum));
    Screen('FillRect',mainWindow,backColor);
    Screen('DrawTexture',mainWindow,imageTex,imageRect,centerRect);
    Screen(mainWindow,'FillOval',fixColor,fixDotRect);
    tStim = Screen('Flip',mainWindow,tStim+stimDur);
    tRespTimeout = tStim+respWindow; %response timeout
    stimOn = 1;
    rts = NaN;
    
    while(GetSecs < tRespTimeout)
        
        % check for responses if none received yet
        if isnan(rts)
            [keyIsDown, secs, keyCode] = KbCheck(DEVICE); % -1 checks all keyboards
            if keyIsDown
                if (keyCode(LEFT))
                    rts = secs-tStim;
                    resps = find(keyCode,1);
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
end

Screen('FillRect',mainWindow,backColor);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tFix = Screen('Flip',mainWindow,tStim+stimDur);
WaitSecs(TR);

%% 

feedText{1} = 'Today we will be doing a task just like that.';
feedText{2} = ' ';
feedText{3} = 'The first part will be just as you practiced';
feedText{4} = 'For the second part, the first half will also be the same';
feedText{5} = 'But for the second hal of the second part, you will get feedback about how well you''re doing';
feedText{6} = ' ';
feedText{7} = contInstruct;

%show task instructions
for lineNum=1:length(feedText)
    tempBounds = Screen('TextBounds',mainWindow,feedText{lineNum});
    Screen('drawtext',mainWindow,feedText{lineNum},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(lineNum-1),textColor);
    clear tempBounds;
end
tFeed = Screen('Flip',mainWindow);
pause;

clearvars feedText
feedText{1} = 'We will tell you when the feedback is going to start by words that say:';
feedText{2} = 'The feedback blocks will start soon';
feedText{3} = ' ';
feedText{4} = contInstruct;

%show task instructions
for lineNum=1:length(feedText)
    tempBounds = Screen('TextBounds',mainWindow,feedText{lineNum});
    Screen('drawtext',mainWindow,feedText{lineNum},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(lineNum-1),textColor);
    clear tempBounds;
end
tFeed = Screen('Flip',mainWindow);
pause;

clearvars feedText
feedText{1} = 'Since it''s really loud in the scanner, we can''t tell you how you''re doing.';
feedText{2} = 'Also, we wouldn''t want to distract you!';
feedText{3} = ' ';
feedText{4} = 'Instead, we will give you feedback by changing the photos that you see';
feedText{5} = ' ';
feedText{6} = contInstruct;

%show task instructions
for lineNum=1:length(feedText)
    tempBounds = Screen('TextBounds',mainWindow,feedText{lineNum});
    Screen('drawtext',mainWindow,feedText{lineNum},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(lineNum-1),textColor);
    clear tempBounds;
end
tFeed = Screen('Flip',mainWindow);
pause;

clearvars feedText;
feedText{1} = 'During the feedback blocks, you will always be looking at the places in the photos';
feedText{2} = ' ';
feedText{3} = 'So the instructions will be';
feedText{4} = sceneShorterInstruct;
feedText{5} = ' ';
feedText{6} = contInstruct;

%show task instructions
for lineNum=1:length(feedText)
    tempBounds = Screen('TextBounds',mainWindow,feedText{lineNum});
    Screen('drawtext',mainWindow,feedText{lineNum},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(lineNum-1),textColor);
    clear tempBounds;
end
tFeed = Screen('Flip',mainWindow);
pause;

clearvars feedText;
feedText{1} = 'From your brain we can tell how well you are attending to the places';
feedText{2} = 'The way we will give you feedback is by changing the amount of face and place in a photo';
feedText{3} = ' ';
feedText{4} = 'So if you''re doing well, we will make the task easier by increasing the amount of place';
feedText{5} = 'We''ll show you what that looks like now';
feedText{6} = ' ';
feedText{7} = contInstruct;

%show task instructions
for lineNum=1:length(feedText)
    tempBounds = Screen('TextBounds',mainWindow,feedText{lineNum});
    Screen('drawtext',mainWindow,feedText{lineNum},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(lineNum-1),textColor);
    clear tempBounds;
end
tFeed = Screen('Flip',mainWindow);
pause;


%% scene stim

% show fixation
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tFix = Screen('Flip',mainWindow);

for half=[SCENE FACE]
    % get current images1
    tempPower{half} = imagePower{mode(blockData(1).categs{half}),1}; %#ok<NODEF>
    tempImagePhase{half} = imagePhase{mode(blockData(1).categs{half}),1}; %#ok<AGROW>
    tempImage{half} = real(ifft2(tempPower{half}.*exp(sqrt(-1)*tempImagePhase{half}))); %#ok<AGROW>
end
        
% generate image
fullImage = uint8(.75*tempImage{SCENE}+.25*tempImage{FACE});
        
% make textures
imageTex = Screen('MakeTexture',mainWindow,fullImage);
Screen('PreloadTextures',mainWindow,imageTex);
        
% wait for trigger and show image
FlushEvents('keyDown');
Priority(MaxPriority(screenNum));
Screen('FillRect',mainWindow,backColor);
Screen('DrawTexture',mainWindow,imageTex,imageRect,centerRect);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tStim = Screen('Flip',mainWindow,tFix+1);
tRespTimeout = tStim+respWindowPractice; %response timeout
stimOn = 1;
rts = NaN;

while(GetSecs < tRespTimeout)
    
    % check for responses if none received yet
    if isnan(rts)
        [keyIsDown, secs, keyCode] = KbCheck(DEVICE); % -1 checks all keyboards
        if keyIsDown
            if (keyCode(LEFT))
                rts = secs-tStim; 
                resps = find(keyCode,1); 
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

Screen('FillRect',mainWindow,backColor);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tFix = Screen('Flip',mainWindow,tStim+TR);

%%
clearvars feedText;
feedText{1} = 'If we''d like you to attend more, we will make the task harder by decreasing the places and increasing the faces';
feedText{2} = 'We''ll show you what that looks like now';
feedText{3} = ' ';
feedText{4} = contInstruct;

%show task instructions
for lineNum=1:length(feedText)
    tempBounds = Screen('TextBounds',mainWindow,feedText{lineNum});
    Screen('drawtext',mainWindow,feedText{lineNum},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(lineNum-1),textColor);
    clear tempBounds;
end
tFeed = Screen('Flip',mainWindow);
pause;

%% scene stim

% show fixation
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tFix = Screen('Flip',mainWindow);

for half=[SCENE FACE]
    % get current images
    tempPower{half} = imagePower{mode(blockData(1).categs{half}),1}; %#ok<NODEF>
    tempImagePhase{half} = imagePhase{mode(blockData(1).categs{half}),1}; %#ok<AGROW>
    tempImage{half} = real(ifft2(tempPower{half}.*exp(sqrt(-1)*tempImagePhase{half}))); %#ok<AGROW>
end
        
% generate image
fullImage = uint8(.25*tempImage{SCENE}+.75*tempImage{FACE});
        
% make textures
imageTex = Screen('MakeTexture',mainWindow,fullImage);
Screen('PreloadTextures',mainWindow,imageTex);
        
% wait for trigger and show image
FlushEvents('keyDown');
Priority(MaxPriority(screenNum));
Screen('FillRect',mainWindow,backColor);
Screen('DrawTexture',mainWindow,imageTex,imageRect,centerRect);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tStim = Screen('Flip',mainWindow,tFix+1);
tRespTimeout = tStim+respWindowPractice; %response timeout
stimOn = 1;
rts = NaN;

while(GetSecs < tRespTimeout)
    
    % check for responses if none received yet
    if isnan(rts)
        [keyIsDown, secs, keyCode] = KbCheck(DEVICE); % -1 checks all keyboards
        if keyIsDown
            if (keyCode(LEFT))
                rts = secs-tStim; 
                resps = find(keyCode,1); 
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

Screen('FillRect',mainWindow,backColor);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tFix = Screen('Flip',mainWindow,tStim+TR);


%%

clearvars feedText;
feedText{1} = 'So you''re goal during the feedback is to continue to do the task well';
feedText{2} = 'You can make the face disappear by strongly attending to the place';
feedText{3} = ' ';
feedText{4} = 'Now you can try a practice block';
feedText{5} = ' ';
feedText{6} = contInstruct;

%show task instructions
for lineNum=1:length(feedText)
    tempBounds = Screen('TextBounds',mainWindow,feedText{lineNum});
    Screen('drawtext',mainWindow,feedText{lineNum},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(lineNum-1),textColor);
    clear tempBounds;
end
tFeed = Screen('Flip',mainWindow);
pause;

%% scene stim

% clear screen
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);
FlushEvents('keyDown');

% show instructions
clearvars runInstruct;
runInstruct{1} = sceneShorterInstruct;

for instruct=1:length(runInstruct)
    tempBounds = Screen('TextBounds',mainWindow,runInstruct{instruct});
    Screen('drawtext',mainWindow,runInstruct{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
tInstruct = Screen('Flip',mainWindow);

% show fixation
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tFix = Screen('Flip',mainWindow,tInstruct+instructDur);

iTrial = 9;
for half=[SCENE FACE]
    % get current images
    tempPower{half} = imagePower{mode(blockData(1).categs{half}),iTrial}; %#ok<NODEF>
    tempImagePhase{half} = imagePhase{mode(blockData(1).categs{half}),iTrial}; %#ok<AGROW>
    tempImage{half} = real(ifft2(tempPower{half}.*exp(sqrt(-1)*tempImagePhase{half}))); %#ok<AGROW>
end
        
% generate image
fullImage = uint8(.5*tempImage{SCENE}+.5*tempImage{FACE});
        
% make textures
imageTex = Screen('MakeTexture',mainWindow,fullImage);
Screen('PreloadTextures',mainWindow,imageTex);
        
% wait for trigger and show image
FlushEvents('keyDown');
Priority(MaxPriority(screenNum));
Screen('FillRect',mainWindow,backColor);
Screen('DrawTexture',mainWindow,imageTex,imageRect,centerRect);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tStim = Screen('Flip',mainWindow,tFix+1);
tRespTimeout = tStim+respWindow; %response timeout
stimOn = 1;
rts = NaN;

while(GetSecs < tRespTimeout)
    
    % check for responses if none received yet
    if isnan(rts)
        [keyIsDown, secs, keyCode] = KbCheck(DEVICE); % -1 checks all keyboards
        if keyIsDown
            if (keyCode(LEFT))
                rts = secs-tStim; 
                resps = find(keyCode,1); 
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

attPropScene = [.6 .7 .8 .9 1];
attPropFace = 1-attPropScene;
for iTrial = 1:5;
    for half=[SCENE FACE]
        % get current images
        if (half == SCENE) && (iTrial==4)
            x = blockData(1).categs{half}(find(blockData(1).categs{half}~=mode(blockData(1).categs{half}),1,'first'));
        else
            x = mode(blockData(1).categs{half});
        end
        tempPower{half} = imagePower{x,iTrial+9}; %#ok<NODEF>
        tempImagePhase{half} = imagePhase{x,iTrial+9}; %#ok<AGROW>
        tempImage{half} = real(ifft2(tempPower{half}.*exp(sqrt(-1)*tempImagePhase{half}))); %#ok<AGROW>    
    end
    
    % generate image
    fullImage = uint8(attPropScene(iTrial)*tempImage{SCENE}+attPropFace(iTrial)*tempImage{FACE});
    
    % make textures
    imageTex = Screen('MakeTexture',mainWindow,fullImage);
    Screen('PreloadTextures',mainWindow,imageTex);
    
    % wait for trigger and show image
    FlushEvents('keyDown');
    Priority(MaxPriority(screenNum));
    Screen('FillRect',mainWindow,backColor);
    Screen('DrawTexture',mainWindow,imageTex,imageRect,centerRect);
    Screen(mainWindow,'FillOval',fixColor,fixDotRect);
    tStim = Screen('Flip',mainWindow,tStim+stimDur);
    tRespTimeout = tStim+respWindow; %response timeout
    stimOn = 1;
    rts = NaN;
    
    while(GetSecs < tRespTimeout)
        
        % check for responses if none received yet
        if isnan(rts)
            [keyIsDown, secs, keyCode] = KbCheck(DEVICE); % -1 checks all keyboards
            if keyIsDown
                if (keyCode(LEFT))
                    rts = secs-tStim;
                    resps = find(keyCode,1);
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
end

Screen('FillRect',mainWindow,backColor);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
tFix = Screen('Flip',mainWindow,tStim+stimDur);
WaitSecs(TR);


%%

congratsText{1} = 'Congrats!';
congratsText{2} = 'Now you are ready to start the task.';
congratsText{3} = ' ';
congratsText{4} = 'The task will not be very long so please try your best!';
congratsText{5} = ' ';
congratsText{6} = 'Good luck!';

%show task instructions
for lineNum=1:length(congratsText)
    tempBounds = Screen('TextBounds',mainWindow,congratsText{lineNum});
    Screen('drawtext',mainWindow,congratsText{lineNum},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(lineNum-1),textColor);
    clear tempBounds;
end
tCongrats = Screen('Flip',mainWindow);

Screen('FillRect',mainWindow,backColor);
Screen('Flip',mainWindow,tCongrats+3*TR);

% clean up and go home
sca;
ListenChar(1);
fclose('all');
end
