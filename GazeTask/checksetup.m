% check ratio of data points
% MAKE INTO FUNCTION
% ADD NEUTRAL IMAGE
% SAVE DATA AND PLOT


function response = checksetup(subjectNum,expDay,eyeTrack,debug)
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


%initialize system time calls
GetSecs;

%% Experimental Parameters

% block timing
instructOn = 0;     % secs
instructDur = 1;    % secs
instructTRnum = 1;  % TRs
%fixationOn = TR-.3; % secs

% practice 3 trials
stim.picDuration = 30;

stim.isiDuration = 1; %ITI

% display parameters
textColor = 255;
textFont = 'Arial';
textSize = 25;
textSpacing = 25;
fixColor = 255;
respColor = 255;
backColor = 0;
imageSize = [300 300]; % X AND Y NOT NROWS NCOLS
fixationSize = 4;% pixels
progWidth = 400; % image loading progress bar
progHeight = 20;

ScreenResX = 1280;
ScreenResY = 720;

%% Response Mapping and Counterbalancing

% skyra: use current design button box (keys 1,2,3,4)
KbName('UnifyKeyNames');
RETURN = KbName('Return');
DEVICE = -1;
LEFT = [KbName('1!') KbName('1')];
subj_keycode = LEFT;
DEVICENAME = 'Dell KB216 Wired Keyboard';
if debug == 0 % use external keyboard
    [index devName] = GetKeyboardIndices;
    for device = 1:length(index)
        if strcmp(devName(device),DEVICENAME)
            DEVICE = index(device);
        end
    end
else
    DEVICE = -1;
end
%DEVICE = -1
% counterbalancing response mapping based on subject assignment
% correctResp spells out the responses for {INDOOR,OUTDOOR,MALE,FEMALE}

% want to have it so there are 20 trials
% 8 filler trials: neutral fillers
% 12 regular trials
% each stimulus category must occur in each of the spots 3 times
nImages = 1;
nTrials = 3;
DYSPHORIC = 1;
THREAT = 2;
NEUTRAL = 3;
POSITIVE = 4;

stim.order(:,DYSPHORIC) = randperm(nImages);
stim.order(:,THREAT) = randperm(nImages);
stim.order(:,NEUTRAL) = randperm(nImages);
stim.order(:,POSITIVE) = randperm(nImages);
nCategories = 4;
stim.trialType=1;
% now for the positioning
% so 1 = regular trial and 2 = filler


%% Initialize Screens

screenNumbers = Screen('Screens');
Screen('Preference', 'SkipSyncTests', 2);
% show full screen if real, otherwise part of screen
if debug == 1
    screenNum = 0;
    %screenNum = screenNumbers(end);
else
    screenNum = screenNumbers(end);
end

%retrieve the size of the display screen
if debug == 1
    screenX = 500;
    screenY = 500;
else
    % first just make the screen tiny
    %screenNum = 0; % I'm not sure it's coming up as screen 0
    [screenX screenY] = Screen('WindowSize',screenNum);
%     otherscreen = screenNumbers(1);
%     if otherscreen ~= screenNum
%         % open another window
%         [s2x s2y] = Screen('WindowSize', otherscreen);
%         otherWindow = Screen(otherscreen,'OpenWindow',backColor);
%     end
    % put this back in!!!
    windowSize.degrees = [51 30];
    resolution = Screen('Resolution', screenNum);
    windowSize.pixels = [resolution.width resolution.height];
    screenX = windowSize.pixels(1);
    screenY = windowSize.pixels(2);
end
%% CALIBRATION WOO! - have to have the screen 
%%

if debug == 1
    mainWindow = Screen(screenNum, 'OpenWindow', backColor,[0 0 screenX screenY]);
else
    mainWindow = Screen(screenNum, 'OpenWindow', backColor);
end

% make transparent window

ifi = Screen('GetFlipInterval', mainWindow);
SLACK  = ifi/2;
% details of main window
centerX = screenX/2; centerY = screenY/2;
Screen(mainWindow,'TextFont',textFont);
Screen(mainWindow,'TextSize',textSize);

% original dimensions
imageSize2 = imageSize;
actual_imageSize = [400 400];
imageRect = [0 0 actual_imageSize(1) actual_imageSize(2)];
% placeholder for images
%border = screenX/20;
% try to scale border to area of screen
% maybe make a little bigger?
%border = (screenY - imageSize(2)*2)/2;
border = (screenY - imageSize(2)*2)/1.5;
% try 2/28 make border bigger
borderH = border/2;

