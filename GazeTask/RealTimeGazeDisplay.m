function RealTimeGazeDisplay(subjectNum,matchNum,eyeTrack,debug)
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
stim.picDuration = 5 %change for debugging;        % secs
stim.isiDuration = 1; %ITI

% display parameters
textColor = 255;
textFont = 'Arial';
textSize = 25;
textSpacing = 25;
fixColor = 255;
respColor = 255;
backColor = 0;
imageSize = [800 600]; % X AND Y NOT NROWS NCOLS
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

% want to have it so there are 20 trials
% 8 filler trials: neutral fillers
% 12 regular trials
% each stimulus category must occur in each of the spots 3 times
nImages = 12;
nFillerImages = 16;
nTrialsReg = 12;
nFillers = 8;
nTrials = nTrialsReg + nFillers;
DYSPHORIC = 1;
THREAT = 2;
NEUTRAL = 3;
POSITIVE = 4;
NEUTRALFILLER = 5;

stim.order(:,DYSPHORIC) = randperm(nImages);
stim.order(:,THREAT) = randperm(nImages);
stim.order(:,NEUTRAL) = randperm(nImages);
stim.order(:,POSITIVE) = randperm(nImages);
nCategories = 4;
% now for the positioning
done = 0;
while ~done
    for t = 1:nTrialsReg
        stim.position(t,:) = randperm(nCategories);
    end
    % make sure there 3x repeats in each cateogry
    if length(find(stim.position(:,1)==1)) == 3 && length(find(stim.position(:,2)==1)) ==3 && length(find(stim.position(:,3)==1))==3 && length(find(stim.position(:,4)==1))==3 && length(find(stim.position(:,1)==2)) == 3 && length(find(stim.position(:,2)==2)) ==3 && length(find(stim.position(:,3)==2))==3 && length(find(stim.position(:,4)==2))==3 && length(find(stim.position(:,1)==3)) == 3 && length(find(stim.position(:,2)==3)) ==3 && length(find(stim.position(:,3)==3))==3 && length(find(stim.position(:,4)==3))==3 && length(find(stim.position(:,1)==4)) == 3 && length(find(stim.position(:,2)==4)) ==3 && length(find(stim.position(:,3)==4))==3 && length(find(stim.position(:,4)==4))==3
        % now make sure none repeat in the same position for two trials in
        % row
        %if ~any(any(diff(stim.position)==0))
            done = 1;
        %end
    end
end

% NOW FILLERS
% they need to appear twice so maybe have it so they don't appear in the
% same location?
% there are  8 filler trials so choose 8 rounds of 4 images
done = 0;
while ~done
    fillerVec = Shuffle([1:nFillerImages 1:nFillerImages]);
    for t=1:nFillers
        % for each trial choose four images
        chosen = randperm(length(fillerVec),4);
        stim.fillerPosition(t,:) = fillerVec(chosen);
        fillerVec(chosen) = [];
    end
    for t=1:nFillers
        nU(t) = length(unique(stim.fillerPosition(t,:)));
    end
    % now make sure none of the filllers repeat
    if all(nU==4)
        done =1;
    end
end
% check 2x per image
for t = 1:nFillerImages
    nR(t) = length(find(stim.fillerPosition==t));
end
% now counterbalance types of trials: make sure that neutral fillers don't
% appear for more than 2 in a row
done = 0;
while ~done
    stim.trialType = Shuffle([ones(1,nTrialsReg) 2*ones(1,nFillers)]);
    neutrals = find(stim.trialType==2);
    if ~any(diff(neutrals)==1)
        done=1;
    end
end
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
    screenX = 1000;
    screenY = 800;
else
    % first just make the screen tiny
    
    [screenX screenY] = Screen('WindowSize',screenNum);
    % put this back in!!!
    windowSize.degrees = [51 30];
    resolution = Screen('Resolution', screenNum);
    windowSize.pixels = [resolution.width resolution.height];
    screenX = windowSize.pixels(1);
    screenY = windowSize.pixels(2);
end

mainWindow = Screen(screenNum,'OpenWindow',backColor,[0 0 screenX screenY]);
ifi = Screen('GetFlipInterval', mainWindow);
SLACK  = ifi/2;
% details of main window
centerX = screenX/2; centerY = screenY/2;
Screen(mainWindow,'TextFont',textFont);
Screen(mainWindow,'TextSize',textSize);

% placeholder for images
imageRect = [0,0,imageSize(1),imageSize(2)];
destDims = imageSize/2;
BorderX = screenX/20;
BorderY = screenY/20;

