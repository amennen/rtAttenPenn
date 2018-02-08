function Subj_BehavResults(subjNum,exptNum)
%function Subj_BehavResults(subjNum,exptNum)
%
%this function calculates behavioral results for a single subject from the 
%real-time Attention training behavioral expt at UT Austin and saves these
%behavioral results to a directory for later analysis across-subjects
%
%INPUTS:
% - subjNum = subject number identifier (e.g. 1)
% - exptNum = 2 or 3 or 4 
%
% MdB, 3/2012

%% check inputs

assert(isnumeric(subjNum),'subjNum should be a number');
assert((exptNum==2)||(exptNum==3)||(exptNum==4),'exptNum needs to be either 2, 3, or 4')


%% boilerplate

%print out info
fprintf('== Analyzing behavioral data for subject: %s == \n',num2str(subjNum))

%% subject ID


if subjNum <10
    subjStr = ['00' num2str(subjNum)];
elseif subjNum <100
    subjStr = ['0' num2str(subjNum)];
else
    subjStr = num2str(subjNum);
end


%% filepaths
%these may need to be changed based on the paths

%experiment directory
expt_dir = '/Volumes/LabGroup/Faculty-Labs/BeeversLAB/Projects/rtAT/';
assert(logical(exist(expt_dir,'dir')),sprintf('experiment directory does not exist, %s\n',expt_dir));

%project directory
if exptNum==2
    projName = '1_Behavioral/1_Old_Protocol';
elseif exptNum==3
    projName = '1_Behavioral/2_New_Protocol';
elseif exptNum==4
    projName = '2_Behavioral-Scan-Behavioral';
end
proj_dir = [expt_dir '/' projName];
assert(logical(exist(proj_dir,'dir')),sprintf('project directory does not exist: %s\n',proj_dir))

%subject directory
subj_dir = [proj_dir '/2_Data/2_MatLab/' subjStr];
assert(logical(exist(subj_dir,'dir')),sprintf('subject directory does not exist: %s\n',subj_dir));

%script directory
script_dir = [proj_dir '/2_Data/2_MatLab/scripts'];
assert(logical(exist(script_dir,'dir')),sprintf('script directory does not exist: %s\n',script_dir));
addpath(script_dir);

%directory where output should be saved
save_dir = [proj_dir '/2_Data/2_MatLab/results/'];
assert(logical(exist(save_dir,'dir')),sprintf('directory where output should be saved does not exist; %s\n',save_dir));


%% plotting options

plotSize=[1 1 1000 550]; %default plot size


%% find all run numbers

cd(subj_dir)
[runnums,blockdatafilenames] = GrabFileInfo(subj_dir,'blockdata'); %obtain list of output filenames 
nruns = runnums(end); %total number of runs
fprintf('subject has %d runs\n',nruns)

nblocks = 8;

%pre-allocate
block = nan(nruns,nblocks);
type = nan(nruns,nblocks);
attCateg = nan(nruns,nblocks);
inattCateg = nan(nruns,nblocks);
trialsPerBlock = nan(nruns,nblocks);
trial = cell(nruns,nblocks);
trialLabel = cell(nruns,nblocks);
trialCount = cell(nruns,nblocks);
corrresps = cell(nruns,nblocks);
rts = cell(nruns,nblocks);
resps = cell(nruns,nblocks);
accs = cell(nruns,nblocks);
pulses = cell(nruns,nblocks);
classOutputFileLoad = cell(nruns,nblocks);
classOutputFile = cell(nruns,nblocks);
categsep = cell(nruns,nblocks);
attImgProp = cell(nruns,nblocks);
smoothAttImgProp = cell(nruns,nblocks);
categs = cell(nruns,nblocks);
images = cell(nruns,nblocks);
files = cell(nruns,nblocks);

