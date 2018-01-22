% declare things that don't change across days

subjectNum = 5; % multiday test is subject 5, intel demo is subject 3
matchNum = 0;
projectName = 'rtAttenPenn';
highresScan = 5;
functionalScan=6;
flash_hrScan = 7;
flash_lrScan = 8;

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
project_folder = '/Data1/code/rtAttenPenn';
if matchNum == 0
    save_dir = [project_folder '/data/' num2str(subjectNum)];
else
    save_dir = [project_folder '/data/' num2str(matchNum) '_match'];
end
process_dir = [save_dir '/' 'reg' '/'];
roi_name = 'wholebrain_mask';
roi_dir = pwd; % change this path name to wherever you put it on the penn computer!
code_dir = pwd;
addpath(genpath(code_dir));

if ~exist(process_dir)
    mkdir(process_dir)
end
cd(process_dir)
%% 
subjDate1 = '9-22-17';
runNum = 1;
subjectName1 = [datestr(subjDate1,5) datestr(subjDate1,7) datestr(subjDate1,11) num2str(runNum) '_' projectName];
dicom_dir1 = ['/Data1/subjects/' datestr(subjDate1,10) datestr(subjDate1,5) datestr(subjDate1,7) '.' subjectName1 '.' subjectName1 '/'];

%% now do steps registration for first day scans to make the mask

%% Process t1-weighted MPRAGE and check brain extraction!
highresFN = 'highres';
highresFN_RE = 'highres_re';
highresfiles_genstr = sprintf('%s001_0000%s_0*',dicom_dir,num2str(highresScan,'%2.2i')); %general string for ALL mprage files**
unix(sprintf('%sdicom2bxh %s %s.bxh',bxhpath,highresfiles_genstr,highresFN));
unix(sprintf('%sbxhreorient --orientation=LAS %s.bxh %s.bxh',bxhpath,highresFN,highresFN_RE));
unix(sprintf('%sbxh2analyze --overwrite --analyzetypes --niigz --niftihdr -s %s.bxh %s',bxhpath,highresFN_RE,highresFN_RE))
unix(sprintf('%sbet %s.nii.gz %s_brain.nii.gz -R -m',fslpath,highresFN_RE,highresFN_RE)) 
%unix(sprintf('%sbet %s.nii.gz %s_brain.nii.gz -r 90 -R',fslpath,highresFN_RE,highresFN_RE)) 

% for dcm2niix the command would be 'dcm2niix dicomdir -f test -o dicomdir -s y dicomdir/001_000007_000008.dcm'
fprintf('%sfslview %s.nii.gz\n',fslpath,highresFN_RE)
fprintf('%sfslview %s_brain.nii.gz', fslpath,highresFN_RE)
% Register standard to nifti
StartReg = GetSecs;
unix(sprintf('%sflirt -in %s_brain.nii.gz -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz -out highres2standard -omat highres2standard.mat -cost corratio -dof 12 -searchrx -30 30 -searchry -30 30 -searchrz -30 30 -interp trilinear',fslpath,highresFN_RE));
unix(sprintf('%sfnirt --iout=highres2standard_head --in=%s.nii.gz --aff=highres2standard.mat --cout=highres2standard_warp --iout=highres2standard --jout=highres2highres_jac --config=T1_2_MNI152_2mm --ref=$FSLDIR/data/standard/MNI152_T1_2mm.nii.gz --refmask=$FSLDIR/data/standard/MNI152_T1_2mm_brain_mask_dil --warpres=10,10,10', fslpath,highresFN_RE));
unix(sprintf('%sapplywarp -i %s_brain.nii.gz -r $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz -o highres2standard -w highres2standard_warp',fslpath,highresFN_RE));
%compute inverse transform (standard to highres)
unix(sprintf('%sconvert_xfm -inverse -omat standard2highres.mat highres2standard.mat', fslpath));
unix(sprintf('%sinvwarp -w highres2standard_warp -o standard2highres_warp -r %s_brain.nii.gz',fslpath,highresFN_RE));
t.standard2highres = GetSecs - StartReg;
fprintf('Done with standard2highres registration. Time = %6.2f \n',t.standard2highres);

%% Process example epi file

startFunctional = GetSecs;

