function [blockData] = RealTimeBehavDisplay(subjectNum,subjectName,matchNum,runNum,debug)
% function [blockData] = RealTimeBehavDisplay(subjectNum,subjectName,matchNum,runNum,debug)
%
% Face/house attention experiment with real-time classifier feedback
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
typeStr = {'stb','fed'};

% block timing
instructOn = 0;     % secs
instructDur = 1;    % secs
instructTRnum = 1;  % TRs

% trial timing
stimDur = 1;        % secs
respWindow = .85;   % secs
%deltat = .1;        % secs
%allowance = .05;    % secs

% display parameters
textColor = 0;
textFont = 'Arial';
textSize = 14;
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

contInstruct = sprintf('Please hit spacebar to start run %d',runNum);


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

if subjectNum
    % open and set-up output file
    dataFile = fopen([dataHeader '/behavior.txt'],'a');
    fprintf(dataFile,'\n*********************************************\n');
    fprintf(dataFile,'* Punisher Experiment v.2.0\n');
    fprintf(dataFile,['* Date/Time: ' datestr(now,0) '\n']);
    fprintf(dataFile,['* Seed: ' num2str(seed) '\n']);
    fprintf(dataFile,['* Subject Number: ' num2str(subjectNum) '\n']);
    fprintf(dataFile,['* Subject Name: ' subjectName '\n']);
    fprintf(dataFile,['* Matched Subject Num: ' matchNum '\n']);
    fprintf(dataFile,['* Run Number: ' num2str(runNum) '\n']);
    fprintf(dataFile,['* debug: ' num2str(debug) '\n']);
    fprintf(dataFile,'*********************************************\n\n');
end

% print header to command window
fprintf('\n*********************************************\n');
fprintf('* Punisher Experiment v.2.0\n');
fprintf(['* Date/Time: ' datestr(now,0) '\n']);
fprintf(['* Seed: ' num2str(seed) '\n']);
fprintf(['* Subject Number: ' num2str(subjectNum) '\n']);
fprintf(['* Subject Name: ' subjectName '\n']);
fprintf(['* Matched Subject Num: ' matchNum '\n']);
fprintf(['* Run Number: ' num2str(runNum) '\n']);
fprintf(['* debug: ' num2str(debug) '\n']);
fprintf('*********************************************\n\n');


%% Show Instructions

% clear screen
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);
FlushEvents('keyDown');

% show instructions
runInstruct{1} = sceneInstruct;
runInstruct{2} = faceInstruct;
runInstruct{3} = ' ';
runInstruct{4} = ' ';
runInstruct{5} = contInstruct;

for instruct=1:length(runInstruct)
    tempBounds = Screen('TextBounds',mainWindow,runInstruct{instruct});
    Screen('drawtext',mainWindow,runInstruct{instruct},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(instruct-1),textColor);
    clear tempBounds;
end
Screen('Flip',mainWindow);

% wait for experimenter to advance with 'q' key
FlushEvents('keyDown');
pause;
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);


%% Start Experiment

% wait for initial trigger
Priority(MaxPriority(screenNum));
Screen(mainWindow,'FillRect',backColor);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
runStart = GetSecs;
Screen('Flip',mainWindow);
Priority(0);

% prepare for trial sequence
if subjectNum
    fprintf(dataFile,'run\tblk\ttyp\tcat\ttrl\tdf\tpls\tsct\tfct\tsimg\tfimg\tcrsp\trsp\tacc\trt\tctsp\tatPrp\tsmthPrp\n');
end
fprintf('run\tblk\ttyp\tcat\ttrl\ttdf\tpls\tsct\tfct\tsimg\tfimg\tcrsp\trsp\tacc\trt\tctsp\tatPrp\tsmthPrp\n');

%% set up

for iBlock = 1:numel(blockData) %#ok<NODEF>
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

blockOnsets((numel(blockOnsets)/2+1):end) = blockOnsets((numel(blockOnsets)/2+1):end)+IBI;
typeOrder = [blockData.type];
indBlocks = 1:(numel(typeOrder));