%load files & assemble matrices
for iRun = 1:nruns
    fprintf('loading file: %s\n',blockdatafilenames{iRun});
    load(blockdatafilenames{iRun});

    block(iRun,:) = [blockData.block];
    type(iRun,:) = [blockData.type];
    attCateg(iRun,:) = [blockData.attCateg];
    inattCateg(iRun,:) = [blockData.inattCateg];
    trialsPerBlock(iRun,:) = [blockData.trialsPerBlock];
    trial(iRun,:) = {blockData.trial};
    trialLabel(iRun,:) = {blockData.trialLabel};
    trialCount(iRun,:) = {blockData.trialCount};
    corrresps(iRun,:) = {blockData.corrresps};
    rts(iRun,:) = {blockData.rts};
    resps(iRun,:) = {blockData.resps};
    accs(iRun,:) = {blockData.accs};
    pulses(iRun,:) = {blockData.pulses};
    classOutputFileLoad(iRun,:) = {blockData.classOutputFileLoad};
    classOutputFile(iRun,:) = {blockData.classOutputFile};
    categsep(iRun,:) = {blockData.categsep};
    attImgProp(iRun,:) = {blockData.attImgProp};
    smoothAttImgProp(iRun,:) = {blockData.smoothAttImgProp};
    categs(iRun,:) = {blockData.categs};
    images(iRun,:) = {blockData.images};
    files(iRun,:) = {blockData.files};
end

%remove last block data file
clearvars blockData


%% clean up the data

%convert RTs to ms
rtsMsec = cellfun(@(x) x*1000, rts,'UniformOutput',false);

%find lure trial locations
lureTrials = cellfun(@(x) isnan(x),corrresps,'UniformOutput',false);  
%find target trial locations
targTrials = cellfun(@(x) ~isnan(x),corrresps,'UniformOutput',false);

attnF_distS.blocks = intersect(find(attCateg==2),find(cell2mat(cellfun(@(x) any(x{2}<=4),categs,'UniformOutput',false))));
attsdF_distS.blocks = intersect(find(attCateg==2),find(cell2mat(cellfun(@(x) any(x{2}>4),categs,'UniformOutput',false))));
attS_distnF.blocks = intersect(find(attCateg==1),find(cell2mat(cellfun(@(x) any(x{2}<=4),categs,'UniformOutput',false))));
attS_distsdF.blocks = intersect(find(attCateg==1),find(cell2mat(cellfun(@(x) any(x{2}>4),categs,'UniformOutput',false))));

%find the RTs for the stable and emotional distractors
attnF_distS.RTs = [rtsMsec{attnF_distS.blocks}];
attsdF_distS.RTs = [rtsMsec{attsdF_distS.blocks}];
attS_distnF.RTs = [rtsMsec{attS_distnF.blocks}];
attS_distsdF.RTs = [rtsMsec{attS_distsdF.blocks}];

%temporary accuracy of all trials 
attnF_distS.accs = [accs{attnF_distS.blocks}];
attsdF_distS.accs = [accs{attsdF_distS.blocks}];
attS_distnF.accs = [accs{attS_distnF.blocks}];
attS_distsdF.accs = [accs{attS_distsdF.blocks}];

%% rts trend

%trials before and after lure
rtWindow = 6;