fileN = 6; % we can choose 10 later2
functionalFN = 'exfunc';
functionalFN_RE = 'exfunc_re';
exfunc_str = sprintf('%s001_0000%s_0000%s.dcm',dicom_dir,num2str(functionalScan,'%2.2i'),num2str(fileN,'%2.2i')); %general string for ALL mprage files**
unix(sprintf('%sdicom2bxh %s %s.bxh',bxhpath,exfunc_str,functionalFN));
unix(sprintf('%sbxhreorient --orientation=LAS %s.bxh %s.bxh',bxhpath,functionalFN,functionalFN_RE));
unix(sprintf('%sbxh2analyze --overwrite --analyzetypes --niigz --niftihdr -s %s.bxh %s',bxhpath,functionalFN_RE,functionalFN_RE))

% now register to highres!
t1 = GetSecs;
exfunc2highres_mat='example_func2highres';
highres2exfunc_mat='highres2example_func';
unix(sprintf('%sepi_reg --epi=%s --t1=%s --t1brain=%s_brain --out=%s',fslpath,functionalFN_RE,highresFN_RE,highresFN_RE,exfunc2highres_mat))
timefunc2highres = GetSecs-t1;
unix(sprintf('%sconvert_xfm -inverse -omat %s.mat %s.mat',fslpath,highres2exfunc_mat,exfunc2highres_mat));

% now register mask to all data
unix(sprintf('%sapplywarp -i %s/%s.nii.gz -r %s.nii.gz -o %s_exfunc.nii.gz -w standard2highres_warp.nii.gz --postmat=%s.mat',fslpath,roi_dir,roi_name,functionalFN_RE,roi_name,highres2exfunc_mat));
% check after here that the applied warp is binary and in the right
% orientation so we could just apply to nifti files afterwards
if exist(sprintf('%s_exfunc.nii.gz',roi_name),'file')
    unix(sprintf('gunzip %s_exfunc.nii.gz',roi_name));
end
unix(sprintf('%sbxhabsorb %s_exfunc.nii %s_exfunc.bxh',bxhpath,roi_name,roi_name));

% brain extract functional scan to make sure we stay inside the brain of
% the subject!
unix(sprintf('%sbet %s.nii.gz %s_brain -R -m',fslpath,functionalFN_RE,functionalFN_RE)); % check that this is okay!
%CHECK OKAY
fprintf('%sfslview %s_brain_mask.nii.gz', fslpath,functionalFN_RE)

t.standard2func = GetSecs - startFunctional;
fprintf('Done with standard2func registration, time = %6.2f', t.standard2func);

%% create mask file for real-time dicom files
% this is where you would make the mask bigger
vol = ReadFile(exfunc_str,64,0);
mask = BrainMask(vol,0,0);
imagesc(mask(:,:,10)); %checks that the dicom files are properly aligned
save(['mask_wholeBrain' '.mat'], 'mask');


startMask = GetSecs;
%load registered anatomical ROI
maskStruct = readmr([roi_name '_exfunc.bxh'],'BXH',{[],[],[]});
brainExtFunc = readmr([functionalFN_RE '_brain.bxh'], 'BXH',{[],[],[]});

%rotate anatomical ROI to be in the same space as the mask - check that this works for different scans/ROIs
anatMaskRot = zeros(size(mask));
brainExtRot = zeros(size(mask));
for i = 1:size(maskStruct.data,3)
    anatMaskRot(:,:,i) = rot90(maskStruct.data(:,:,i)); %rotates entire slice by 90 degrees
    brainExtRot(:,:,i) = rot90(brainExtFunc.data(:,:,i));
end

%overwrite whole-brain mask
mask = logical(anatMaskRot); %make it so it's just 1's and 0's
brainExt = logical(brainExtRot);
allinMask = find(anatMaskRot);
allinBrainExt = find(brainExt);
mask_indices = allinMask(find(ismember(allinMask,allinBrainExt))); %these are the good mask indices that are only brain
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
if matchNum == 0
    save([code_dir '/data/' num2str(subjectNum) '/mask_' num2str(subjectNum)],'mask');
else
    save([code_dir '/data/' num2str(matchNum) '_match/mask_' num2str(subjectNum)],'mask');
end

fprintf('Done with mask creation\n');
t.mask = GetSecs - startMask;
t.total = GetSecs - startProcess;
save(fullfile(process_dir, 'timing'), 't');
fprintf('Standard2highres time = %7.2f \nStandard2func time = %7.2f \nMask time = %7.2f \n Total time = %7.2f\n', t.standard2highres, t.standard2func,t.mask,t.total);
% if cd into the directory, cd out of it back to the general exp folder
cd(code_dir)