% for upper right
X1 = centerX + borderH;
X2 = X1 + imageSize2(1);
Y2 = centerY - borderH;
Y1 = Y2 - imageSize2(2);
imPos(1,:) = [X1,Y1,X2,Y2];

% for upper left
X2 = centerX - borderH;
X1 = X2 - imageSize2(1);
Y2 = centerY - borderH;
Y1 = Y2 - imageSize2(2);
imPos(2,:) = [X1,Y1,X2,Y2];

% for lower left
X2 = centerX - borderH;
X1 = X2 - imageSize2(1);
Y1 = centerY + borderH;
Y2 = Y1 + imageSize2(2);
imPos(3,:) = [X1,Y1,X2,Y2];

% for lower right
X1 = centerX + borderH;
X2 = X1 + imageSize2(1);
Y1 = centerY + borderH;
Y2 = Y1 + imageSize2(2);
imPos(4,:) = [X1,Y1,X2,Y2];

%% Load or Initialize Real-Time Data & Staircasing Parameters

dataHeader = ['data/subject' num2str(subjectNum)];
dayHeader = [dataHeader '/day' num2str(expDay)];

if ~exist(dayHeader)
    mkdir(dayHeader);
end

% get the image director for the day
image_path = ['exampleimage' '/'];
code_path = pwd;
%% Load Images
nSubCategs = 1;
cd(image_path);
for categ=1:nSubCategs
    
    % move into the right folder
    %if (categ == 1)
    %    cd image_path;
    %else
    %    error('Impossible category!');
    %end
    
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
cd(code_path);
Screen('Flip',mainWindow);


%% Output Files Setup

% open and set-up output file
% dataFile = fopen([dataHeader '/behavior.txt'],'a');
% fprintf(dataFile,'\n*********************************************\n');
% fprintf(dataFile,'* Gaze Experiment v.1.0\n');
% fprintf(dataFile,['* Date/Time: ' datestr(now,0) '\n']);
% fprintf(dataFile,['* Seed: ' num2str(seed) '\n']);
% fprintf(dataFile,['* Subject Number: ' num2str(subjectNum) '\n']);
% fprintf(dataFile,['* Tobii: ' num2str(eyeTrack) '\n']);
% fprintf(dataFile,['* Debug: ' num2str(debug) '\n']);
% fprintf(dataFile,'*********************************************\n\n');
% 
% fprintf('\n*********************************************\n');
% fprintf('* Gaze Experiment v.1.0\n');
% fprintf(['* Date/Time: ' datestr(now,0) '\n']);
% fprintf(['* Seed: ' num2str(seed) '\n']);
% fprintf(['* Subject Number: ' num2str(subjectNum) '\n']);
% fprintf(['* Tobii: ' num2str(eyeTrack) '\n']);
% fprintf(['* Debug: ' num2str(debug) '\n']);
% fprintf('*********************************************\n\n');

%%
instruct = {};
% another page of instructions?
instruct{1} = 'Press to test once more';

for i=1:length(instruct)
    tempBounds = Screen('TextBounds',mainWindow,instruct{i});
    if i == 4
        textSpacing = textSpacing*1.5;
    end
    Screen('drawtext',mainWindow,instruct{i},centerX-tempBounds(3)/2,centerY-(.15*centerY)-tempBounds(4)/5+1.5*textSpacing*(i-1),textColor);
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

timing.runStart = GetSecs;

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
%fprintf(dataFile,'trial\ttype\tEflip\ttype1\ttype2\ttype3\ttype4\tid1\tid2\tid3\tid4\n');
%fprintf('trial\ttype\tEflip\ttype1\ttype2\ttype3\ttype4\tid1\tid2\tid3\tid4\n');
% instructionsd

% show instructions

% show fixation