for iRun = runnums;
    for iBlock = 1:nblocks;
        %lureAccs{iRun,iBlock} = accs{iRun,iBlock}(lureTrials{iRun,iBlock})~=0; %#ok<NASGU>
        lureRTs{iRun,iBlock} = rtsMsec{iRun,iBlock}(lureTrials{iRun,iBlock}); %#ok<AGROW>
        %targetRTs{iRun,iBlock} = rtsMsec{iRun,iBlock}(targTrials{iRun,iBlock});
        lureTrialNums{iRun,iBlock} = find(lureTrials{iRun,iBlock}); %#ok<AGROW>
        
        rts_afterLures{iRun,iBlock} = NaN(rtWindow,numel(lureTrialNums{iRun,iBlock})); %#ok<AGROW>
        accs_afterLures{iRun,iBlock} = NaN(rtWindow,numel(lureTrialNums{iRun,iBlock})); %#ok<AGROW>
        for iLure = 1:numel(lureTrialNums{iRun,iBlock})
            trialNums_beforeLures{iRun,iBlock}(:,iLure) = lureTrialNums{iRun,iBlock}(iLure)-(6:-1:1); %#ok<AGROW>
            rts_beforeLures{iRun,iBlock}(:,iLure) = rtsMsec{iRun,iBlock}(trialNums_beforeLures{iRun,iBlock}(:,iLure)); %#ok<AGROW>
            %accs_beforeLures{iRun,iBlock}(:,iLure) = accs{iRun,iBlock}(trialNums_beforeLures{iRun,iBlock}(:,iLure))~=0;   
            
            trialNums_afterLures{iRun,iBlock}(:,iLure) = lureTrialNums{iRun,iBlock}(iLure)+(1:6); %#ok<AGROW>
            for i = 1:rtWindow
                if (trialNums_afterLures{iRun,iBlock}(i,iLure)<=50)
                    rts_afterLures{iRun,iBlock}(i,iLure) = rtsMsec{iRun,iBlock}(trialNums_afterLures{iRun,iBlock}(i,iLure)); %#ok<AGROW>
                    accs_afterLures{iRun,iBlock}(i,iLure) = accs{iRun,iBlock}(trialNums_afterLures{iRun,iBlock}(i,iLure))~=0; %#ok<AGROW>
                else
                    rts_afterLures{iRun,iBlock}(i,iLure) = NaN; %#ok<AGROW>
                    accs_afterLures{iRun,iBlock}(i,iLure) = NaN; %#ok<AGROW>
                end
            end
            
        end
    end
end

%% block stats

blockBehav.nTarg = cell2mat(cellfun(@(x) sum(x),targTrials,'UniformOutput',false));  %number of targets per block
blockBehav.nTargCor = cell2mat(cellfun(@(x) sum(x==1),accs,'UniformOutput',false));  %correct reject per block
blockBehav.nTargErr  = blockBehav.nTarg - blockBehav.nTargCor;                       %false alarm per block

blockBehav.nLure = cell2mat(cellfun(@(x) sum(x),lureTrials,'UniformOutput',false));  %number of lures per block
blockBehav.nLureCor = cell2mat(cellfun(@(x) sum(x==2),accs,'UniformOutput',false));  %correct reject per block
blockBehav.nLureErr  = blockBehav.nLure - blockBehav.nLureCor;                       %false alarm per block

blockBehav.hitRate = blockBehav.nTargCor./blockBehav.nTarg;
blockBehav.missRate = 1-blockBehav.hitRate;
blockBehav.corrrejRate = blockBehav.nLureCor./blockBehav.nLure;
blockBehav.falsealarmRate = 1-blockBehav.corrrejRate;

%% run stats

%collapsing across conditions
runBehav.nTarg = sum(blockBehav.nTarg,2);
runBehav.nTargCor = sum(blockBehav.nTargCor,2);
runBehav.nTargErr = runBehav.nTarg - runBehav.nTargCor;

runBehav.nLure = sum(blockBehav.nLure,2);
runBehav.nLureCor = sum(blockBehav.nLureCor,2);
runBehav.nLureErr = runBehav.nLure - runBehav.nLureCor;

runBehav.hitrate = runBehav.nTargCor./runBehav.nTarg;
runBehav.missrate = 1-runBehav.hitrate;
runBehav.corrrejrate = runBehav.nLureCor./runBehav.nLure;
runBehav.falsealarmrate = 1-runBehav.corrrejrate; %#ok<STRNU>


%% rt trend

attnF_distS.allRTsbeforeLures = [rts_beforeLures{attnF_distS.blocks}];
attsdF_distS.allRTsbeforeLures = [rts_beforeLures{attsdF_distS.blocks}];
attS_distnF.allRTsbeforeLures = [rts_beforeLures{attS_distnF.blocks}];
attS_distsdF.allRTsbeforeLures = [rts_beforeLures{attS_distsdF.blocks}];

attnF_distS.allRTsLure = [lureRTs{attnF_distS.blocks}];
attsdF_distS.allRTsLure = [lureRTs{attnF_distS.blocks}];
attS_distnF.allRTsLure = [lureRTs{attS_distnF.blocks}];
attS_distsdF.allRTsLure = [lureRTs{attS_distsdF.blocks}];