%% now register for second day mask
subjDate2 = '9-22-17';
runNum = 3;
subjectName2 = [datestr(subjDate2,5) datestr(subjDate2,7) datestr(subjDate2,11) num2str(runNum) '_' projectName];
dicom_dir2 = ['/Data1/subjects/' datestr(subjDate2,10) datestr(subjDate2,5) datestr(subjDate2,7) '.' subjectName2 '.' subjectName2 '/'];

% get both flashes ready

flashhrFN = 'flashhr';
flashhrFN_RE = 'flashhr_re';
flashhrfiles_genstr = sprintf('%s001_0000%s_0*',dicom_dir,num2str(flash_hrScan,'%2.2i')); 
unix(sprintf('%sdicom2bxh %s %s.bxh',bxhpath,flashhrfiles_genstr,flashhrFN));
unix(sprintf('%sbxhreorient --orientation=LAS %s.bxh %s.bxh',bxhpath,flashhrFN,flashhrFN_RE));
unix(sprintf('%sbxh2analyze --overwrite --analyzetypes --niigz --niftihdr -s %s.bxh %s',bxhpath,flashhrFN_RE,flashhrFN_RE))
unix(sprintf('%sbet %s.nii.gz %s_brain.nii.gz -R -m',fslpath,flashhrFN_RE,flashhrFN_RE)) 

flashlrFN = 'flashlr';
flashlrFN_RE = 'flashlr_re';
flashlrfiles_genstr = sprintf('%s001_0000%s_0*',dicom_dir,num2str(flash_lrScan,'%2.2i')); 
unix(sprintf('%sdicom2bxh %s %s.bxh',bxhpath,flashlrfiles_genstr,flashlrFN));
unix(sprintf('%sbxhreorient --orientation=LAS %s.bxh %s.bxh',bxhpath,flashlrFN,flashlrFN_RE));
unix(sprintf('%sbxh2analyze --overwrite --analyzetypes --niigz --niftihdr -s %s.bxh %s',bxhpath,flashlrFN_RE,flashlrFN_RE))
unix(sprintf('%sbet %s.nii.gz %s_brain.nii.gz -R -m',fslpath,flashlrFN_RE,flashlrFN_RE)) 

% get epi 2 ready

fileN = 6; % we can choose 10 later2
functional2FN = 'exfunc2';
functional2FN_RE = 'exfunc2_re';
exfunc_str = sprintf('%s001_0000%s_0000%s.dcm',dicom_dir,num2str(functionalScan,'%2.2i'),num2str(fileN,'%2.2i')); %general string for ALL mprage files**
unix(sprintf('%sdicom2bxh %s %s.bxh',bxhpath,exfunc_str,functional2FN));
unix(sprintf('%sbxhreorient --orientation=LAS %s.bxh %s.bxh',bxhpath,functional2FN,functional2FN_RE));
unix(sprintf('%sbxh2analyze --overwrite --analyzetypes --niigz --niftihdr -s %s.bxh %s',bxhpath,functional2FN_RE,functional2FN_RE))


% repeat over with flash scans being scan numbers 7 AND OR 8!!!

% new test: (repeat for each type of flash that is recorded)

% 1. register exfunc1 --> flash2
unix(sprintf('%sflirt -dof 6 -in %s_brain.nii.gz -ref %s_brain.nii.gz -out func12flash -omat func12flash.mat', fslpath, functionalFN_RE,flashhrFN_RE))
% 2. register flash 2 --> exfunc 2
unix(sprintf('%sflirt -dof 6 -in %s_brain.nii.gz -ref %s_brain.nii.gz -out flash2func2 -omat flash2func2.mat', fslpath, flashhrFN_RE,functional2FN_RE))
% 3. apply old mask - apply mask to func2flash1
unix(sprintf('%sflirt -in wholebrain_exfunc.nii.gz -ref %s_brain.nii.gz -applyxfm -init func2flash.mat -interp nearestneighbor -out mask1-2-flash', fslpath, flash2FN_RE))
% 4: apply odl mask - apply mask to flash2func2
unix(sprintf('%sflirt -in mask1-2-flash -ref %s_brain.nii.gz -applyxfm -init flash2func2.mat -interp nearestneighbor -out mask1-2-flash-2-func2', fslpath, functional2FN_RE))

% now you have a mask in func 2 space!