% position of each image
% position of images
imPos(1,:) = [BorderX,BorderY,BorderX+destDims(1),BorderY+destDims(2)];
imPos(2,:) = [screenX-BorderX-destDims(1),BorderY,screenX-BorderX,BorderY+destDims(2)];
imPos(3,:) = [BorderX,screenY-BorderY-destDims(2),BorderX+destDims(1),screenY-BorderY];
imPos(4,:) = [screenX-BorderX-destDims(1),screenY-BorderY-destDims(2),screenX-BorderX,screenY-BorderY];

% image loading progress bar
progRect = [centerX-progWidth/2,centerY-progHeight/2,centerX+progWidth/2,centerY+progHeight/2];


%% Load or Initialize Real-Time Data & Staircasing Parameters

if matchNum == 0
    dataHeader = ['data/' num2str(subjectNum)];
    if ~exist(dataHeader)
        mkdir(dataHeader);
        MdataHeader = ['data/' num2str(subjectNum) '_match'];
        mkdir(MdataHeader);
    end
else
    dataHeader = ['data/' num2str(subjectNum) '_match'];
end

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
%                 
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
fprintf(dataFile,'* Gaze Experiment v.1.0\n');
fprintf(dataFile,['* Date/Time: ' datestr(now,0) '\n']);
fprintf(dataFile,['* Seed: ' num2str(seed) '\n']);
fprintf(dataFile,['* Subject Number: ' num2str(subjectNum) '\n']);
fprintf(dataFile,['* Tobii: ' num2str(eyeTrack) '\n']);
fprintf(dataFile,['* debug: ' num2str(debug) '\n']);
fprintf(dataFile,'*********************************************\n\n');

fprintf('\n*********************************************\n');
fprintf('* Gaze Experiment v.1.0\n');
fprintf(['* Date/Time: ' datestr(now,0) '\n']);
fprintf(['* Seed: ' num2str(seed) '\n']);
fprintf(['* Subject Number: ' num2str(subjectNum) '\n']);
fprintf(['* Tobii: ' num2str(eyeTrack) '\n']);
fprintf(['* debug: ' num2str(debug) '\n']);
fprintf('*********************************************\n\n');


     
%% Show Instructions
instruct{1} = 'Please look at the computer screen for the allotted time in the trial.';

% clear screen
Screen(mainWindow,'FillRect',backColor);
Screen('Flip',mainWindow);
FlushEvents('keyDown');

% % show instructions
% if (blockData(1).type == 1)
%     runInstruct{1} = sceneInstruct;
%     runInstruct{2} = faceInstruct;
% else
%     runInstruct{1} = faceInstruct;
%     runInstruct{2} = sceneInstruct;
% end

for i=1:length(instruct)
    tempBounds = Screen('TextBounds',mainWindow,instruct{i});
    Screen('drawtext',mainWindow,instruct{i},centerX-tempBounds(3)/2,centerY-tempBounds(4)/5+textSpacing*(i-1),textColor);
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
timing.runStart = GetSecs;
Screen('Flip',mainWindow);
Priority(0);


%% set up timing
config.TR = 2;
config.nTRs.ISI = stim.isiDuration/config.TR;
config.nTRs.pic = stim.picDuration/config.TR;
config.nTrials = nTrials;

config.nTRs.perTrial = config.nTRs.ISI + config.nTRs.pic;
config.nTRS.perBlock = (config.nTRs.perTrial)*config.nTrials + config.nTRs.ISI; % includes last ISI at the end

timing.plannedOnsets.preITI(1:config.nTrials) = timing.runStart + ((0:config.nTrials-1)*config.nTRs.perTrial)*config.TR;
timing.plannedOnsets.pic(1:config.nTrials) = timing.plannedOnsets.preITI + config.nTRs.ISI*config.TR;
timing.plannedOnsets.lastITI = timing.plannedOnsets.pic(end) + config.nTRs.pic*config.TR;
%% Begin experiment

% prepare for trial sequence
fprintf(dataFile,'trial\ttype\tEflip\ttype1\ttype2\ttype3\ttype4\tid1\tid2\tid3\tid4\n');
fprintf('trial\ttype\tEflip\ttype1\ttype2\ttype3\ttype4\tid1\tid2\tid3\tid4\n');
% instructions

% show instructions

% show fixation

