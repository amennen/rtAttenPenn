% THIS SCRIPT WILL REGISTER THE FLASH AND THE MASK TO BE USED FOR DAY 21
% MAKE SURE YOU DO THE SAME BET SETTINGS AS WITH DAY 1!

subjectNum = 6; % multiday test is subject 5, intel demo is subject 3, %NK is 6, phantom is 7
runNum = 3;
dayNum = 2; % REMEMBER TO SPECIFY WHAT DAY IT IS!!
flash_hrScan = 5;
functionalScan=6;
%%
projectName = 'rtAttenPenn';
biac_dir = '/Data1/packages/BIAC_Matlab_R2014a/';
bxhpath='/opt/BXH/1.11.1/bin/';
fslpath='/opt/fsl/5.0.9/bin/';
%add necessary package
if ~exist('readmr','file')
    addpath(genpath(biac_dir));
    addpath([biac_dir '/mr/']);
    addpath([biac_dir '/general/'])
end
setenv('FSLOUTPUTTYPE','NIFTI_GZ');
dataDirHeader = pwd; % this has to be in the code directory
save_dir = fullfile(dataDirHeader,['/data/' num2str(subjectNum), '/day' num2str(dayNum)]);
process_dir1 = fullfile(dataDirHeader,['/data/' num2str(subjectNum), '/day' num2str(1) '/reg' '/']);
process_dir_today = [save_dir '/' 'reg' '/'];
roi_name = 'wholebrain_mask';
roi_dir = pwd; % change this path name to wherever you put it on the penn computer!
code_dir = pwd;
addpath(genpath(code_dir));

if ~exist(process_dir_today)
    mkdir(process_dir_today)
end
cd(process_dir_today)
%% now register for second day mask

subjDate2 = '1-22-18';%'9-22-17';
subjectName2 = [datestr(subjDate2,5) datestr(subjDate2,7) datestr(subjDate2,11) num2str(runNum) '_' projectName];
dicom_dir2 = ['/Data1/subjects/' datestr(subjDate2,10) datestr(subjDate2,5) datestr(subjDate2,7) '.' subjectName2 '.' subjectName2 '/'];
%subjectName2 = [datestr(now,5) datestr(now,7) datestr(now,11) num2str(runNum) '_' projectName];
%dicom_dir2 = ['/Data1/subjects/' datestr(now,10) datestr(now,5) datestr(now,7) '.' subjectName2 '.' subjectName2 '/'];

%%
% get both flashes ready

flashhrFN = 'flashhr';
flashhrFN_RE = 'flashhr_re';
flashhrfiles_genstr = sprintf('%s001_0000%s_0*',dicom_dir2,num2str(flash_hrScan,'%2.2i')); 
unix(sprintf('%sdicom2bxh %s %s.bxh',bxhpath,flashhrfiles_genstr,flashhrFN));
unix(sprintf('%sbxhreorient --orientation=LAS %s.bxh %s.bxh',bxhpath,flashhrFN,flashhrFN_RE));
unix(sprintf('%sbxh2analyze --overwrite --analyzetypes --niigz --niftihdr -s %s.bxh %s',bxhpath,flashhrFN_RE,flashhrFN_RE))
unix(sprintf('%sbet %s.nii.gz %s_brain.nii.gz -R -m',fslpath,flashhrFN_RE,flashhrFN_RE)) 
fprintf('%sfslview %s_brain.nii.gz', fslpath,flashhrFN_RE)
%%
% flashlrFN = 'flashlr';
% flashlrFN_RE = 'flashlr_re';
% flashlrfiles_genstr = sprintf('%s001_0000%s_0*',dicom_dir2,num2str(flash_lrScan,'%2.2i')); 
% unix(sprintf('%sdicom2bxh %s %s.bxh',bxhpath,flashlrfiles_genstr,flashlrFN));
% unix(sprintf('%sbxhreorient --orientation=LAS %s.bxh %s.bxh',bxhpath,flashlrFN,flashlrFN_RE));
% unix(sprintf('%sbxh2analyze --overwrite --analyzetypes --niigz --niftihdr -s %s.bxh %s',bxhpath,flashlrFN_RE,flashlrFN_RE))
% unix(sprintf('%sbet %s.nii.gz %s_brain.nii.gz -R -m',fslpath,flashlrFN_RE,flashlrFN_RE)) 

% get epi 2 ready

