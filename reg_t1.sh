#!/bin/bash
#Author: Anne
#Purpose: register t1 to standard space
# Things it does
# 1. skull strip data
# 2. register to standard space
# 3. invert transformation

source globals.sh
echo "subject number is $subjectNum, day $dayNum, run $runNum"
subject_save_path=$project_path/data/subject$subjectNum/day$dayNum/reg
# move into subjects directory
mkdir -pv $subject_save_path
cd $subject_save_path
echo "moving into folder: $subject_save_path"

flirt -in $highresFN_RE_brain.nii.gz -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz -out highres2standard -omat highres2standard.mat -cost corratio -dof 12 -searchrx -30 30 -searchry -30 30 -searchrz -30 30 -interp trilinear
fnirt --iout=highres2standard_head --in=$highresFN_RE.nii.gz --aff=highres2standard.mat --cout=highres2standard_warp --iout=highres2standard --jout=highres2highres_jac --config=T1_2_MNI152_2mm --ref=$FSLDIR/data/standard/MNI152_T1_2mm.nii.gz --refmask=$FSLDIR/data/standard/MNI152_T1_2mm_brain_mask_dil --warpres=10,10,10
applywarp -i $highresFN_RE_brain.nii.gz -r $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz -o highres2standard -w highres2standard_warp
#compute inverse transform (standard to highres)
convert_xfm -inverse -omat standard2highres.mat highres2standard.mat
invwarp -w highres2standard_warp -o standard2highres_warp -r $highresFN_RE_brain.nii.gz