% start trial sequence
vCount = 0; % for exp images
fCount = 0; % for neutral fillers
for iTrial=1:config.nTrials
    
    %present ISI
    timespec = timing.plannedOnsets.preITI(iTrial) - SLACK;
    timing.actualOnsets.preITI(iTrial) = isi_specific(mainWindow,fixColor, timespec);
    % now close previous trial's data
    if eyeTrack
        if iTrial > 0
            Temp = tetio_localTimeNow;
            timing.gaze.preITI(iTrial) = tetio_localToRemoteTime(Temp);
            tetio_stopTracking;
            [GazeData.Left{iTrial-1}, GazeData.Right{iTrial-1}, GazeData.Timing.Remote{iTrial-1}] = tetio_readGazeData;
        end
    end
    
    Screen('FillRect',mainWindow,backColor);
    % generate images
    if stim.trialType(iTrial) == 1
        vCount = vCount + 1;
        for im = 1:4
            categ = stim.position(vCount,im);
            stim.image{vCount,im} = images{categ,stim.order(vCount,categ)};
            % make textures
            imageTex = Screen('MakeTexture',mainWindow,stim.image{vCount,im});
            Screen('PreloadTextures',mainWindow,imageTex);
            Screen('DrawTexture',mainWindow,imageTex,imageRect,imPos(im,:));
        end
    else
        fCount = fCount + 1;
        categ=NEUTRALFILLER;
        for im = 1:4
            stim.neutralFillerImage{fCount,im} = images{categ,stim.fillerPosition(fCount,im)};
            % make textures
            imageTex = Screen('MakeTexture',mainWindow,stim.neutralFillerImage{fCount,im});
            Screen('PreloadTextures',mainWindow,imageTex);
            Screen('DrawTexture',mainWindow,imageTex,imageRect,imPos(im,:));
        end
    end
    if eyeTrack
        tetio_startTracking;
    end
    timespec = timing.plannedOnsets.pic(iTrial) - SLACK;
    timing.actualOnsets.pic(iTrial) = Screen('Flip',mainWindow,timespec); %#ok<AGROW>
    if eyeTrack
        Temp = tetio_localTimeNow;
        timing.gaze.pic(iTrial) = tetio_localToRemoteTime(Temp);
    end
    %fprintf('Flip time error = %.4f\n', timing.actualOnsets.pic(iTrial) - timing.plannedOnsets.pic(iTrial));
    if stim.trialType(iTrial)==1
        % print trial results
        fprintf(dataFile,'%d\t%d\t%.3f\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n',iTrial,stim.trialType(iTrial),timing.actualOnsets.pic(iTrial) - timing.plannedOnsets.pic(iTrial),stim.position(vCount,1),stim.position(vCount,2),stim.position(vCount,3),stim.position(vCount,4),stim.order(vCount,stim.position(vCount,1)),stim.order(vCount,stim.position(vCount,2)),stim.order(vCount,stim.position(vCount,3)),stim.order(vCount,stim.position(vCount,4)));
        fprintf('%d\t%d\t%.3f\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n',iTrial,stim.trialType(iTrial),timing.actualOnsets.pic(iTrial) - timing.plannedOnsets.pic(iTrial),stim.position(vCount,1),stim.position(vCount,2),stim.position(vCount,3),stim.position(vCount,4),stim.order(vCount,stim.position(vCount,1)),stim.order(vCount,stim.position(vCount,2)),stim.order(vCount,stim.position(vCount,3)),stim.order(vCount,stim.position(vCount,4)));
    else
        fprintf(dataFile,'%d\t%d\t%.3f\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n',iTrial,stim.trialType(iTrial),timing.actualOnsets.pic(iTrial) - timing.plannedOnsets.pic(iTrial),categ,categ,categ,categ,stim.fillerPosition(fCount,1),stim.fillerPosition(fCount,2),stim.fillerPosition(fCount,3),stim.fillerPosition(fCount,4));
        fprintf('%d\t%d\t%.3f\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\n',iTrial,stim.trialType(iTrial),timing.actualOnsets.pic(iTrial) - timing.plannedOnsets.pic(iTrial),categ,categ,categ,categ,stim.fillerPosition(fCount,1),stim.fillerPosition(fCount,2),stim.fillerPosition(fCount,3),stim.fillerPosition(fCount,4));
    end
end % trial loop

timespec = timing.plannedOnsets.lastITI - SLACK;
timing.actualOnsets.lastITI = isi_specific(mainWindow,fixColor,timespec);

% now end eye tracking for last trial
if eyeTrack
    tetio_stopTracking;
    [GazeData.Left{iTrial}, GazeData.Right{iTrial}, GazeData.Timing.Remote{iTrial}] = tetio_readGazeData;
end

fprintf('Flip time error = %.4f\n', timing.actualOnsets.lastITI - timing.plannedOnsets.lastITI);

tetio_disconnectTracker;
tetio_cleanUp;

Screen('FillRect',mainWindow,backColor);
Screen('Flip',mainWindow);
%% save
if ~eyeTrack
    save([dataHeader '/gazedata' '_' datestr(now,30)],'stim', 'config', 'timing');
else
    save([dataHeader '/gazedata' '_' datestr(now,30)],'stim', 'config', 'timing', 'GazeData');
end
% clean up and go home
sca;
ListenChar(1);
fclose('all');
end
