% ProcessMask: made into script so can check registration

subjNum = 100;
funcScan = 5;
runNum = 1;

startProcess = GetSecs;
img_mat = 64; %image matrix size
ROI = -1;
processNew = 1;
makeMprageNifti = processNew;
extractBrain = processNew;
registerToStandard = processNew;
makeTestFuncRun = processNew;
registerMprageToNifti =processNew;
registerAnatMaskToNifti = processNew;
brainExtractFunctional = processNew;
createMaskFileForRTDicoms = 1;

if IsLinux
    biac_dir = '/Users/amennen/code/BIAC_Matlab_R2014a/';
    bxhpath='/opt/BXH/1.11.1/bin/';
    fslpath='/opt/fsl/5.0.9/bin/';
end

%add necessary package
if ~exist('readmr','file')
    addpath(genpath(biac_dir));
    addpath([biac_dir '/mr/']);
    addpath([biac_dir '/general/'])
end

setenv('FSLOUTPUTTYPE','NIFTI_GZ');
if matchNum == 0
    save_dir = ['./data/' num2str(subjectNum)];
    %save(['./data/' num2str(subjectNum) '/mask_' num2str(subjectNum)],'mask');
else
    %save(['./data/' num2str(subjectNum) '_match/mask_' num2str(subjectNum)],'mask');
end

process_dir = [save_dir 'reg' '/'];
roi_name = 'standard_brain';
roi_dir = fullfile(fslpath, 'data/standard/MNI152_T1_2mm_brain.nii.gz'); % change this path name to wherever you put it on the penn computer!
if ~exist(process_dir)
    mkdir(process_dir)
end
cd(process_dir)


%scan numbers: mprage is 5, epis are 9:2:19
scanNum = 3;
highres_scanstr = num2str(scanNum, '%2.2i');

%fileStr = num2str(fileNum, '%3.3i');
%specificFile = ['001_0000' scanStr '_000' fileStr '.dcm'];

%first let's try loading in the mprage file

%taken from: registrationHighRes
highres_test_file = fullfile(dicom_dir,['001_0000' highres_scanstr '_000001.dcm']);

while ~exist(highres_test_file,'file')
    %error('the test file for the high resolution scan does not exist: %s',highres_test_file);
end
fprintf('Found highres file!\n')
%% make mprage nifti file

highres_fn = 'highres_old_orientation';
highres_reorient_fn = 'highres_new_orientation';

highresfiles_genstr = sprintf('%s001_0000%s_0*',dicom_dir,highres_scanstr); %general string for ALL mprage files**

if makeMprageNifti
    
    %convert mprage dicom files to a bxh wrapper
    unix(sprintf('%sdicom2bxh %s %s.bxh',bxhpath,highresfiles_genstr,highres_fn));
    
    %reorient bxh wrapper
    unix(sprintf('%sbxhreorient --orientation=LAS %s.bxh %s.bxh',bxhpath,highres_fn,highres_reorient_fn));
    
    %convert the reoriented bxh wrapper to a nifti file
    unix(sprintf('%sbxh2analyze --overwrite --analyzetypes --niigz --niftihdr -s %s.bxh %s',bxhpath,highres_reorient_fn,highres_reorient_fn))
    
end

%% brain extract (skull strip) mprage

%bet_param = .4; %need to check parameter for BET if using a different mprage

%brain extract mprage
if extractBrain
    unix(sprintf('%sbet %s.nii.gz %s_brain -R -m',fslpath,highres_reorient_fn,highres_reorient_fn));
end
%this works too!! again, saves in whatever directory you're in
%% register everything to standard

exFuncScanNum = funcScan;
exFunc_scanstr = num2str(exFuncScanNum, '%2.2i');
exFunc_test_file = fullfile(dicom_dir,['001_0000' exFunc_scanstr '_000008.dcm']);
exfunc_fn = 'example_func_old_orientation';
exfunc_reorient_fn = 'example_func_new_orientation';
highres_reorient_fn = 'highres_new_orientation';
exfunc2highres_mat='example_func2highres';
highres2exfunc_mat='highres2example_func';