attnF_distS.allRTsafterLures = [rts_afterLures{attnF_distS.blocks}];
attsdF_distS.allRTsafterLures = [rts_afterLures{attnF_distS.blocks}];
attS_distnF.allRTsafterLures = [rts_afterLures{attS_distnF.blocks}];
attS_distsdF.allRTsafterLures = [rts_afterLures{attS_distsdF.blocks}];


%% subject stats

%collapsing across all condition
subBehav.nTarg = sum(sum(blockBehav.nTarg));
subBehav.nTargCor = sum(sum(blockBehav.nTargCor));
subBehav.nTargErr = subBehav.nTarg-subBehav.nTargCor;

subBehav.nLure = sum(sum(blockBehav.nLure));
subBehav.nLureCor = sum(sum(blockBehav.nLureCor));
subBehav.nLureErr = subBehav.nLure-subBehav.nLureCor;

subBehav.hitRate = subBehav.nTargCor/subBehav.nTarg;
subBehav.missRate = 1-subBehav.hitRate;
subBehav.corrrejRate = subBehav.nLureCor/subBehav.nLure;
subBehav.falsealarmRate = 1-subBehav.corrrejRate;

%splitting into different conditions
attnF_distS.nTarg = sum(blockBehav.nTarg(attnF_distS.blocks));
attnF_distS.nTargCor = sum(blockBehav.nTargCor(attnF_distS.blocks));
attnF_distS.nTargErr = attnF_distS.nTarg - attnF_distS.nTargCor;
attnF_distS.nLure = sum(blockBehav.nLure(attnF_distS.blocks));
attnF_distS.nLureCor = sum(blockBehav.nLureCor(attnF_distS.blocks));
attnF_distS.nLureErr = attnF_distS.nLure - attnF_distS.nLureCor;
attnF_distS.hitRate = attnF_distS.nTargCor/attnF_distS.nTarg;
attnF_distS.missRate = 1-attnF_distS.hitRate;
attnF_distS.corrrejRate = attnF_distS.nLureCor/attnF_distS.nLure;
attnF_distS.falsealarmRate = 1-attnF_distS.corrrejRate;

attsdF_distS.nTarg = sum(blockBehav.nTarg(attsdF_distS.blocks));
attsdF_distS.nTargCor = sum(blockBehav.nTargCor(attsdF_distS.blocks));
attsdF_distS.nTargErr = attsdF_distS.nTarg - attsdF_distS.nTargCor;
attsdF_distS.nLure = sum(blockBehav.nLure(attsdF_distS.blocks));
attsdF_distS.nLureCor = sum(blockBehav.nLureCor(attsdF_distS.blocks));
attsdF_distS.nLureErr = attsdF_distS.nLure - attsdF_distS.nLureCor;
attsdF_distS.hitRate = attsdF_distS.nTargCor/attsdF_distS.nTarg;
attsdF_distS.missRate = 1-attsdF_distS.hitRate;
attsdF_distS.corrrejRate = attsdF_distS.nLureCor/attsdF_distS.nLure;
attsdF_distS.falsealarmRate = 1-attsdF_distS.corrrejRate;

attS_distnF.nTarg = sum(blockBehav.nTarg(attS_distnF.blocks));
attS_distnF.nTargCor = sum(blockBehav.nTargCor(attS_distnF.blocks));
attS_distnF.nTargErr = attS_distnF.nTarg - attS_distnF.nTargCor;
attS_distnF.nLure = sum(blockBehav.nLure(attS_distnF.blocks));
attS_distnF.nLureCor = sum(blockBehav.nLureCor(attS_distnF.blocks));
attS_distnF.nLureErr = attS_distnF.nLure - attS_distnF.nLureCor;
attS_distnF.hitRate = attS_distnF.nTargCor/attS_distnF.nTarg;
attS_distnF.missRate = 1-attS_distnF.hitRate;
attS_distnF.corrrejRate = attS_distnF.nLureCor/attS_distnF.nLure;
attS_distnF.falsealarmRate = 1-attS_distnF.corrrejRate;

