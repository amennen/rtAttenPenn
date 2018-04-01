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
subject_day1_path=$project_path/data/subject$subjectNum/day1/reg
# move into subjects directory
mkdir -pv $subject_save_path
cd $subject_save_path
echo "moving into folder: $subject_save_path"

subjName=$(date +"%m%d%y")$runNum'_'$projectName
echo "subject name is $subjName"
scannerdate=$(date +"%Y%m%d")
scanFolder=$dicom_path/$(date +"%Y%m%d")'.'$subjName'.'$subjName
echo "looking for dicoms in $scanFolder"

# Process t1-weighted MPRAGE and check brain extraction!
functional2FN=exfunc2
functional2FN_RE=exfunc2_re
fileN=6
exfunc_str=$(printf "%s/001_0000%02d_0000%02d.dcm" "$scanFolder" "$functionalScan" "$fileN")
if [ $1 -eq 1 ]
then
	$bxhpath/dicom2bxh $highresfiles_genstr $functional2FN.bxh
	$bxhpath/bxhreorient --orientation=LAS $functional2FN.bxh $functional2FN_RE.bxh  
	$bxhpath/sbxh2analyze --overwrite --analyzetypes --niigz --niftihdr -s $functional2FN_RE.bxh $functional2FN_RE
fi

bet $functional2FN_RE.nii.gz$ $functional2FN_RE_brain -R -m
if [ -f $functional2FN_RE_brain.nii.gz ]; then echo "ungzipping epi"; gunzip $functional2FN_RE_brain.nii.gz ; fi
bxhabsorb $functional2FN_RE_brain.nii $functional2FN_RE_brain.bxh

flirt -dof 6 -in $subject_day1_path/$functionalFN_RE.nii.gz -ref $functional2FN_RE.nii.gz -out func12func2 -omat func12func2.mat 
flirt -in $subject_day1_path/wholebrain_mask_exfunc -ref $functional2FN_RE.nii.gz -applyxfm -init func12func2.mat -interp nearestneighbour -out mask12func2

if [ -f $mask12func2.nii.gz ]; then echo "ungzipping mask"; gunzip $mask12func2.nii.gz ; fi
$bxhpath/bxhabsorb $mask12func2.nii $mask12func2.bxh