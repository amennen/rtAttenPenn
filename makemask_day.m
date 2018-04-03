function makemask_day1(subjectNum,dayNum)
%%
projectName = 'rtAttenPenn';
%biac_dir = '/home/amennen/code/BIAC_Matlab_R2014a/';
biac_dir = '/Data1/packages/BIAC_Matlab_R2014a/';
bxhpath='/opt/BXH/1.11.1/bin/';
fslpath='/opt/fsl/5.0.9/bin/';
%fslpath = '/opt/FSL/5.0.9/bin/';
%add necessary package
%if ~exist('readmr','file')
    addpath(genpath(biac_dir));
    addpath([biac_dir '/mr/']);
    addpath([biac_dir '/general/'])
%end
save_dir = fullfile(fileparts(which('makemask_day.m')),['/data/subject' num2str(subjectNum), '/day' num2str(dayNum)]);
process_dir = [save_dir '/' 'reg' '/'];
roi_name = 'wholebrain_mask';
code_dir = fileparts(which('makemask_day.m'));
addpath(genpath(code_dir));

%if ~exist(process_dir)
%    mkdir(process_dir)
%end
cd(process_dir)
%% create mask file for real-time dicom files

%load registered anatomical ROI
if dayNum==1
	maskStruct = readmr([roi_name '_exfunc.bxh'],'BXH',{[],[],[]});
	functionalFN = 'exfunc';
else
	maskStruct = readmr(['mask12func2' '.bxh'], 'BXH', {[],[],[]});
	functionalFN = 'exfunc2';
end
brainExtFunc = readmr([functionalFN '_brain.bxh'], 'BXH',{[],[],[]});

%rotate anatomical ROI to be in the same space as the mask - check that this works for different scans/ROIs
anatMaskRot = zeros(size(brainExtFunc.data));
brainExtRot = zeros(size(brainExtFunc.data));
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
%mask_indices = allinMask(find(allinMask)); % just use all the ones from the registration
[gX gY gZ] = ind2sub(size(mask),mask_indices);
mask_brain = zeros(size(mask,1),size(mask,2),size(mask,3));
for j=1:length(mask_indices)
    mask_brain(gX(j),gY(j),gZ(j)) = 1;
end

checkMask = 0;
if checkMask
    plot3Dbrain(mask,[], 'mask')    
    plot3Dbrain(mask_brain, [], 'mask_brain')
end
% use the mask that has been checked there's nothing outside the functional
% brain
mask=mask_brain;
%save anatomical mask
save([code_dir '/data/subject' num2str(subjectNum) '/day' num2str(dayNum) '/mask_' num2str(subjectNum) '_' num2str(dayNum)],'mask');
fprintf('Done with mask creation\n');
% if cd into the directory, cd out of it back to the general exp folder
cd(code_dir)

end