attS_distsdF.nTarg = sum(blockBehav.nTarg(attS_distsdF.blocks));
attS_distsdF.nTargCor = sum(blockBehav.nTargCor(attS_distsdF.blocks));
attS_distsdF.nTargErr = attS_distsdF.nTarg - attS_distsdF.nTargCor;
attS_distsdF.nLure = sum(blockBehav.nLure(attS_distsdF.blocks));
attS_distsdF.nLureCor = sum(blockBehav.nLureCor(attS_distsdF.blocks));
attS_distsdF.nLureErr = attS_distsdF.nLure - attS_distsdF.nLureCor;
attS_distsdF.hitRate = attS_distsdF.nTargCor/attS_distsdF.nTarg;
attS_distsdF.missRate = 1-attS_distsdF.hitRate;
attS_distsdF.corrrejRate = attS_distsdF.nLureCor/attS_distsdF.nLure;
attS_distsdF.falsealarmRate = 1-attS_distsdF.corrrejRate;


%% behavioral information 

fprintf('Percent Lure Trials Correct: %.3f\n',subBehav.corrrejRate*100);
fprintf('Percent Target Trials Correct: %.3f\n',subBehav.hitRate*100);

[subBehav.dPrime,subBehav.beta,subBehav.C] = dprime(subBehav.hitRate,subBehav.falsealarmRate,subBehav.nTarg,subBehav.nLure);

[attnF_distS.dPrime,attnF_distS.beta,attnF_distS.C] = dprime(attnF_distS.hitRate,attnF_distS.falsealarmRate,attnF_distS.nTarg,attnF_distS.nLure);
[attsdF_distS.dPrime,attsdF_distS.beta,attsdF_distS.C] = dprime(attsdF_distS.hitRate,attsdF_distS.falsealarmRate,attsdF_distS.nTarg,attsdF_distS.nLure);
[attS_distnF.dPrime,attS_distnF.beta,attS_distnF.C] = dprime(attS_distnF.hitRate,attS_distnF.falsealarmRate,attS_distnF.nTarg,attS_distnF.nLure);
[attS_distsdF.dPrime,attS_distsdF.beta,attS_distsdF.C] = dprime(attS_distsdF.hitRate,attS_distsdF.falsealarmRate,attS_distsdF.nTarg,attS_distsdF.nLure);

fprintf('\n')
fprintf('dprime = %.3f\n',subBehav.dPrime);
fprintf('beta = %.3f\n',subBehav.beta);
fprintf('C = %.3f\n',subBehav.C);

subBehav.aPrime = .5 + ((subBehav.hitRate-subBehav.falsealarmRate)*(1+subBehav.hitRate-subBehav.falsealarmRate))/(4*subBehav.hitRate*(1-subBehav.falsealarmRate));
subBehav.B_D = ((1-subBehav.hitRate)*(1-subBehav.falsealarmRate)-(subBehav.hitRate*subBehav.falsealarmRate))/((1-subBehav.hitRate)*(1-subBehav.falsealarmRate)+(subBehav.hitRate*subBehav.falsealarmRate));

attnF_distS.aPrime = .5 + ((attnF_distS.hitRate-attnF_distS.falsealarmRate)*(1+attnF_distS.hitRate-attnF_distS.falsealarmRate))/(4*attnF_distS.hitRate*(1-attnF_distS.falsealarmRate));
attnF_distS.B_D = ((1-attnF_distS.hitRate)*(1-attnF_distS.falsealarmRate)-(attnF_distS.hitRate*attnF_distS.falsealarmRate))/((1-attnF_distS.hitRate)*(1-attnF_distS.falsealarmRate)+(attnF_distS.hitRate*attnF_distS.falsealarmRate));
attsdF_distS.aPrime = .5 + ((attsdF_distS.hitRate-attsdF_distS.falsealarmRate)*(1+attsdF_distS.hitRate-attsdF_distS.falsealarmRate))/(4*attsdF_distS.hitRate*(1-attsdF_distS.falsealarmRate));
attsdF_distS.B_D = ((1-attsdF_distS.hitRate)*(1-attsdF_distS.falsealarmRate)-(attsdF_distS.hitRate*attsdF_distS.falsealarmRate))/((1-attsdF_distS.hitRate)*(1-attsdF_distS.falsealarmRate)+(attsdF_distS.hitRate*attsdF_distS.falsealarmRate));