% start trial sequence
vCount = 0; % for exp images
for iTrial=1:config.nTrials
    
    %present ISI
    timespec = timing.plannedOnsets.preITI(iTrial) - SLACK;
    timing.actualOnsets.preITI(iTrial) = isi_specific(mainWindow,fixColor, timespec);
    % now close previous trial's data
    if eyeTrack
        if iTrial > 1
            Temp = tetio_localTimeNow;
            timing.gaze.off(iTrial-1) = tetio_localToRemoteTime(Temp);
            tetio_stopTracking;
            [GazeData.Left{iTrial-1}, GazeData.Right{iTrial-1}, GazeData.Timing.Remote{iTrial-1}] = tetio_readGazeData;
        end
    end
    
    Screen('FillRect',mainWindow,backColor);
    % generate images
    if stim.trialType == 1
        vCount = vCount + 1;
        for im = 1:4
            % for valence trials
            %categ = stim.position(vCount,im);
            stim.image{vCount,im} = images{1,1};
            % make textures
            imageTex = Screen('MakeTexture',mainWindow,stim.image{vCount,im});
            Screen('PreloadTextures',mainWindow,imageTex);
            Screen('DrawTexture',mainWindow,imageTex,imageRect,imPos(im,:));
        end
    end
    % start eye tracking here
    if eyeTrack
        tetio_startTracking;
        timing.startEye(iTrial) = GetSecs;
    end
    timespec = timing.plannedOnsets.pic(iTrial) - SLACK;
    timing.actualOnsets.pic(iTrial) = Screen('Flip',mainWindow,timespec); %#ok<AGROW>
    if eyeTrack
        Temp = tetio_localTimeNow;
        timing.gaze.pic(iTrial) = tetio_localToRemoteTime(Temp);
        % this gets the time that it flipped in the eye tracker time
    end
    %fprintf('Flip time error = %.4f\n', timing.actualOnsets.pic(iTrial) - timing.plannedOnsets.pic(iTrial));
    
end % trial loop

timespec = timing.plannedOnsets.lastITI - SLACK;
timing.actualOnsets.lastITI = isi_specific(mainWindow,fixColor,timespec);

% now end eye tracking for last trial
if eyeTrack
    Temp = tetio_localTimeNow;
    timing.gaze.off(iTrial) = tetio_localToRemoteTime(Temp);
    tetio_stopTracking;
    [GazeData.Left{iTrial}, GazeData.Right{iTrial}, GazeData.Timing.Remote{iTrial}] = tetio_readGazeData;
end

fprintf('Flip time error = %.4f\n', timing.actualOnsets.lastITI - timing.plannedOnsets.lastITI);

Screen('FillRect',mainWindow,backColor);
Screen('Flip',mainWindow);
%% calculate ratio found and plot here
GazeData.ratio_pts = [];
if eyeTrack
    for trial = 1:3
        remote_start = timing.gaze.pic(trial);
        remote_stop = timing.gaze.off(trial);
        time_trial = GazeData.Timing.Remote{trial}; % 709 points
        trial_rows = intersect(find(time_trial>=remote_start), find(time_trial<=remote_stop));
        
        
        rightEyeAll = GazeData.Right{trial}(trial_rows,:);
        leftEyeAll = GazeData.Left{trial}(trial_rows,:);
        rightGazePoint2d.x = rightEyeAll(:,7);
        rightGazePoint2d.y = rightEyeAll(:,8);
        leftGazePoint2d.x = leftEyeAll(:,7);
        leftGazePoint2d.y = leftEyeAll(:,8);
        badrightX = find(rightGazePoint2d.x == -1);
        badrightY = find(rightGazePoint2d.y == -1);
        badleftX = find(leftGazePoint2d.x == -1);
        badleftY = find(leftGazePoint2d.y == -1);
        rightGazePoint2d.x(badrightX) = nan;
        rightGazePoint2d.y(badrightY) = nan;
        leftGazePoint2d.x(badleftX) = nan;
        leftGazePoint2d.y(badrightY) = nan;
        gaze.x = nanmean([rightGazePoint2d.x, leftGazePoint2d.x],2);
        gaze.y = nanmean([rightGazePoint2d.y, leftGazePoint2d.y],2);
        
        n_points = length(find(gaze.x > 0 | gaze.y >0));
        GazeData.ratio_pts(trial) = n_points/length(gaze.x);
    end
fprintf('gazedata ratios are:\n');
fprintf('%.2f \t %.2f \t %.2f\n', GazeData.ratio_pts(1), GazeData.ratio_pts(2), GazeData.ratio_pts(3))   
response = input('IS THIS OKAY?\n');
end

%% save

save([dayHeader '/gazeCHECK' '_' datestr(now,30)],'stim', 'config', 'timing', 'GazeData');
% clean up and go home
sca;
ListenChar(1);
fclose('all');
clearvars -except response;
end