StartReg= GetSecs;
if registerToStandard
    %register high resolution mprage (bet-extracted) to standard
    % if strncmp(computer,'MACI',4)
    unix(sprintf('%sflirt -in %s_brain.nii.gz -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz -out highres2standard -omat highres2standard.mat -cost corratio -dof 12 -searchrx -30 30 -searchry -30 30 -searchrz -30 30 -interp trilinear',fslpath,highres_reorient_fn));
    unix(sprintf('%sfnirt --iout=highres2standard_head --in=%s.nii.gz --aff=highres2standard.mat --cout=highres2standard_warp --iout=highres2standard --jout=highres2highres_jac --config=T1_2_MNI152_2mm --ref=$FSLDIR/data/standard/MNI152_T1_2mm.nii.gz --refmask=$FSLDIR/data/standard/MNI152_T1_2mm_brain_mask_dil --warpres=10,10,10', fslpath,highres_reorient_fn));
    unix(sprintf('%sapplywarp -i %s_brain.nii.gz -r $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz -o highres2standard -w highres2standard_warp',fslpath,highres_reorient_fn));
    
    %compute inverse transform (standard to highres)
    unix(sprintf('%sconvert_xfm -inverse -omat standard2highres.mat highres2standard.mat', fslpath));
    %unix(sprintf('%sflirt -in %s_brain.nii.gz -ref $FSLDIR/data/standard/mni152_t1_2mm_brain.nii.gz -out highres2standard -omat highres2standard.mat -cost corratio -dof 12 -searchrx -30 30 -searchry -30 30 -searchrz -30 30 -interp trilinear',fslpath,highres_reorient_fn));
    %make inverse for the warped image
    unix(sprintf('%sinvwarp -w highres2standard_warp -o standard2highres_warp -r %s_brain.nii.gz',fslpath,highres_reorient_fn));
    
end
t.standard2highres = GetSecs - StartReg;
fprintf('Done with standard2highres registration. Time = %6.2f \n',t.standard2highres);

%% now use this to create functional mask once you have functional data
% 
%k = batch('Reg_func2highres', 'Profile', 'local');
exFuncScanNum = funcScan;
exFunc_scanstr = num2str(exFuncScanNum, '%2.2i');
exFunc_test_file = fullfile(dicom_dir,['001_0000' exFunc_scanstr '_000008.dcm']);
while ~exist(exFunc_test_file,'file')
    %error('the test file for the functional scan does not exist: %s',exFunc_test_file);
end
pause(0.2) %pause when the file appears for complete transfer
fprintf('Found example functional file!\n')
% now taken from GenerateMask: does k-means cluster-more generous than
% brain skull

vol = ReadFile(exFunc_test_file,64,0);
mask = BrainMask(vol,0,0);
imagesc(mask(:,:,10)); %checks that the dicom files are properly aligned
save([process_dir 'mask_wholeBrain' '.mat'], 'mask');

%% make test functional run
startFunctional = GetSecs;
exfunc_fn = 'example_func_old_orientation';
exfunc_reorient_fn = 'example_func_new_orientation';
if makeTestFuncRun
    %convert test EPI dicom file to a bxh wrapper
    unix(sprintf('%sdicom2bxh %s001_0000%s_0* %s.bxh',bxhpath,dicom_dir,exFunc_scanstr,exfunc_fn));
    
    %reorient bxh wrapper
    unix(sprintf('%sbxhreorient --orientation=LAS %s.bxh %s.bxh',bxhpath,exfunc_fn,exfunc_reorient_fn));
    
    %convert the reoriented bxh wrapper to a nifti file
    unix(sprintf('%sbxh2analyze --overwrite --analyzetypes --niigz --niftihdr -s %s.bxh %s',bxhpath,exfunc_reorient_fn,exfunc_reorient_fn))
end

%% register mprage to nifti file

highres_reorient_fn = 'highres_new_orientation';

exfunc2highres_mat='example_func2highres';
highres2exfunc_mat='highres2example_func';


if registerMprageToNifti
    
    %use FSL's BBR function to register example functional image to high resolution mprage
    regFunction = 'epi_reg'; %epi_reg, flirt
    if strcmp(regFunction,'epi_reg')
        unix(sprintf('%sepi_reg --epi=%s --t1=%s --t1brain=%s_brain --out=%s',fslpath,exfunc_reorient_fn,highres_reorient_fn,highres_reorient_fn,exfunc2highres_mat))
    elseif strcmp(regFunction,'flirt')
        unix(sprintf('%sflirt -in %s -ref %s_brain -out %s -omat %s -searchrx -30 30 -searchry -30 30 -searchrz -30 30 -interp nearestneighbour',fslpath,exfunc_reorient_fn,highres_reorient_fn,exfunc2highres_mat,[exfunc2highres_mat '.mat']));
    end
    
    %compute inverse transform
    unix(sprintf('%sconvert_xfm -inverse -omat %s.mat %s.mat',fslpath,highres2exfunc_mat,exfunc2highres_mat));