%% Block Sequence - Phase 1

trialCounter = 0;
for iBlock=1:numel(indBlocks)
    
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
        blockData(iBlock).attImgProp(iTrial)=attImgProp; %#ok<AGROW>
        
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
        
        blockData(iBlock).pulses(iTrial) = 0; %#ok<AGROW>
        blockData(iBlock).actualtrialonsets(iTrial) = Screen('Flip',mainWindow,blockData(iBlock).plannedtrialonsets(iTrial)); %#ok<AGROW>
        stimOn = 1;
        
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
        
        % print trial results
        if subjectNum
            fprintf(dataFile,'%d\t%d\t%s\t%s\t%d\t%.3f\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%.3f\t%.3f\t%.3f\t%.3f\n',runNum,iBlock,typeStr{blockData(iBlock).type},categStr{blockData(iBlock).attCateg},iTrial,blockData(iBlock).actualtrialonsets(iTrial)-blockData(iBlock).plannedtrialonsets(iTrial),blockData(iBlock).pulses(iTrial),blockData(iBlock).categs{SCENE}(iTrial),blockData(iBlock).categs{FACE}(iTrial),blockData(iBlock).images{SCENE}(iTrial),blockData(iBlock).images{FACE}(iTrial),blockData(iBlock).corrresps(iTrial),blockData(iBlock).resps(iTrial),blockData(iBlock).accs(iTrial),blockData(iBlock).rts(iTrial),NaN,blockData(iBlock).attImgProp(iTrial),NaN);
        end
        fprintf('%d\t%d\t%s\t%s\t%d\t%.3f\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%.3f\t%.3f\t%.3f\t%.3f\n',runNum,iBlock,typeStr{blockData(iBlock).type},categStr{blockData(iBlock).attCateg},iTrial,blockData(iBlock).actualtrialonsets(iTrial)-blockData(iBlock).plannedtrialonsets(iTrial),blockData(iBlock).pulses(iTrial),blockData(iBlock).categs{SCENE}(iTrial),blockData(iBlock).categs{FACE}(iTrial),blockData(iBlock).images{SCENE}(iTrial),blockData(iBlock).images{FACE}(iTrial),blockData(iBlock).corrresps(iTrial),blockData(iBlock).resps(iTrial),blockData(iBlock).accs(iTrial),blockData(iBlock).rts(iTrial),NaN,blockData(iBlock).attImgProp(iTrial),NaN);
        
    end % trial loop
    
    while ((GetSecs-blockData(iBlock).actualtrialonsets(iTrial) < stimDur))
        1;
    end
    
    Screen('FillRect',mainWindow,backColor);
    Screen(mainWindow,'FillOval',fixColor,fixDotRect);
    Screen('Flip',mainWindow);
    
end % end block loop

Screen('FillRect',mainWindow,backColor);
Screen(mainWindow,'FillOval',fixColor,fixDotRect);
Screen('Flip',mainWindow);
WaitSecs(IBI);

%% save

if subjectNum
    save([dataHeader '/blockdata_' num2str(runNum) '_' datestr(now,30)],'blockData','runStart');
end


% %behav calculations
% corrresps = [blockData.corrresps];
% resps = [blockData.resps];
% indsTarg=find(corrresps==LEFT);
% indsLure=find(isnan(corrresps));
% hits = corrresps(indsTarg)==resps(indsTarg);
% hitRate = sum(hits)/(numel(indsTarg));
% falseAlarms = isnan(resps(indsLure));
% falseAlarmRate = sum(falseAlarms)/numel(indsLure);
% Aprime = .5+((hitRate-falseAlarmRate)*(1+hitRate-falseAlarmRate))/(4*hitRate*(1-falseAlarmRate));
% fprintf('Run %d A'': %.3f\n',runNum,Aprime); 

% clean up and go home
sca;
ListenChar(1);
fclose('all');
end