attS_distnF.aPrime = .5 + ((attS_distnF.hitRate-attS_distnF.falsealarmRate)*(1+attS_distnF.hitRate-attS_distnF.falsealarmRate))/(4*attS_distnF.hitRate*(1-attS_distnF.falsealarmRate));
attS_distnF.B_D = ((1-attS_distnF.hitRate)*(1-attS_distnF.falsealarmRate)-(attS_distnF.hitRate*attS_distnF.falsealarmRate))/((1-attS_distnF.hitRate)*(1-attS_distnF.falsealarmRate)+(attS_distnF.hitRate*attS_distnF.falsealarmRate));
attS_distsdF.aPrime = .5 + ((attS_distsdF.hitRate-attS_distsdF.falsealarmRate)*(1+attS_distsdF.hitRate-attS_distsdF.falsealarmRate))/(4*attS_distsdF.hitRate*(1-attS_distsdF.falsealarmRate));
attS_distsdF.B_D = ((1-attS_distsdF.hitRate)*(1-attS_distsdF.falsealarmRate)-(attS_distsdF.hitRate*attS_distsdF.falsealarmRate))/((1-attS_distsdF.hitRate)*(1-attS_distsdF.falsealarmRate)+(attS_distsdF.hitRate*attS_distsdF.falsealarmRate));

%%

fprintf('Printing A'' information for various conditions\n');
fprintf('Mat ID\tnF S\tsdF S\tS nF\tS sdF\tmean A''\tA'' diff distn-distsd\n')
fprintf('%d\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n',subjNum,attnF_distS.aPrime,attsdF_distS.aPrime,attS_distnF.aPrime,attS_distsdF.aPrime,...
    mean([attnF_distS.aPrime,attsdF_distS.aPrime,attS_distnF.aPrime,attS_distsdF.aPrime]),attS_distnF.aPrime-attS_distsdF.aPrime);
fprintf('\n');


%% plot overall behavioral information

figure('Position',plotSize,'DefaultLineLineWidth',2,'DefaultAxesFontSize',16,'DefaultTextFontSize',16);

subplot(1,3,1);
hold on;
bar(1,subBehav.hitRate);
bar(2,subBehav.falsealarmRate);
title(['Behavior Subj ' num2str(subjNum)]);
set(gca,'ylim',[0 1],'xlim',[0 3],'xtick',[1 2],'xticklabel',{'Hit rate','FA rate'})

subplot(1,3,2);
hold on;
bar(1,subBehav.dPrime);
bar(2,subBehav.beta);
title(['Param measures Subj' num2str(subjNum)]);
set(gca,'xlim',[0 3],'xtick',[1 2],'xticklabel',{'d''','beta'})

subplot(1,3,3);
hold on;
bar(1,subBehav.aPrime);
bar(2,subBehav.B_D);
title(['Non-param measures Subj ' num2str(subjNum)]);
set(gca,'ylim',[-1 1],'xlim',[0 3],'xtick',[1 2],'xticklabel',{'a''','B_D'})

%save figure
figname = [num2str(subjNum) '_behav_meas'];
printfig2(fullfile(save_dir,figname),'filetype','eps');


%% plot condition behavioral information

figure('Position',plotSize,'DefaultLineLineWidth',2,'DefaultAxesFontSize',16,'DefaultTextFontSize',16);

subplot(2,2,1);
hold on;
bar(1,attnF_distS.falsealarmRate);
bar(2,attnF_distS.aPrime);
title('att n F dist S');
set(gca,'ylim',[0 1]','xlim',[0 3],'xtick',[1 2],'xticklabel',{'FA rate','a'''})

subplot(2,2,2);
hold on;
bar(1,attsdF_distS.falsealarmRate);
bar(2,attsdF_distS.aPrime);
title('att sd F dist S');
set(gca,'ylim',[0 1],'xlim',[0 3],'xtick',[1 2],'xticklabel',{'FA rate','a'''})