fileN = 6; 
functionalFN = 'exfunc';
functionalFN_RE = 'exfunc_re';
functional2FN = 'exfunc2';
functional2FN_RE = 'exfunc2_re';
exfunc_str = sprintf('%s001_0000%s_0000%s.dcm',dicom_dir2,num2str(functionalScan,'%2.2i'),num2str(fileN,'%2.2i')); %general string for ALL mprage files**
unix(sprintf('%sdicom2bxh %s %s.bxh',bxhpath,exfunc_str,functional2FN));
unix(sprintf('%sbxhreorient --orientation=LAS %s.bxh %s.bxh',bxhpath,functional2FN,functional2FN_RE));
unix(sprintf('%sbxh2analyze --overwrite --analyzetypes --niigz --niftihdr -s %s.bxh %s',bxhpath,functional2FN_RE,functional2FN_RE))
%unix(sprintf('%sbet %s.nii.gz %s_brain.nii.gz -R -m',fslpath,functional2FN_RE,functional2FN_RE)) 

% now check okay and make bxh 
%fprintf('%sfslview %s_brain.nii.gz', fslpath,functional2FN_RE)
%% if okay make functional into bxh file
% if exist(sprintf('%s_brain.nii.gz',functional2FN_RE),'file')
%     unix(sprintf('gunzip %s_brain.nii.gz',functional2FN_RE));
% end
% unix(sprintf('%sbxhabsorb %s_brain.nii %s_brain.bxh',bxhpath,functional2FN_RE,functional2FN_RE));

%% REGISTRATION
% repeat over with flash scans being scan numbers 7 AND OR 8!!!
% go directly from exfunc1 --> exfunc 2
% now you have a mask in func 2 space!
unix(sprintf('%sflirt -dof 6 -in %s%s_brain.nii.gz -ref %s_brain.nii.gz -out func12func2 -omat func12func2.mat', fslpath, process_dir1,functionalFN_RE,functional2FN_RE))
% 3. apply old mask - apply mask to func12func2
unix(sprintf('%sflirt -in %swholebrain_mask_exfunc -ref %s_brain.nii.gz -applyxfm -init func12func2.mat -interp nearestneighbour -out mask12func2', fslpath, process_dir1,functional2FN_RE))

%% NOW CREATE MASK IN MATLAB

% this is where you would make the mask bigger
vol = ReadFile(exfunc_str,64,0);
mask = BrainMask(vol,0,0);
imagesc(mask(:,:,10)); %checks that the dicom files are properly aligned
save(['mask_wholeBrain' '.mat'], 'mask');

startMask = GetSecs;
%load registered anatomical ROI
regmask = 'mask12func2';
if exist(sprintf('%s.nii.gz',regmask),'file')
    unix(sprintf('gunzip %s.nii.gz',regmask));
end
unix(sprintf('%sbxhabsorb %s.nii %s.bxh',bxhpath,regmask,regmask));
maskStruct = readmr([regmask '.bxh'],'BXH',{[],[],[]});
%brainExtFunc = readmr([functional2FN_RE '_brain.bxh'], 'BXH',{[],[],[]});

%rotate anatomical ROI to be in the same space as the mask - check that this works for different scans/ROIs
anatMaskRot = zeros(size(mask));
%brainExtRot = zeros(size(mask));
for i = 1:size(maskStruct.data,3)
    anatMaskRot(:,:,i) = rot90(maskStruct.data(:,:,i)); %rotates entire slice by 90 degrees
    %brainExtRot(:,:,i) = rot90(brainExtFunc.data(:,:,i));
end

%overwrite whole-brain mask
mask = logical(anatMaskRot); %make it so it's just 1's and 0's
%brainExt = logical(brainExtRot);
allinMask = find(anatMaskRot);
%allinBrainExt = find(brainExt);
%mask_indices = allinMask(find(ismember(allinMask,allinBrainExt))); %these are the good mask indices that are only brain
mask_indices = allinMask; % don't worry about if not in exfunc bc could remove some frontal regions
[gX gY gZ] = ind2sub(size(mask),mask_indices);
mask_brain = zeros(size(mask,1),size(mask,2),size(mask,3));
for j=1:length(mask_indices)
    mask_brain(gX(j),gY(j),gZ(j)) = 1;
end

checkMask = 1;
if checkMask
    plot3Dbrain(mask,[], 'mask')    
    plot3Dbrain(mask_brain, [], 'mask_brain')
end
% use the mask that has been checked there's nothing outside the functional
% brain
mask=mask_brain;
%save anatomical mask
save([code_dir '/data/' num2str(subjectNum) '/day' num2str(dayNum) '/mask_' num2str(subjectNum) '_' num2str(dayNum)],'mask');

fprintf('Done with mask creation\n');
% if cd into the directory, cd out of it back to the general exp folder
cd(code_dir)