end

t.standard2func = GetSecs - startFunctional;
fprintf('Done with standard2func registration, time = %6.2f', t.standard2func);

%% register anatomical mask to nifti file
if registerAnatMaskToNifti
    unix(sprintf('%sapplywarp -i %s%s.nii.gz -r %s.nii.gz -o %s_exfunc.nii.gz -w standard2highres_warp.nii.gz --postmat=%s.mat',fslpath,roi_dir,roi_name,exfunc_reorient_fn,roi_name,highres2exfunc_mat));
    
    %register the anatomical ROI to the example func dimensions
    % unix(sprintf('%sflirt -in %s%s.nii.gz -ref %s.nii.gz -applyxfm -init standard2example_func.mat -out %s_exfunc -searchrx -60 60 -searchry -60 60 -searchrz -60 60',fslpath,roi_dir,roi_name,exfunc_reorient_fn,roi_name)
    %threshold the registered mask (.1 is arbitrary)
    
    %unix(sprintf('%sfslmaths %s_exfunc.nii.gz -thr .1 -bin
    %%s_exfunc_bin',fslpath,roi_name,roi_name)) something here is why its
    %%bin
    
    %unzip, if necessary
    if exist(sprintf('%s_exfunc.nii.gz',roi_name),'file')
        unix(sprintf('gunzip %s_exfunc.nii.gz',roi_name));
    end
    
    %make bxh wrapper: do this to use for dicom files?
    unix(sprintf('%sbxhabsorb %s_exfunc.nii %s_exfunc.bxh',bxhpath,roi_name,roi_name));
end

%% brain extract functional scan
if brainExtractFunctional
    % first take average
    unix(sprintf('%sfslmaths %s.nii.gz -Tmean %s_mean.nii.gz',fslpath,exfunc_reorient_fn,exfunc_reorient_fn));
    % then brain extract
    unix(sprintf('%sbet %s_mean.nii.gz %s_mean_brain -R -m',fslpath,exfunc_reorient_fn,exfunc_reorient_fn));
    % now unzip and convert to load into matlab
    %unzip, if necessary
    if exist(sprintf('%s_mean_brain.nii.gz',exfunc_reorient_fn),'file')
        unix(sprintf('gunzip %s_mean_brain.nii.gz',exfunc_reorient_fn));
    end
    
    %make bxh wrapper: do this to use for dicom files?
    unix(sprintf('%sbxhabsorb %s_mean_brain.nii %s_mean_brain.bxh',bxhpath,exfunc_reorient_fn,exfunc_reorient_fn));
end
%% create mask file for real-time dicom files
% this is where you would make the mask bigger
startMask = GetSecs;
if createMaskFileForRTDicoms
    %load registered anatomical ROI
    maskStruct = readmr([roi_name '_exfunc.bxh'],'BXH',{[],[],[]});
    
    brainExtFunc = readmr([exfunc_reorient_fn '_mean_brain.bxh'], 'BXH',{[],[],[]});
    
    %load whole-brain mask-actual whole brain mask from example epi file:
    %see if masks are in the same space or not
    load(fullfile(process_dir,['mask_wholeBrain' '.mat']));
    
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
  
    % now check that the new mask isn't outside the brain
    i_stretched = find(stretchedMask);
    new_indices = i_stretched(find(ismember(i_stretched,allinBrainExt)));
    [gX gY gZ] = ind2sub(size(mask),new_indices);
    stretched_brain = zeros(size(mask,1),size(mask,2),size(mask,3));
    for j=1:length(new_indices)
        stretched_brain(gX(j),gY(j),gZ(j)) = 1;
    end
    

    %save anatomical mask
    if matchNum == 0
        save(['./data/' num2str(subjectNum) '/mask_' num2str(subjectNum)],'mask');
    else
        save(['./data/' num2str(subjectNum) '_match/mask_' num2str(subjectNum)],'mask');
    end
end
fprintf('Done with mask creation\n');
t.mask = GetSecs - startMask;
t.total = GetSecs - startProcess;
save(fullfile(process_dir, 'timing'), 't');
fprintf('Standard2highres time = %7.2f \nStandard2func time = %7.2f \nMask time = %7.2f \n Total time = %7.2f\n', t.standard2highres, t.standard2func,t.mask,t.total);
% if cd into the directory, cd out of it back to the general exp folder
cd ../