subplot(2,2,3);
hold on;
bar(1,attS_distnF.falsealarmRate);
bar(2,attS_distnF.aPrime);
title('att S dist n F');
set(gca,'ylim',[0 1],'xlim',[0 3],'xtick',[1 2],'xticklabel',{'FA rate','a'''})

subplot(2,2,4);
hold on;
bar(1,attS_distnF.falsealarmRate);
bar(2,attS_distnF.aPrime);
title('att S dist sd F');
set(gca,'ylim',[0 1],'xlim',[0 3],'xtick',[1 2],'xticklabel',{'FA rate','a'''})

%save figure
figname = [num2str(subjNum) '_cond_behav_meas'];
printfig2(fullfile(save_dir,figname),'filetype','eps');


%%

figure('Position',plotSize,'DefaultLineLineWidth',2,'DefaultAxesFontSize',16,'DefaultTextFontSize',16);
ylim = [300 650];
xlim = [-7 7];
xtick = ((-1*rtWindow):2:rtWindow);

subplot(2,2,1);
hold on;
h1=errorbar(-1*(rtWindow:-1:1),nanmean(attnF_distS.allRTsbeforeLures(:,isnan(attnF_distS.allRTsLure)),2),...
    nanstd(attnF_distS.allRTsbeforeLures(:,isnan(attnF_distS.allRTsLure)),[],2)./sqrt(sum(isnan(attnF_distS.allRTsLure))),'g','linewidth',2);
errorbar((1:rtWindow),nanmean(attnF_distS.allRTsafterLures(:,isnan(attnF_distS.allRTsLure)),2),...
    nanstd(attnF_distS.allRTsafterLures(:,isnan(attnF_distS.allRTsLure)),[],2)./sqrt(sum(isnan(attnF_distS.allRTsLure))),'g');
h3=errorbar(-1*rtWindow:rtWindow,...
    [nanmean(attnF_distS.allRTsbeforeLures(:,~isnan(attnF_distS.allRTsLure)),2);nanmean(attnF_distS.allRTsLure);nanmean(attnF_distS.allRTsafterLures(:,~isnan(attnF_distS.allRTsLure)),2)],...
    [nanstd(attnF_distS.allRTsbeforeLures(:,isnan(attnF_distS.allRTsLure)),[],2);nanstd(attnF_distS.allRTsLure);nanstd(attnF_distS.allRTsafterLures(:,~isnan(attnF_distS.allRTsLure)),[],2)]./sqrt(sum(isnan(attnF_distS.allRTsLure))),'r','linewidth',2);
set(gca,'ylim',ylim,'xlim',xlim,'xtick',xtick);
title('att neut F dist S');
xlabel('Trials from lure');
legend([h1 h3],{'CR','FA'},'Location','SouthEast');
ylabel('RTs (ms)');

subplot(2,2,2);
hold on;
errorbar(-1*(rtWindow:-1:1),nanmean(attsdF_distS.allRTsbeforeLures(:,isnan(attsdF_distS.allRTsLure)),2),...
    nanstd(attsdF_distS.allRTsbeforeLures(:,isnan(attsdF_distS.allRTsLure)),[],2)./sqrt(sum(isnan(attsdF_distS.allRTsLure))),'g','linewidth',2);
errorbar((1:rtWindow),nanmean(attsdF_distS.allRTsafterLures(:,isnan(attsdF_distS.allRTsLure)),2),...
    nanstd(attsdF_distS.allRTsafterLures(:,isnan(attsdF_distS.allRTsLure)),[],2)./sqrt(sum(isnan(attsdF_distS.allRTsLure))),'g');
errorbar(-1*rtWindow:rtWindow,...
    [nanmean(attsdF_distS.allRTsbeforeLures(:,~isnan(attsdF_distS.allRTsLure)),2);nanmean(attsdF_distS.allRTsLure);nanmean(attsdF_distS.allRTsafterLures(:,~isnan(attsdF_distS.allRTsLure)),2)],...
    [nanstd(attsdF_distS.allRTsbeforeLures(:,isnan(attsdF_distS.allRTsLure)),[],2);nanstd(attsdF_distS.allRTsLure);nanstd(attsdF_distS.allRTsafterLures(:,~isnan(attsdF_distS.allRTsLure)),[],2)]./sqrt(sum(isnan(attsdF_distS.allRTsLure))),'r','linewidth',2);
set(gca,'ylim',ylim,'xlim',xlim,'xtick',xtick);
title('att sad F dist S');
xlabel('Trials from lure');
ylabel('RTs (ms)');

subplot(2,2,3);
hold on;
errorbar(-1*(rtWindow:-1:1),nanmean(attS_distnF.allRTsbeforeLures(:,isnan(attS_distnF.allRTsLure)),2),...
    nanstd(attS_distnF.allRTsbeforeLures(:,isnan(attS_distnF.allRTsLure)),[],2)./sqrt(sum(isnan(attS_distnF.allRTsLure))),'g');
errorbar((1:rtWindow),nanmean(attS_distnF.allRTsafterLures(:,isnan(attS_distnF.allRTsLure)),2),...
    nanstd(attS_distnF.allRTsafterLures(:,isnan(attS_distnF.allRTsLure)),[],2)./sqrt(sum(isnan(attS_distnF.allRTsLure))),'g');
errorbar(-1*rtWindow:rtWindow,...
    [nanmean(attS_distnF.allRTsbeforeLures(:,~isnan(attS_distnF.allRTsLure)),2);nanmean(attS_distnF.allRTsLure);nanmean(attS_distnF.allRTsafterLures(:,~isnan(attS_distnF.allRTsLure)),2)],...
    [nanstd(attS_distnF.allRTsbeforeLures(:,isnan(attS_distnF.allRTsLure)),[],2);nanstd(attS_distnF.allRTsLure);nanstd(attS_distnF.allRTsafterLures(:,~isnan(attS_distnF.allRTsLure)),[],2)]./sqrt(sum(isnan(attS_distnF.allRTsLure))),'r');
set(gca,'ylim',ylim,'xlim',xlim,'xtick',xtick);
title('att S dist neut F');
xlabel('Trials from lure');

subplot(2,2,4);
hold on;
errorbar(-1*(rtWindow:-1:1),nanmean(attS_distsdF.allRTsbeforeLures(:,isnan(attS_distsdF.allRTsLure)),2),...
    nanstd(attS_distsdF.allRTsbeforeLures(:,isnan(attS_distsdF.allRTsLure)),[],2)./sqrt(sum(isnan(attS_distsdF.allRTsLure))),'g');
errorbar((1:rtWindow),nanmean(attS_distsdF.allRTsafterLures(:,isnan(attS_distsdF.allRTsLure)),2),...
    nanstd(attS_distsdF.allRTsafterLures(:,isnan(attS_distsdF.allRTsLure)),[],2)./sqrt(sum(isnan(attS_distsdF.allRTsLure))),'g');
errorbar(-1*rtWindow:rtWindow,...
    [nanmean(attS_distsdF.allRTsbeforeLures(:,~isnan(attS_distsdF.allRTsLure)),2);nanmean(attS_distsdF.allRTsLure);nanmean(attS_distsdF.allRTsafterLures(:,~isnan(attS_distsdF.allRTsLure)),2)],...
    [nanstd(attS_distsdF.allRTsbeforeLures(:,isnan(attS_distsdF.allRTsLure)),[],2);nanstd(attS_distsdF.allRTsLure);nanstd(attS_distsdF.allRTsafterLures(:,~isnan(attS_distsdF.allRTsLure)),[],2)]./sqrt(sum(isnan(attS_distsdF.allRTsLure))),'r');
set(gca,'ylim',ylim,'xlim',xlim,'xtick',xtick);
title('att S dist sad F');
xlabel('Trials from lure');

%save figure
figname = [num2str(subjNum) '_rtsaroundlures'];
printfig2(fullfile(save_dir,figname),'filetype','eps');


%%

filename = [num2str(subjNum) '_behavResults'];
save(fullfile(save_dir,filename),'blockBehav','runBehav','subBehav','attnF_distS','attsdF_distS','attS_distnF','attS_distsdF');


